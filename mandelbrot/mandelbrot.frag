#version 450 core

uniform vec2 u_resolution;

out vec4 fragColor;

#define MAX_ITER 80
#define MAX_DIST 2.

float mandelbrot(vec2 p) {
    // z.x => real, z.y => imag
    vec2 z = vec2(0.);
    float temp = 0.;
    int i;
    for (i = 0; i < MAX_ITER; i++) {
        temp = z.x * z.x - z.y * z.y + p.x;
        z.y = 2 * z.x * z.y + p.y;
        z.x = temp;
        if (length(z) >= MAX_DIST) break;
    }
    return float(i) / float(MAX_ITER);
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    // Place origin at the center of the screen
    uv -= 0.5;
    // Aspect ratio fix
    uv.x *= u_resolution.x / u_resolution.y;
    // Scale axis length
    uv *= 4.;

    float x = mandelbrot(uv);
    if (x <= 0.8) {
        fragColor = vec4(x, 0.0, 0.0, 1.0);
    } else {
        fragColor = vec4(vec3(0.), 1.0);
    }
}