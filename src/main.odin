// SNEK
package main

import "vendor:raylib"

SNAKE_LENGTH :: 256
SQUARE_SIZE  :: 31

Snake_t :: struct {
    position: raylib.Vector2,
    size:     raylib.Vector2,
    speed:    raylib.Vector2,
    color:    raylib.Color
}

Food_t :: struct {
    position: raylib.Vector2,
    size:     raylib.Vector2,
    active:   bool,
    color:    raylib.Color
}

SCREEN_WIDTH  : i32 = 800
SCREEN_HEIGHT : i32 = 800

FRAMES_COUNTER : i32 = 0
GAME_OVER      : bool = false
PAUSE          : bool = false

SNAKE          : [SNAKE_LENGTH]Snake_t = {}
SNAKE_POSITION : [SNAKE_LENGTH]raylib.Vector2 = {}
FRUIT          : Food_t = {}
ALLOW_MOVE     : bool = false
OFFSET         : raylib.Vector2 = {}
COUNTER_TAIL   : i32 = 0

main :: proc() {
    using raylib

    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Snake")
    defer CloseWindow()

    InitGame()

    SetTargetFPS(60)

    for !WindowShouldClose() {

        UpdateDrawFrame()

    }
}

// Initialize game variables
InitGame :: proc() {
    using raylib

    FRAMES_COUNTER = 0
    GAME_OVER      = false
    PAUSE          = false

    COUNTER_TAIL = 1
    ALLOW_MOVE   = false

    OFFSET.x = f32(SCREEN_WIDTH % SQUARE_SIZE)
    OFFSET.y = f32(SCREEN_HEIGHT % SQUARE_SIZE)

    for i := 0; i < SNAKE_LENGTH; i+=1 {
        SNAKE[i].position = (Vector2){ OFFSET.x/2, OFFSET.y/2 }
        SNAKE[i].size     = (Vector2){ SQUARE_SIZE, SQUARE_SIZE }
        SNAKE[i].speed    = (Vector2){ SQUARE_SIZE, 0 }
    
        if i == 0 { 
            SNAKE[i].color = DARKBLUE 
        }
        else {
            SNAKE[i].color = BLUE
        }

        for i := 0; i < SNAKE_LENGTH; i+=1 {
            SNAKE_POSITION[i] = (Vector2){ 0.0, 0.0 }
        }

        FRUIT.size   = (Vector2){ SQUARE_SIZE, SQUARE_SIZE }
        FRUIT.color  = SKYBLUE
        FRUIT.active = false
    }
}

