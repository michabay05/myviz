# myviz TODOs

TODOs:
- [ ] (feat) Make debug previews (enable and disable)-able
    - Things like current FPS, dt multiplier, paused
- [ ] (feat) Provide timeline bar
    - Mostly to customize the duration of animations
- [ ] (fix) Change vizmain's keymap domain
    - It should not take up common keymaps; it should map things like the function keys,
      ctrl+<SOME_OTHER_KEY>, etc.
- [ ] (fix) Remove plug update's knowledge of the frame dt
    - It should operate based on frame indices
- [ ] (feat) Make DLL selectable on startup (if cmd args are not specified)
    - This would imply that the cmd args pertaining to DLL path is optional.
- [ ] (feat) Implement a non-trivial 3D visualization (I don't really know what, for now)
    - This should involve a 3D camera animation
- [ ] (feat) Come up with a good way to work with absolute/relative units
- [ ] (feat) Provide basic positioning utilities
    - [ ] Placement
    - [ ] Alignment
- [ ] (feat) Plugins should have the ability to decide the output video's params
    - Params include (but are not limited to) video dimensions, fps, etc.
    - One mechanims is to make the user return a `Video_Config` structure containing all
      relevant info about the target video on the setup function.
- [ ] (feat) Add a 2D camera animation to the `rect_ease` anim
    - [ ] Translation
    - [ ] Rotation
    - [ ] Zoom

v0.1:
- [x] (feat) Add FFMPEG rendering
    - [x] Save info logged by ffmpeg into `stdout` and `stderr` instead of ignoring
- [x] (feat) Implement raylib's "easing rectangles" anim
    - Source: https://github.com/raysan5/raylib/tree/4b0c5962dda6ca2b473fe81254e6027c84714b51
    - Dir: examples/shapes/shapes_easings_rectangles.c
- [x] (refactor) Move animation system into utils
- [x] (feat) Implement mandelbrot visualization
- [x] (feat) Implement the raylib logo animation
    - Source: https://github.com/raysan5/raylib/tree/4b0c5962dda6ca2b473fe81254e6027c84714b51
    - Dir: examples/shapes/shapes_logo_raylib_anim.c
- [x] (feat) Individual anim funcs should not know anything about their duration
    - Anim funcs should get a normalized time value: $t \in [0, 1]$

