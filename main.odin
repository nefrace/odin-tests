package main

import "core:fmt"
import "core:math"
import "core:strings"
import "core:strconv"
import col "shared/collisions"
import vec "shared/vector"
import rl "vendor:raylib"

MAX_RECTS :: 2000

Player :: struct {
	using collider: col.Collider,
	cameraOffset:   rl.Vector3,
	direction:      f32,
	yaw:            f32,
	velocity:       rl.Vector3,
	onFloor: bool,
}

Block :: struct {
	using collider: col.Collider,
	color:          rl.Color,
}

main :: proc() {
	rl.InitWindow(800, 600, "DOOM")
	defer rl.CloseWindow()
	player := Player {
		position = rl.Vector3{0, 3, 4},
		extends = rl.Vector3{0.5, 1, 0.5},
		cameraOffset = rl.Vector3{0, 0.8, 0},
		mask = {col.Layers.Solid},
		layer = {col.Layers.Solid, col.Layers.Player},
	}
	blocks := [MAX_RECTS]Block{}

	camera := rl.Camera3D {
		position = rl.Vector3{0, 1, 4},
		up = rl.Vector3{0, 1, 0},
		fovy = 90,
		projection = rl.CameraProjection.PERSPECTIVE,
	}

	for i in 0 ..< MAX_RECTS-1 {
		pos := rl.Vector3{f32(rl.GetRandomValue(-300, 300))/10, f32(rl.GetRandomValue(0, 200))/10, f32(rl.GetRandomValue(-300, 300))/10}
		ext := rl.Vector3{
			f32(rl.GetRandomValue(2, 8)) / 4,
			f32(rl.GetRandomValue(2, 8)) / 4,
			f32(rl.GetRandomValue(2, 8)) / 4,
		}
		color := rl.Color{
			u8(rl.GetRandomValue(20, 255)),
			u8(rl.GetRandomValue(20, 255)),
			u8(rl.GetRandomValue(20, 255)),
			255,
		}
		blocks[i] = Block {
			position = pos,
			extends = ext,
			color = color,
			layer = {},
			mask = {col.Layers.Solid},
		}
	}
	blocks[MAX_RECTS-1] = Block{
		position = rl.Vector3{0, 0, 0},
		extends = rl.Vector3{40, 0.3, 40},
		color = rl.DARKGRAY,
		layer = {col.Layers.Solid},
		mask = {col.Layers.Solid},
	}
	rl.DisableCursor()
	rl.SetTargetFPS(60)

	for (!rl.WindowShouldClose()) {
		using rl

		mouseDelta := GetMouseDelta()
		player.direction -= mouseDelta.x * 0.003
		dir_right := player.direction + math.PI / 2
		player.yaw -= mouseDelta.y * 0.003

		forward := Vector3{math.sin_f32(player.direction), 0, math.cos_f32(player.direction)}
		right := Vector3{math.sin_f32(dir_right), 0, math.cos_f32(dir_right)}

		player.velocity.y -= 0.009
		motion := Vector3{}
		if (IsKeyDown(rl.KeyboardKey.W)) {motion += forward * 0.1}
		if (IsKeyDown(KeyboardKey.S)) {motion -= forward * 0.1}
		if (IsKeyDown(rl.KeyboardKey.A)) {motion += right * 0.1}
		if (IsKeyDown(KeyboardKey.D)) {motion -= right * 0.1}
		if (IsKeyPressed(KeyboardKey.SPACE) && player.onFloor) {player.velocity.y = 0.2; player.onFloor = false}
		motion = vec.Vector3ClampValue(motion, 0, 0.2)
		player.velocity.xz = motion.xz

		cols: for j in 0 ..< 1 {
		for i in 0 ..< MAX_RECTS {
			b := &blocks[i]
			if card(player.mask & b.layer) == 0 {
					continue
				}
			if player.velocity.xyz == {0, 0, 0} {
					break cols
				}
			hit, ok := col.collider_intersect_segment(
				b,
				player.position,
				player.velocity,
				player.extends,
			).?
			if ok {
				player.position = hit.position
				v := vec.Vector3ProjectToPlane(player.velocity, hit.normal)
				player.velocity = v
				if hit.normal.y > 0 {
					player.velocity.y = 0
					player.onFloor = true
				}				
			}
		}
		}
		player.position += player.velocity
		if player.position.y < 1 {
			player.position.y = 1
			player.velocity.y = 0
			player.onFloor = true
		}

		camera.position = player.position + player.cameraOffset
		target := Vector3{0, 0, 1}
		target.z = math.cos_f32(player.direction) * math.cos_f32(player.yaw)
		target.x = math.sin_f32(player.direction) * math.cos_f32(player.yaw)
		target.y = math.sin_f32(player.yaw)

		camera.target = player.position + player.cameraOffset + target

		BeginDrawing()
		BeginMode3D(camera)

		ClearBackground(rl.RAYWHITE)
		DrawPlane(Vector3{0, 0, 0}, Vector2{32, 32}, LIGHTGRAY)

		colliding := false
		for i in 0 ..< MAX_RECTS {
			b := &blocks[i]
			DrawCubeV(b.position, b.extends * 2, b.color)
		}

		EndMode3D()
		if colliding {
			DrawText("COLLIDING", 0, 0, 30, DARKGRAY)
		}
		fps := GetFPS()
		f := strings.clone_to_cstring(fmt.aprintln(fps))
		DrawText(f, 0, 0, 20, BLACK)
		EndDrawing()

	}
}