// Update game state
UpdateGame :: proc() {
    using raylib

    if !GAME_OVER {

        if IsKeyPressed(KeyboardKey.P) { PAUSE = !PAUSE }

        if !PAUSE {
            // Handle movement inputs. (0, 0) is the top left corner.
            if IsKeyPressed(KeyboardKey.RIGHT) && (SNAKE[0].speed.x == 0) && ALLOW_MOVE {
                SNAKE[0].speed = (Vector2){ SQUARE_SIZE, 0 }
                ALLOW_MOVE = false
            }
            if IsKeyPressed(KeyboardKey.LEFT) && (SNAKE[0].speed.x == 0) && ALLOW_MOVE {
                SNAKE[0].speed = (Vector2){ -SQUARE_SIZE, 0 }
                ALLOW_MOVE = false
            }
            if IsKeyPressed(KeyboardKey.UP) && (SNAKE[0].speed.y == 0) && ALLOW_MOVE {
                SNAKE[0].speed = (Vector2){ 0, -SQUARE_SIZE }
                ALLOW_MOVE = false
            }
            if IsKeyPressed(KeyboardKey.DOWN) && (SNAKE[0].speed.y == 0) && ALLOW_MOVE {
                SNAKE[0].speed = (Vector2){ 0, SQUARE_SIZE }
                ALLOW_MOVE = false
            }

            for i := 0; i < int(COUNTER_TAIL); i+=1 {
                SNAKE_POSITION[i] = SNAKE[i].position
            }

            if (FRAMES_COUNTER % 5) == 0 {
                for i := 0; i < int(COUNTER_TAIL); i+=1 {
                    if i == 0 {
                        SNAKE[0].position.x += SNAKE[0].speed.x
                        SNAKE[0].position.y += SNAKE[0].speed.y
                        ALLOW_MOVE = true
                    }
                    else {
                        SNAKE[i].position = SNAKE_POSITION[i - 1]
                    }
                }
            }

            // Collide with edge of screen
            if ((SNAKE[0].position.x) > (f32(SCREEN_WIDTH) - OFFSET.x)) ||
               ((SNAKE[0].position.y) > (f32(SCREEN_HEIGHT) - OFFSET.y)) ||
               (SNAKE[0].position.x < 0) || 
               (SNAKE[0].position.y < 0) {
                GAME_OVER = true
            } 

            // Collide with self
            for i := 1; i < int(COUNTER_TAIL); i+=1 {
                if (SNAKE[0].position.x == SNAKE[i].position.x) && (SNAKE[0].position.y == SNAKE[i].position.y) {
                    GAME_OVER = true
                }
            }
            
            // Calculate fruit position
            if !FRUIT.active {
                FRUIT.active = true
                FRUIT.position = (Vector2){ 
                    f32(GetRandomValue(0, (SCREEN_WIDTH / SQUARE_SIZE) - 1)) * f32(SQUARE_SIZE) + OFFSET.x / 2,
                    f32(GetRandomValue(0, (SCREEN_HEIGHT / SQUARE_SIZE) - 1)) * f32(SQUARE_SIZE) + OFFSET.y / 2
                }

                for i := 0; i < int(COUNTER_TAIL); i+=1 {
                    for (FRUIT.position.x == SNAKE[i].position.x) && (FRUIT.position.y == SNAKE[i].position.y) {
                        FRUIT.position = (Vector2){
                            f32(GetRandomValue(0, (SCREEN_WIDTH / SQUARE_SIZE) - 1)) * f32(SQUARE_SIZE) + OFFSET.x / 2,
                            f32(GetRandomValue(0, (SCREEN_HEIGHT / SQUARE_SIZE) - 1)) * f32(SQUARE_SIZE) + OFFSET.y / 2
                        }
                        i = 0
                    }
                }
            }

            // Collision with fruit
            if (SNAKE[0].position.x < (FRUIT.position.x + FRUIT.size.x)) && 
               (SNAKE[0].position.x + SNAKE[0].size.x) > FRUIT.position.x &&
               (SNAKE[0].position.y < (FRUIT.position.y + FRUIT.size.y)) &&
               (SNAKE[0].position.y + SNAKE[0].size.y) > FRUIT.position.y {
                SNAKE[COUNTER_TAIL].position = SNAKE_POSITION[COUNTER_TAIL - 1]
                COUNTER_TAIL += 1
                FRUIT.active = false
            }

            FRAMES_COUNTER+=1
        }
    }
    else {
        // Restart
        if IsKeyPressed(KeyboardKey.ENTER) {
            InitGame()
            GAME_OVER = false
        }
    }
}

// Draw single frame
DrawGame :: proc() {
    using raylib
    
    BeginDrawing()

        ClearBackground(RAYWHITE)

        if !GAME_OVER {
            // Vertical lines
            for i := 0; i < int(SCREEN_WIDTH / SQUARE_SIZE + 1); i+=1 {
                DrawLineV(
                    (Vector2){ f32(SQUARE_SIZE * i) + OFFSET.x / 2, OFFSET.y / 2 },
                    (Vector2){ f32(SQUARE_SIZE * i) + OFFSET.x / 2, f32(SCREEN_HEIGHT) - OFFSET.y / 2 },
                    LIGHTGRAY
                )
            }
            // Horizontal lines
            for i := 0; i < int(SCREEN_HEIGHT / SQUARE_SIZE + 1); i+=1 {
                DrawLineV(
                    (Vector2){ OFFSET.x / 2, f32(SQUARE_SIZE * i) + OFFSET.y / 2 },
                    (Vector2){ f32(SCREEN_WIDTH) - OFFSET.x / 2, f32(SQUARE_SIZE * i) + OFFSET.y / 2 },
                    LIGHTGRAY
                )
            }
            // Snake
            for i := 0; i < int(COUNTER_TAIL); i+=1 {
                DrawRectangleV(
                    SNAKE[i].position, 
                    SNAKE[i].size, 
                    SNAKE[i].color
                )
            }

            // Fruit
            DrawRectangleV(FRUIT.position, FRUIT.size, FRUIT.color)

            // Score
            DrawText(
                TextFormat("SCORE: %d", COUNTER_TAIL-1),
                15,
                15,
                20,
                RED
            )

            if PAUSE {
                DrawText(
                    "GAME PAUSED", 
                    SCREEN_WIDTH / 2 - MeasureText("GAME PAUSED", 40) / 2,
                    SCREEN_HEIGHT / 2 - 40,
                    40,
                    GRAY
                )
            }
        }
        else {
            DrawText(
                "PRESS [ENTER] TO PLAY AGAIN",
                GetScreenWidth() / 2 - MeasureText("PRESS [ENTER] TO PLAY AGAIN", 20) / 2,
                GetScreenHeight() / 2 - 50,
                20,
                GRAY
            )
        }

    EndDrawing()
}

UpdateDrawFrame :: proc() {
    UpdateGame()
    DrawGame()
}