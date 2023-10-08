package collisions

import "core:math"
import rl "vendor:raylib"

// https://noonat.github.io/intersect/#sweeping-an-aabb-through-multiple-objects
// https://www.youtube.com/watch?v=3dIiTo7mlnU
// https://habr.com/ru/articles/334990/

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
	aex := a.extends / 2
	bex := b.extends / 2
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
	if dx <= 0 {
		return nil
	}

	dy := point.y - this.position.y
	py := this.extends.y - abs(dy)
	if dy <= 0 {
		return nil
	}

	dz := point.z - this.position.z
	pz := this.extends.z - abs(dz)
	if dz <= 0 {
		return nil
	}

	hit := Hit {
		collider = this,
	}

	// FIXME: Somehting is wrong with collisions in X coord

	if (px < py && px < pz) {
		sx := math.sign(dx)
		hit.delta.x = px * sx
		hit.normal.x = sx
		hit.position.x = this.position.x + this.extends.x * sx
		hit.position.y = point.y
		hit.position.z = point.z
	} else if (py < px && py < pz) {
		sy := math.sign(dy)
		hit.delta.y = py * sy
		hit.normal.y = sy
		hit.position.x = point.x
		hit.position.y = this.position.y + this.extends.y * sy
		hit.position.z = point.z
	} else if (pz < px && pz < py) {
		sz := math.sign(dz)
		hit.delta.z = pz * sz
		hit.normal.z = sz
		hit.position.x = point.x
		hit.position.y = point.y
		hit.position.z = this.position.z + this.extends.z * sz
	}
	return &hit
}
