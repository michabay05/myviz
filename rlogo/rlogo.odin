package rlogo

import "base:runtime"
import rl "vendor:raylib"
import "../utils"

Vec2 :: rl.Vector2
Vec3 :: rl.Vector3

SW :: proc(factor: f32 = 1.0) -> f32 {
    return f32(rl.GetScreenWidth()) * factor
}
SH :: proc(factor: f32 = 1.0) -> f32 {
    return f32(rl.GetScreenHeight()) * factor
}

State :: struct {
    anims: utils.Anims,
    frames: int,
}

state: ^State

@(export)
alloc :: proc "c" (dt: f32) {
    context = runtime.default_context()
    state = new(State)
}

@(export)
post_reload :: proc "c" (s: rawptr) {
    state = cast(^State)s
    context = runtime.default_context()
    // Reset state
    clear(&state.anims.items)
    utils.anims_init(&state.anims,
        utils.anim(blinking_dot, 60*3),
        utils.anim(line_extend_left_down, 60),
        utils.anim(line_extend_right_up, 60),
    )
    state.anims.index = 0
    state.frames = 0
}

@(export)
pre_reload :: proc "c" () -> rawptr {
    return state
}

@(export)
update :: proc "c" (dt: f32) {
    context = runtime.default_context()
    rl.ClearBackground(rl.RAYWHITE)

    utils.anims_update(&state.anims, state.frames)
    state.frames += 1
}

/* Animations steps
    - Blinking rectangular dot
    - Line extending simul. left and down
    - Line extending simul. right and up
    Source: https://github.com/raysan5/raylib/
    Dir: examples/shapes/shapes_logo_raylib_anim.c
*/

blinking_dot :: proc(t: f32) {
    half_period := f32(0.1)
    color := rl.BLACK if int(t/half_period)%2 == 0 else rl.BLANK
    rl.DrawRectangle(100, 100, 35, 35, color)
}

line_extend_left_down :: proc(t: f32) {
    final_x := i32(400)
    x := i32(t * f32(final_x))
    rl.DrawRectangle(100, 100, x, 35, rl.BLACK)
    rl.DrawRectangle(100, 100, 35, x, rl.BLACK)
}

line_extend_right_up :: proc(t: f32) {
    final_x := i32(400)
    x := i32(t * f32(final_x))

    rl.DrawRectangle(100, 100, final_x, 35, rl.BLACK)
    rl.DrawRectangle(100, 100, 35, final_x, rl.BLACK)
    rl.DrawRectangle(100+final_x-35, 100, 35, x, rl.BLACK)
    rl.DrawRectangle(100, 100+final_x-35, x, 35, rl.BLACK)

    if t == 1.0 {
        // NOTE(mabay): I know that this is a cope-out (because the source animation
        // has a typewriter effect) but it is what is it is.
        text: cstring = "raylib"
        font_sz: i32 = 45
        w := rl.MeasureText(text, font_sz)
        rl.DrawText("raylib", 500-w-35-20, 500-font_sz-35-20, font_sz, rl.BLACK)
    }
}
