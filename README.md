# myviz

This project is my attempt at replacing what [Processing](https://processing.org/) can do
for me. Processing is great at providing a wide array of basic primitives such that I can
just start visualizing whatever I find interesting at the moment. Everything from
manipulating the individual pixels to drawing primitive shapes to loading custom shaders
is a such a trivial thing to do in Processing. However, I don't really like the
surrounding 'architecture', so to speak; the need to depend on Java appears to be more of
a historical constraint for Processing. I believe that one could achieve feature parity
(or even better) without having to rely on Java. The main benefit of using Java, in my
eyes, is the fact that it allows for static type checking, which eliminates the
"you-will-find-out-if-your-script-works-at-runtime" style of iterating on a given
visualization (a process very familiar for people that used
[manim](https://github.com/3b1b/manim)).

For me, the benefit I get from using something like Processing is the fact that I can
explore interesting geometric or fractal visualizations in a rather simple, expressive
manner. With that said, Processing's dependency on Java is a rather critical issue for
me. Trying to run my Processing scripts through its CLI is unbearable. So, the
question is: "Can I replicate the benefits of Processing without having to depend on
something like Java?" (Answer should be obvious, given the existence of this project)

**Objective**: Develop a simple CLI program that can process a 2D visualization script and
immediately start visualizing it. Below are some requirements to consider this project a
success (in order of importance):
- Statically typed scripting language
- Minimal startup time (as close to instant as possible)
- Comprehensive set of primitives and animations
- Extensible system (hopefully without an OOP-like system)
- Runtime REPL

> [!NOTE]
> The ideas listed in `OLD_DOC.md` are features I want to have implemented in my
> visualizer; however, the ideas there were written to serve as a guide for me as I tried
> to implement a domain-specific scripting language for this visualizer, which I am no
> longer pursuing.

## Quickstart
```
$ ./build_plug.sh rlogo/
$ vizmain/run.sh rlogo.so
```

## Other resources
Below are tools I have tried/looked into before embarking on this journey:
- [Processing](https://processing.org/)
- [manim](https://github.com/3b1b/manim)
- [Motion Canvas](https://motioncanvas.io/)