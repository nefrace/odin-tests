package main

import "core:math"
import rl "vendor:raylib"

MAX_RECTS :: 32

Player :: struct {
	using collider: Collider,
	cameraOffset:   rl.Vector3,
	direction:      f32,
	yaw:            f32,
	velocity:       rl.Vector3,
}

Block :: struct {
	using collider: Collider,
	color:          rl.Color,
}

main :: proc() {
	rl.InitWindow(800, 600, "DOOM")
	defer rl.CloseWindow()

	player := Player {
		position = rl.Vector3{0, 1, 4},
		extends = rl.Vector3{0.5, 2, 0.5},
		cameraOffset = rl.Vector3{0, 0.8, 0},
		mask = {Layers.Solid},
		layer = {Layers.Solid, Layers.Player},
	}
	blocks := [MAX_RECTS]Block{}

	camera := rl.Camera3D {
		position = rl.Vector3{0, 1, 4},
		up = rl.Vector3{0, 1, 0},
		fovy = 90,
		projection = rl.CameraProjection.PERSPECTIVE,
	}

	for i in 0 ..< MAX_RECTS {
		pos := rl.Vector3{f32(rl.GetRandomValue(-15, 15)), 0, f32(rl.GetRandomValue(-15, 15))}
		ext := rl.Vector3{
			f32(rl.GetRandomValue(1, 4)),
			f32(rl.GetRandomValue(2, 15)),
			f32(rl.GetRandomValue(1, 4)),
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
			layer = {Layers.Solid},
			mask = {Layers.Solid},
		}
	}
	rl.DisableCursor()
	rl.SetTargetFPS(60)

	for (!rl.WindowShouldClose()) {
		using rl

		motion := GetMouseDelta()
		player.direction -= motion.x * 0.003
		dir_right := player.direction + math.PI / 2
		player.yaw -= motion.y * 0.003

		forward := Vector3{math.sin_f32(player.direction), 0, math.cos_f32(player.direction)}
		right := Vector3{math.sin_f32(dir_right), 0, math.cos_f32(dir_right)}

		if (IsKeyDown(rl.KeyboardKey.W)) {player.position += forward * 0.1}
		if (IsKeyDown(KeyboardKey.S)) {player.position -= forward * 0.1}
		if (IsKeyDown(rl.KeyboardKey.A)) {player.position += right * 0.1}
		if (IsKeyDown(KeyboardKey.D)) {player.position -= right * 0.1}

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
			pos := b.position - (b.extends / 4)
			DrawCubeV(b.position, b.extends, b.color)
			if colliders_intersect(player, blocks[i]) {
				colliding = true
			}
		}

		EndMode3D()
		if colliding {
			DrawText("COLLIDING", 0, 0, 30, DARKGRAY)
		}
		EndDrawing()

	}
}
