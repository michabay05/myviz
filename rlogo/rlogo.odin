package rlogo

import "core:math"
import "base:runtime"
import rl "vendor:raylib"

Vec2 :: rl.Vector2
Vec3 :: rl.Vector3

SW :: proc(factor: f32 = 1.0) -> f32 {
    return f32(rl.GetScreenWidth()) * factor
}
SH :: proc(factor: f32 = 1.0) -> f32 {
    return f32(rl.GetScreenHeight()) * factor
}

Anim_Func :: proc(t: f32)
Anim :: struct {
    func: Anim_Func,
    duration: int,
    start_frame: int,
}
anim :: proc(func: Anim_Func, duration, start_frame: int) -> Anim {
    return {
        func = func,
        duration = duration,
        start_frame = start_frame
    }
}

State :: struct {
    anims: [dynamic]Anim,
    index: int,
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
    state^ = {
        anims = make([dynamic]Anim),
        index = 0
    }
    append(&state.anims,
        anim(blinking_dot, 60*3, 0),
        anim(line_extend_left_down, 60, 0),
        anim(line_extend_right_up, 60, 0),
    )

    // Compute the start frame index
    total := int(0)
    for &anim in state.anims {
        anim.start_frame = total
        total += anim.duration
    }
}

@(export)
pre_reload :: proc "c" () -> rawptr {
    return state
}

@(export)
update :: proc "c" (dt: f32) {
    context = runtime.default_context()
    rl.ClearBackground(rl.RAYWHITE)

    if state.index >= len(state.anims) {
        state.anims[len(state.anims)-1].func(1.0)
        rl.DrawText("Done!", 10, i32(SH()-30), 20, rl.WHITE)
        return
    }

    anim := &state.anims[state.index]
    t := f32(state.frames - anim.start_frame) / f32(anim.duration)
    if 0 <= t && t <= 1 {
        anim.func(t)
        if t == 1.0 do state.index += 1
    }
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
    half_period := f32(0.2)
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
