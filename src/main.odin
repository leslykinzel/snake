package main

import "vendor:raylib"

SCREEN_TITLE :: "raylib example"
SCREEN_W :: 800
SCREEN_H :: 450

main :: proc() {
    using raylib

    InitWindow(SCREEN_W, SCREEN_H, SCREEN_TITLE)
    defer CloseWindow()

    rotation: f32

    SetTargetFPS(60)

    for !WindowShouldClose() {
        rotation += 0.2

        {
            BeginDrawing()
            defer EndDrawing()

            ClearBackground(RAYWHITE)

            DrawText("Some basic shapes available on raylib", 20, 20, 20, DARKGRAY)

            DrawCircle(SCREEN_W/5, 120, 35, DARKBLUE)
            DrawCircleGradient(SCREEN_W/5, 220, 60, GREEN, SKYBLUE)
            DrawCircleLines(SCREEN_W/5, 340, 80, DARKBLUE)

            DrawRectangle(SCREEN_W/4*2 - 60, 100, 120, 60, RED)
            DrawRectangleGradientH(SCREEN_W/4*2 - 90, 170, 180, 130, MAROON, GOLD)
            DrawRectangleLines(SCREEN_W/4*2 - 40, 320, 80, 60, ORANGE)

            fw := f32(SCREEN_W)

            DrawTriangle(
                {fw/4 * 3, 80},
                {fw/4 * 3 - 60, 150},
                {fw/4 * 3 + 60, 150}, VIOLET,
            )
            DrawTriangleLines(
                {fw/4 * 3, 160},
                {fw/4 * 3 - 60, 150},
                {fw/4 * 3 + 60, 150}, DARKBLUE,
            )

            DrawPoly({fw/4 * 3, 330}, 6, 80, rotation, BROWN)
            DrawPolyLines({fw/4 * 3, 330}, 6, 90, rotation, BROWN)
            DrawPolyLinesEx({fw/4 * 3, 330}, 6, 85, rotation, 6, BEIGE)

            DrawLine(18, 42, SCREEN_W -18, 42, BLACK)
        }
    }
}
