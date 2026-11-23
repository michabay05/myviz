package rlogo

import "core:math/ease"
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
    camera: rl.Camera2D
}

state: ^State

@(export)
alloc :: proc "c" () {
    context = runtime.default_context()
    state = new(State)
}

@(export)
post_reload :: proc "c" (s: rawptr) {
    state = cast(^State)s
    context = runtime.default_context()
    // Reset state
    state.anims = utils.Anims{}
    utils.anims_init(&state.anims,
        utils.anim(rotating_rects, 60*10)
    )
    state.anims.index = 0
    state.frames = 0

    state.camera = rl.Camera2D{
        target = {0., 0.},
        offset = {SW(0.5), SH(0.5)},
        rotation = 0.,
        zoom = 1.,
    }
}

@(export)
pre_reload :: proc "c" () -> (rawptr, utils.Anims) {
    return state, state.anims
}

CELL_SZ :: 50
CELL_FILL_RATIO :: f32(0.625)

@(export)
update :: proc "c" (dt: f32) {
    context = runtime.default_context()
    rl.ClearBackground(rl.GetColor(0x151515FF))

    utils.anims_update(&state.anims, state.frames)
    state.frames += 1
}

rotating_rects :: proc(t: f32) {
    rl.BeginMode2D(state.camera)
    defer rl.EndMode2D()
    rows, cols := int(SH()) / CELL_SZ, int(SW()) / CELL_SZ

    t := t
    if t < 0.5 {
        t = rl.Remap(t, 0, 0.5, 1, 0)
    } else {
        t = rl.Remap(t, 0.5, 1, 0, 1)
    }
    t = ease.ease(.Circular_In_Out, t)

    rotation := t * 360.
    color := rl.ColorAlpha(rl.RED, 0.5)
    size := Vec2{1., 1.}*CELL_SZ*t
    fill_size := size * CELL_FILL_RATIO
    for r in 0..<rows {
        for c in 0..<cols {
            p := [2]f32{f32(c), f32(r)} * CELL_SZ - state.camera.offset + size/2
            rl.DrawRectanglePro({**p, **fill_size}, fill_size/2, rotation, color)
        }
    }
}
