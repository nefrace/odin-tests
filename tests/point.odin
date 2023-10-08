package tests

import c "../collisions"
import rl "vendor:raylib"


main :: proc() {
	rl.InitWindow(800, 600, "POINT TO AABB")
	camera := rl.Camera3D {
		position = rl.Vector3{5, 5, 5},
		up = rl.Vector3{0, 1, 0},
		fovy = 45,
		projection = rl.CameraProjection.PERSPECTIVE,
	}

	cube := c.Collider {
		position = rl.Vector3{0, 0, 0},
		extends = rl.Vector3{1, 1, 1},
	}
	point := rl.Vector3{2, 2, 2}

	rl.SetTargetFPS(60)

	for (!rl.WindowShouldClose()) {
		using rl

		UpdateCamera(&camera, CameraMode.ORBITAL)

		if (IsKeyDown(KeyboardKey.W)) {point.z -= 0.1}
		if (IsKeyDown(KeyboardKey.S)) {point.z += 0.1}
		if (IsKeyDown(KeyboardKey.A)) {point.x -= 0.1}
		if (IsKeyDown(KeyboardKey.D)) {point.x += 0.1}
		if (IsKeyDown(KeyboardKey.Q)) {point.y += 0.1}
		if (IsKeyDown(KeyboardKey.E)) {point.y -= 0.1}


		BeginDrawing()
		BeginMode3D(camera)

		ClearBackground(rl.BLACK)
		// DrawPlane(Vector3{0, 0, 0}, Vector2{32, 32}, LIGHTGRAY)
		DrawCubeV(point, Vector3{0.05, 0.05, 0.05}, RED)
		DrawCubeV(Vector3{point.x, 0, 0}, Vector3{0.05, 0.05, 0.05}, RED)
		DrawCubeV(Vector3{0, point.y, 0}, Vector3{0.05, 0.05, 0.05}, YELLOW)
		DrawCubeV(Vector3{0, 0, point.z}, Vector3{0.05, 0.05, 0.05}, BLUE)
		DrawCubeWiresV(cube.position, cube.extends * 2, RED)


		hit := c.collider_intersect_point(cube, point)
		if hit != nil {
			DrawCubeV(hit.position, Vector3{0.05, 0.05, 0.05}, MAROON)
		}

		EndMode3D()
		EndDrawing()

	}
}
