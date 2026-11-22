package sample

import "core:fmt"
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

FRAG_PATH :: "./mandelbrot/mandelbrot.frag"

State :: struct {
    T: f32,
    shader: rl.Shader
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
    state.shader = rl.LoadShader(nil, FRAG_PATH)
}

@(export)
pre_reload :: proc "c" () -> rawptr {
    return state
}

@(export)
update :: proc "c" (dt: f32) {
    context = runtime.default_context()
    if rl.IsKeyPressed(.E) {
        rl.UnloadShader(state.shader)
        state.shader = rl.LoadShader(nil, FRAG_PATH)
        fmt.eprintln("[INFO] Recompiled shader.")
    }
    state.T += dt

    res_loc := rl.GetShaderLocation(state.shader, "u_resolution")
    resolution := Vec2{SW(), SH()}
    rl.SetShaderValueV(state.shader, res_loc, &resolution, .VEC2, 1)
    {
        rl.ClearBackground(rl.GetColor(0x181818FF))

        f := f32(0.05)
        pad := f * 0.2
        rec := rl.Rectangle {SW(f), SH(f), SW(1.-2.*f), SH(1.-2.*f)}
        padded_rec := rl.Rectangle {
            x = rec.x - SW(pad),
            y = rec.y - SW(pad),
            width = rec.width + 2.*SW(pad),
            height = rec.height + 2.*SW(pad),
        }
        // rl.DrawRectangleRec(padded_rec, rl.DARKGRAY)
        rl.DrawRectangleLinesEx(padded_rec, 2., rl.DARKGRAY)

        {
            rl.BeginShaderMode(state.shader)
            defer rl.EndShaderMode()
            rl.DrawRectangleRec(rec, rl.WHITE)
        }
    }
}
