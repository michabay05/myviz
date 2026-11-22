package vizmain

import "core:fmt"
import "core:dynlib"
import "core:os"
import rl "vendor:raylib"

DL_Alloc_Proc :: #type proc "c" ()
DL_Pre_Reload_Proc :: #type proc "c" () -> rawptr
DL_Post_Reload_Proc :: #type proc "c" (state: rawptr)
DL_Update_Proc :: #type proc "c" (dt: f32)
DL_Symbols :: struct {
    alloc: DL_Alloc_Proc,
    pre_reload: DL_Pre_Reload_Proc,
    post_reload: DL_Post_Reload_Proc,
    update: DL_Update_Proc,

    _dl_handle: dynlib.Library
}

dl_reload :: proc(symbols: ^DL_Symbols, dl_path: string) -> bool {
    if symbols._dl_handle != nil {
        fmt.eprintfln("[INFO] Unloaded dll.")
        assert(dynlib.unload_library(symbols._dl_handle))
    }

    syms: DL_Symbols
    count, ok := dynlib.initialize_symbols(&syms, dl_path, handle_field_name="_dl_handle")
    if ok {
        fmt.eprintfln("[INFO] Loaded %d symbols.", count)
        symbols^ = syms
    } else {
        fmt.eprintln("[WARN] Failed to reload dll")
        fmt.eprintfln("[DEBUG] count = %v, ok = %v", count, ok)
    }
    return ok
}

main :: proc() {
    if len(os.args) != 2 {
        fmt.eprintfln("Usage: %v <file.so>", os.args[0])
        return;
    }

    dyn_path := os.args[1]
    sym: DL_Symbols
    if !dl_reload(&sym, dyn_path) {
        fmt.eprintfln("[ERROR] Unable to load symbols from '%s'.", dyn_path)
        return
    }

    rl.SetTraceLogLevel(.WARNING)
    rl.SetConfigFlags({.WINDOW_RESIZABLE})
    rl.InitWindow(800, 600, "myviz")
    defer rl.CloseWindow()
    rl.SetTraceLogLevel(.INFO)
    rl.SetExitKey(.Q)
    rl.SetTargetFPS(60)

    sym.alloc()
    state := sym.pre_reload()
    sym.post_reload(state)
    paused := false
    SW :: rl.GetScreenWidth

    t_mult := int(1)
    for !rl.WindowShouldClose() {
        if rl.IsKeyPressed(.R) {
            state := sym.pre_reload()
            // TODO(mabay): Fail more gracefully
            assert(dl_reload(&sym, dyn_path))
            fmt.eprintln("Reloaded dynamic library...")
            sym.post_reload(state)
        } else if rl.IsKeyPressed(.SPACE) {
            paused = !paused
        } else if rl.IsKeyPressed(.LEFT_SHIFT) {
            t_mult -= 1
            if t_mult == 0 do t_mult = -2;
        } else if rl.IsKeyPressed(.RIGHT_SHIFT) {
            t_mult += 1
            if t_mult == -1 do t_mult = 1;
        }

        {
            dt := 0.0 if paused else rl.GetFrameTime() * f32(t_mult)
            rl.BeginDrawing()
            defer rl.EndDrawing()
            sym.update(dt)

            if paused {
                rl.DrawRectangle(SW() - 65, 25, 10, 35, rl.WHITE)
                rl.DrawRectangle(SW() - 42, 25, 10, 35, rl.WHITE)
            }
            if t_mult != 1 {
                assert(t_mult != 0, "t_mult should not be zero.")
                text := rl.TextFormat("%dx", t_mult)
                if t_mult < 0 {
                    text = rl.TextFormat("1/%dx", -t_mult)
                }
                rl.DrawText(text, SW() - 65, 70, 20, rl.WHITE)
            }
        }
    }

    dynlib.unload_library(sym._dl_handle)
}
