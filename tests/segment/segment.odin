package tests

import c "../../collisions"
import rl "vendor:raylib"


main :: proc() {
	rl.InitWindow(800, 600, "SEGMENT TO AABB")
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
	point := rl.Vector3{-2, 0, 0}
	end := rl.Vector3{2, 0, 0}
	rl.DisableCursor()

	rl.SetTargetFPS(60)

	for (!rl.WindowShouldClose()) {
		using rl

		UpdateCamera(&camera, CameraMode.THIRD_PERSON)

		if (IsKeyDown(KeyboardKey.F)) {point.z -= 0.02}
		if (IsKeyDown(KeyboardKey.V)) {point.z += 0.02}
		if (IsKeyDown(KeyboardKey.C)) {point.x -= 0.02}
		if (IsKeyDown(KeyboardKey.B)) {point.x += 0.02}
		if (IsKeyDown(KeyboardKey.T)) {point.y += 0.02}
		if (IsKeyDown(KeyboardKey.G)) {point.y -= 0.02}

		if (IsKeyDown(KeyboardKey.I)) {end.z -= 0.02}
		if (IsKeyDown(KeyboardKey.K)) {end.z += 0.02}
		if (IsKeyDown(KeyboardKey.J)) {end.x -= 0.02}
		if (IsKeyDown(KeyboardKey.L)) {end.x += 0.02}
		if (IsKeyDown(KeyboardKey.U)) {end.y += 0.02}
		if (IsKeyDown(KeyboardKey.O)) {end.y -= 0.02}


		BeginDrawing()
		BeginMode3D(camera)

		ClearBackground(rl.BLACK)
		// DrawPlane(Vector3{0, 0, 0}, Vector2{32, 32}, LIGHTGRAY)
		DrawCubeV(point, Vector3{0.05, 0.05, 0.05}, WHITE)
		DrawLine3D(point, end, YELLOW)
		DrawCubeWiresV(cube.position, cube.extends * 2, RED)


		hit := c.collider_intersect_segment(cube, point, end - point, 0)
		if hit != nil {
			DrawCubeV(hit.position, Vector3{0.05, 0.05, 0.05}, GREEN)
			DrawLine3D(Vector3{0, 0, 0}, hit.normal, RED)
			// DrawCubeV(hit.delta, Vector3{0.05, 0.05, 0.05}, BLUE)
			// DrawCubeV(hit.normal, Vector3{0.05, 0.05, 0.05}, YELLOW)
		}

		EndMode3D()
		EndDrawing()

	}
}
