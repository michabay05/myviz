# myviz TODOs

TODOs:
- [ ] (vizmain) Add FFMPEG rendering
- [ ] (vizmain) Make debug previews (enable and disable)-able
    - Things like current FPS, dt multiplier, paused
- [ ] (vizmain) Provide timeline bar
    - Mostly to customize the duration of animations
- [ ] (vizmain) Change vizmain's keymap domain
    - It should not take up common keymaps; it should map things like the function keys,
      ctrl+<SOME_OTHER_KEY>, etc.
- [ ] (plugs) Implement a non-trivial 3D visualization
    - I don't really know what, for now

v0.1:
- [x] (plugs) Implement mandelbrot visualization
- [x] (plugs) Implement the raylib logo animation
    - Source: https://github.com/raysan5/raylib/
    - Dir: examples/shapes/shapes_logo_raylib_anim.c
- [x] (plugs) Individual anim funcs should not know anything about their duration
    - Anim funcs should get a normalized time value: $t \in [0, 1]$

