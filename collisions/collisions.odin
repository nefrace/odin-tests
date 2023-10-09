package collisions

import "core:math"
import rl "vendor:raylib"

// https://noonat.github.io/intersect/#sweeping-an-aabb-through-multiple-objects
// https://www.youtube.com/watch?v=3dIiTo7mlnU
// https://habr.com/ru/articles/334990/
// https://gdbooks.gitbooks.io/3dcollisions/content/Chapter3/raycast_aabb.html

Layers :: enum {
	Solid,
	Player,
	Enemy,
}

Collider :: struct {
	id:       u64,
	position: rl.Vector3,
	extends:  rl.Vector3,
	layer:    bit_set[Layers],
	mask:     bit_set[Layers],
}

Hit :: struct {
	collider: Collider,
	position: rl.Vector3,
	delta:    rl.Vector3,
	normal:   rl.Vector3,
	time:     f32,
}

Sweep :: struct {
	hit:      Maybe(Hit),
	position: rl.Vector3,
	time:     f32,
}

colliders_intersect :: proc(a: Collider, b: Collider) -> bool {
	if card(a.mask & b.layer) == 0 {
		return false
	}
	aex := a.extends
	bex := b.extends
	cx :=
		a.position.x + aex.x > b.position.x - bex.x && a.position.x - aex.x < b.position.x + bex.x
	cy :=
		a.position.y + aex.y > b.position.y - bex.y && a.position.y - aex.y < b.position.y + bex.y
	cz :=
		a.position.z + aex.z > b.position.z - bex.z && a.position.z - aex.z < b.position.z + bex.z
	return cx && cy && cz
}

collider_intersect_point :: proc(this: Collider, point: rl.Vector3) -> ^Hit {
	dx := point.x - this.position.x
	px := this.extends.x - abs(dx)
	if px <= 0 {
		return nil
	}

	dy := point.y - this.position.y
	py := this.extends.y - abs(dy)
	if py <= 0 {
		return nil
	}

	dz := point.z - this.position.z
	pz := this.extends.z - abs(dz)
	if pz <= 0 {
		return nil
	}

	hit := Hit {
		collider = this,
	}

	switch {
	case px < py && px < pz:
		{
			sx := math.sign(dx)
			hit.delta.x = px * sx
			hit.normal.x = sx
			hit.position.x = this.position.x + this.extends.x * sx
			hit.position.y = point.y
			hit.position.z = point.z
		}
	case py <= px && py < pz:
		{
			sy := math.sign(dy)
			hit.delta.y = py * sy
			hit.normal.y = sy
			hit.position.x = point.x
			hit.position.y = this.position.y + this.extends.y * sy
			hit.position.z = point.z
		}
	case pz <= px && pz <= py:
		{
			sz := math.sign(dz)
			hit.delta.z = pz * sz
			hit.normal.z = sz
			hit.position.x = point.x
			hit.position.y = point.y
			hit.position.z = this.position.z + this.extends.z * sz
		}
	}

	return &hit
}


collider_intersect_segment_2d :: proc(
	this: Collider,
	point: rl.Vector3,
	magnitude: rl.Vector3,
	padding: rl.Vector3,
) -> ^Hit {
	scale := rl.Vector3{1 / magnitude.x, 1 / magnitude.y, 1 / magnitude.z}
	sign := rl.Vector3{math.sign_f32(scale.x), math.sign_f32(scale.y), math.sign_f32(scale.z)}
	neartime := (this.position - sign * (this.extends + padding) - point) * scale
	fartime := (this.position + sign * (this.extends + padding) - point) * scale
	if (neartime.x > fartime.y || neartime.y > fartime.x) {
		return nil
	}

	nt := neartime.x > neartime.y ? neartime.x : neartime.y
	ft := fartime.x < fartime.y ? fartime.x : fartime.y
	if nt >= 1 || ft <= 0 {
		return nil
	}

	hit := Hit {
		collider = this,
		time     = clamp(nt, 0, 1),
	}
	switch {
	case neartime.x > neartime.y:
		{
			hit.normal.x = -sign.x
			hit.normal.y = 0
		}
	case neartime.y >= neartime.x:
		{
			hit.normal.x = 0
			hit.normal.y = -sign.y
		}
	}
	hit.delta = (1.0 - hit.time) * -magnitude
	hit.position = point + magnitude * hit.time
	return &hit
}


collider_intersect_segment :: proc(
	this: Collider,
	point: rl.Vector3,
	magnitude: rl.Vector3,
	padding: rl.Vector3,
) -> ^Hit {
	scale := rl.Vector3{1 / magnitude.x, 1 / magnitude.y, 1 / magnitude.z}
	sign := rl.Vector3{math.sign_f32(scale.x), math.sign_f32(scale.y), math.sign_f32(scale.z)}
	neartime := (this.position - sign * (this.extends + padding) - point) * scale
	fartime := (this.position + sign * (this.extends + padding) - point) * scale
	if (neartime.x > fartime.y || neartime.y > fartime.x || neartime.z > fartime.z) {
		return nil
	}

	nt :=
		neartime.x > neartime.y ? (neartime.x > neartime.z ? neartime.x : neartime.z) : neartime.y
	ft := fartime.x < fartime.y ? (fartime.x < fartime.z ? fartime.x : fartime.z) : fartime.y
	if nt >= 1 || ft <= 0 {
		return nil
	}

	hit := Hit {
		collider = this,
		time     = clamp(nt, 0, 1),
	}

	if neartime.x > neartime.y && neartime.x > neartime.z {
		hit.normal.x = -sign.x
		hit.normal.y = 0
		hit.normal.z = 0
	} else if neartime.y >= neartime.x && neartime.y > neartime.z {
		hit.normal.x = 0
		hit.normal.y = -sign.y
		hit.normal.z = 0
	} else if neartime.z >= neartime.x && neartime.z >= neartime.y {
		hit.normal.x = 0
		hit.normal.y = 0
		hit.normal.z = -sign.z
	}
	hit.delta = (1.0 - hit.time) * -magnitude
	hit.position = point + magnitude * hit.time
	return &hit
}
