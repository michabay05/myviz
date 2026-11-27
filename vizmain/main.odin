package vizmain

import "core:time"
import "core:fmt"
import "core:dynlib"
import "core:os"
import rl "vendor:raylib"
import "../utils"

DL_Alloc_Proc :: #type proc "c" ()
DL_Pre_Reload_Proc :: #type proc "c" () -> (rawptr, utils.Anims)
DL_Post_Reload_Proc :: #type proc "c" (state: rawptr)
DL_Update_Proc :: #type proc "c" ()
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
    state, anims := sym.pre_reload()
    sym.post_reload(state)
    paused := false
    SW :: rl.GetScreenWidth
    SH :: rl.GetScreenHeight

    t_mult := int(1)
    rendering := false
    render_tex := rl.LoadRenderTexture(SW(), SH())
    render_frames, render_duration := 0, -1
    ffmpeg: FFmpeg

    skipped_frames := 0
    for !rl.WindowShouldClose() {
        if rl.IsKeyPressed(.R) {
            state, _ := sym.pre_reload()
            // TODO(mabay): Fail more gracefully
            assert(dl_reload(&sym, dyn_path))
            fmt.eprintln("Reloaded dynamic library...")
            sym.post_reload(state)
        } else if rl.IsKeyPressed(.G) {
            rendering = true
            state, anims = sym.pre_reload()
            sym.post_reload(state)
            render_frames = 0
            render_duration = utils.anims_duration(anims)
            // TODO(mabay): Fail more gracefully
            assert(render_duration > 0)

            ffmpeg = ffmpeg_start("output.mp4", int(SW()), int(SH()), 60)
            // NOTE(mabay): I'm doing this due to raylib's idiosyncrasy
            rl.SetTraceLogLevel(.WARNING)
        } else if rl.IsKeyPressed(.SPACE) {
            paused = !paused
        } else if rl.IsKeyPressed(.LEFT_SHIFT) {
            t_mult -= 1
            if t_mult == 0 do t_mult = -2;
        } else if rl.IsKeyPressed(.RIGHT_SHIFT) {
            t_mult += 1
            if t_mult == -1 do t_mult = 1;
        }

        if !rendering {
            rl.BeginDrawing()
            defer rl.EndDrawing()

            if paused {
                rl.DrawRectangle(SW() - 65, 25, 10, 35, rl.WHITE)
                rl.DrawRectangle(SW() - 42, 25, 10, 35, rl.WHITE)
            } else if t_mult >= 1 {
                for _ in 1..=t_mult do sym.update()
            } else if t_mult <= -2 {
                if skipped_frames == 0 {
                    sym.update()
                    skipped_frames = abs(t_mult)
                } else {
                    skipped_frames -= 1
                }
            }

            if t_mult != 1 {
                assert(t_mult != 0, "t_mult should not be zero.")
                text := rl.TextFormat("%dx", t_mult)
                if t_mult < 0 {
                    text = rl.TextFormat("1/%dx", -t_mult)
                }
                rl.DrawText(text, SW() - 65, 70, 20, rl.WHITE)
            }
        } else {
            {
                rl.BeginDrawing()
                defer rl.EndDrawing()
                rl.ClearBackground(rl.GetColor(0x151515FF))
                rl.DrawText("Rendering...", 100, 100, 20, rl.RED)
            }
            {
                rl.BeginTextureMode(render_tex)
                defer rl.EndTextureMode()
                sym.update()
            }

            img := rl.LoadImageFromTexture(render_tex.texture)
            // NOTE(mabay): In raylib, y increases downward and in videos, y increases upward
            rl.ImageFlipVertical(&img)
            ffmpeg_write(ffmpeg, img)

            if render_frames >= render_duration {
                rendering = false
                ffmpeg_end(ffmpeg)
                fmt.eprintln("Done writing to ffmpeg.")
                rl.SetTraceLogLevel(.INFO)
                break
            }
            render_frames += 1
        }
    }

    dynlib.unload_library(sym._dl_handle)
}

FFmpeg :: struct {
    process: os.Process,
    r_end, w_end, log_file: ^os.File,
}

ffmpeg_start :: proc(out_path: string, width, height: int, fps: int) -> FFmpeg {
    resolution := fmt.tprintf("%vx%v", width, height)
    frame_rate := fmt.tprint(fps)
    cmd_args := []string{
        "ffmpeg",

        "-loglevel", "verbose",
        "-y",

        "-f", "rawvideo",
        "-pix_fmt", "rgba",
        "-s", resolution,
        "-r", frame_rate,
        "-i", "-",

        "-c:v", "libx264",
        "-vb", "2500k",
        "-c:a", "aac",
        "-ab", "200k",
        "-pix_fmt", "yuv420p",
        out_path
    }

    log_file, open_err := os.open("tmp_ffmpeg.log", flags={.Read, .Write})
    assert(open_err == nil)
    r_end, w_end, pipe_err := os.pipe()
    assert(pipe_err == nil)
    process, start_err := os.process_start(os.Process_Desc {
        working_dir = "",
        command = cmd_args,
        stderr = log_file,
        stdout = log_file,
        stdin = r_end,
    })
    assert(start_err == nil)
    return FFmpeg {
        process = process,
        r_end = r_end,
        w_end = w_end,
        log_file = log_file,
    }
}

ffmpeg_end :: proc(ffmpeg: FFmpeg) {
    close_err := os.close(ffmpeg.w_end)
    assert(close_err == nil)
    state, wait_err := os.process_wait(ffmpeg.process, timeout=2*time.Second)
    assert(wait_err == nil, fmt.tprintf("wait_err = %v", wait_err))
    assert(state.success)
    close_err = os.close(ffmpeg.r_end)
    assert(close_err == nil)
}

ffmpeg_write :: proc(ffmpeg: FFmpeg, img: rl.Image) {
    assert(img.format == .UNCOMPRESSED_R8G8B8A8)
    stride :: 4
    img_size := int(img.width * img.height) * stride
    written_size, err := os.write_ptr(ffmpeg.w_end, img.data, img_size)
    assert(err == nil)
    assert(written_size == int(img_size))
}
