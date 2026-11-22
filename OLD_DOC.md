# myviz

Prelude moved to [README](./README.md)

## Builtin types
Some types naturally arise during visualizations; thus, those have to also be accounted
for.
- `boolean`
- `string`
- `float`
- `vec2`
- `vec3`
- `vec4`
- `color` (or `uvec4`)

Building these types into the language also makes it easy to define operators for them.
Only same type ops are defined (with minor exceptions); operations with different operand
types are treated as errors.
- boolean ops
    - `not`, `and`, `or`
- string ops
    - `+`: concat
    - `#`: length
    - `[]`: slices
- float ops
    - `+`, `-`, `*`, `/`, `%`, `^`
- vec2 ops
    - `+`, `-`, `*`
    - `||`: mag
    - `<`: angle
- vec{3,4} ops
    - `+`, `-`, `*`
    - `||`: mag
- uvec4 ops
    - None, so far

## Render
A render refer a sequence of scenes stitched together to produce a single video file.
Renders can be configured as follows:
- Dimensions (width, height)
- Format [png, mp4]
- Frame rate [24, 30, 60]

## Scene
A scene is, simply put, a collection of primitives with a sequence of actions performed on
them.

In the future, embedding a scene in another scene will be implemented.

## Primitives
A primitive is a fundamental building block with which larger primitives and
visualizations are constructed with. The fundamental primitives are:
- Point
- Line
- Arc
- Rect
- Circle

Regardless of the primitive type, all of them have the following common properties:
- Position: (vec2)
- Rotation: (float)
- Fill: (color)
- Stroke: (color)
- (OPTIONAL) Primitive-type specific data
    - Size
    - Vertex offsets, etc.

## Actions
An action refers to an time-based interpolation of a given property (or properties). The
duration of an action is either specified via a frame index or seconds. Either one is
equally as valid since the frame rate serves as a conversion factor between them. Much
like primitives, there are fundamental actions:
- Move
- Blend
- Scale
- Rotate

Each of the fundamental or composed actions require a starting, ending value, and a
duration. However, each action is free to specify its own types for actions.

## Units
When specifying the location or size of some object, absolute or relative units can be
used. Restricting users to a single type of unit does not make practical sense since the
user will end up having to recreate the other when limited to one. Thus, both unit types
will be built into the language. A good example of this idea can be found in the
[typst](https://typst.app/) typsetting language.
- Absolute units
    - Length
        - `px`: pixels
        - `cm`: centimeters
    - Angle
        - `deg`: degrees
        - `rad`: radians
    - Time
        - `s`: seconds
        - `f`: frames
- Relative units
    - Length
        - `vw`: viewport width
        - `vh`: viewport height
    - `%`: percentage of parent's value

## Manual manipulation
Sometimes, it is just easier to manually go through every single pixel and decide what its
color should be. Therefore, manual pixel manipulations should be trivial to work with.
This means fetching and updating the current state of frame's pixel array should be made
trivial. (I got this idea from Processing; I hadn't thought about it before.)

## Runtime values
Sometimes placing and sizing certain elements is very tedious to do strictly through code,
which is where graphical applications shine the brightest. However, I do not wish to
abandon the benefits of coding to create visuals. Serving as a middle ground, runtime
values allow the user to specify values that will be assigned to variables prior to
playing through the visualization. By doing so, the user gets the best of worlds: setting
the scene through the UI and animating it through code. (I stole this idea from [motion
canvas](https://motioncanvas.io/))

However, the benefits of runtime values are not limited to only organizing a scene; they
provide the user with a clean, simple way to influence a visualization. For instance, a
user could define a runtime value for a mandlebrot visualization and control the focus
point of the visuals being produced. These kinds of interactions have largely been limited
to keyboard and mouse events. While usuable without, runtime variables seek to provide an
additional level of interactivity with the visuals.

The values set from a given run will be saved and reused for later runs of the same
visuals. The changing of the original script does not invalidate runtime values created
before.

## Sample
```
color red = {200, 10, 10};

scene simple_test {
    rect r1 = {@r1pos, {100, 100}};
    circle c1 = {100, 100, @c1rad};

    move c1 {100, 100};
    play 1s + 100f;

    fade c1 red;
    play 2s - 20f;
}

scene conditional {
    rect r1 = {100, 100, 100, 100};
    if |r1.position| > 20 {
        // Do something here
    }
}
```