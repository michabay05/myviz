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
- [ ] (vizmain) Make DLL selectable on startup (if cmd args are not specified)
    - This would imply that the cmd args pertaining to DLL path is optional.
- [ ] (plugs) Implement a non-trivial 3D visualization
    - I don't really know what, for now
- [ ] (utils) Come up with a good way to work with absolute/relative units
- [ ] (utils) Provide basic positioning utilities
    - [ ] Placement
    - [ ] Alignment

v0.1:
- [x] (utils) Move animation system into utils
- [x] (plugs) Implement mandelbrot visualization
- [x] (plugs) Implement the raylib logo animation
    - Source: https://github.com/raysan5/raylib/
    - Dir: examples/shapes/shapes_logo_raylib_anim.c
- [x] (plugs) Individual anim funcs should not know anything about their duration
    - Anim funcs should get a normalized time value: $t \in [0, 1]$

