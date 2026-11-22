package utils


Anim_Func :: proc(t: f32)
Anim :: struct {
    func: Anim_Func,
    duration: int,
    start_frame: int,
}

anim :: proc(func: Anim_Func, duration: int, start_frame := -1) -> Anim {
    return {
        func = func,
        duration = duration,
        start_frame = start_frame
    }
}

Anims :: struct {
    items: [dynamic]Anim,
    index: int,
}

anims_init :: proc(a: ^Anims, args: ..Anim) {
    if cap(a.items) == 0 {
        a^ = Anims{
            items = make([dynamic]Anim),
            index = 0
        }
    } else do clear(&a.items)
    append(&a.items, ..args)

    // Compute the start frame index
    total := int(0)
    for &anim in a.items {
        anim.start_frame = total
        total += anim.duration
    }
}

anims_update :: proc(a: ^Anims, frames: int) {
    if a.index >= len(a.items) {
        a.items[len(a.items)-1].func(1.0)
        return
    }

    anim := &a.items[a.index]
    t := f32(frames - anim.start_frame) / f32(anim.duration)
    if 0 <= t && t <= 1 {
        anim.func(t)
        if t == 1.0 do a.index += 1
    }
}