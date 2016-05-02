---
title: "Weep for Graphics Programming"
excerpt: |
    I was recently introduced to real-time 3D rendering with OpenGL. It was awful. This post describes what went wrong for a language-inclined, graphics-ignorant audience.
highlight: true
---
The mainstream real-time graphics APIs, OpenGL and Direct3D, are probably the most widespread way that programmers interact with heterogeneous hardware.
But their brand of CPU--GPU integration is unconscionable.
CPU-side code needs to coordinate closely with GPU-side *shader programs* for good performance, but the APIs we have today treat the two execution units as separate universes.
This approach leads to stringly typed interfaces, a huge volume of boilerplate, and impoverished GPU-specific programming languages.

This post tours a few gritty realities in a tiny OpenGL application.
You can follow along with [a literate listing][tinygl-rendered] of the full [source code][tinygl].

[tinygl-rendered]: http://sampsyo.github.io/tinygl/
[tinygl]: https://github.com/sampsyo/tinygl/blob/master/tinygl.c


## Shaders are Strings

To define an object's appearance in a 3D scene, real-time graphics applications use *[shaders][shader]:* small programs that run on the GPU as part of the rendering pipeline.
There are several kinds of shaders, but the two most common kinds are [vertex shaders][vtx], which produce the position of each vertex in an object's mesh, and [fragment shaders][frag], which decide the color of each pixel on the object's surface.
You write shaders in special C-like programming languages: GLSL uses [GLSL][].

This is where things go wrong: to set up a shader, the host program sends a *string containing shader source code* to the graphics card driver.
The driver JITs the source to the GPU's internal architecture and loads it onto the hardware.

Here's a simplified pair of GLSL [vertex and fragment shaders in C string constants][tgl-shaders]
(it's also common to load shader code from text files at startup time):

```c
const char *vertex_shader =
  "in vec4 position;\n"
  "out vec4 myPos;\n"
  "void main() {\n"
  "  myPos = position;\n"
  "  gl_Position = position;\n"
  "}\n";

const char *fragment_shader =
  "uniform float phase;\n"
  "in vec4 myPos;\n"
  "void main() {\n"
  "  gl_FragColor = ...;\n"
  "}\n";
```

Those [`in`, `out`, and `uniform` qualifiers][qualifiers] denote communication channels between the CPU and GPU and between the different stages of the GPU's rendering pipeline.
The vertex shader's `main` function assigns to the magic `gl_Position` variable for its output, and the fragment shader assigns to `gl_FragColor`.

Here's roughly how you [compile and load the shader program][tgl-compile]:

```c
// Compile the vertex shader.
GLuint vshader = glCreateShader(GL_VERTEX_SHADER);
glShaderSource(vshader, 1, &vertex_shader, 0);

// Compile the fragment shader.
GLuint fshader = glCreateShader(GL_FRAGMENT_SHADER);
glShaderSource(fshader, 1, &fragment_shader, 0);

// Create a program that stitches the two shader stages together.
GLuint shader_program = glCreateProgram();
glAttachShader(shader_program, vshader);
glAttachShader(shader_program, fshader);
glLinkProgram(shader_program);
```

With that boilerplate, we're ready to invoke `shader_program` to draw objects.

The shaders-in-strings interface is the original sin of graphics programming.
It means that part of the complete program's semantics are unknowable until run time---for no reason except that it runs on a different kind of hardware.
It's like [`eval` in JavaScript][eval], but worse: every OpenGL program is *required* to cram some of its code into strings.

The next generation of graphics APIs---[Mantle][], [Metal][], and [Vulkan][]---clean up some of the mess by using a bytecode to ship shaders instead of raw source code.
(Direct3D already uses a bytecode.)
But pre-compiling shader programs is only cosmetic; it doesn't solve the fundamental problem:
the *interface* between the CPU and GPU code is purely dynamic, so you can't reason statically about the whole, heterogeneous program.

[glsl]: https://www.opengl.org/documentation/glsl/
[shader]: https://en.wikipedia.org/wiki/Shader
[hlsl]: https://msdn.microsoft.com/en-us/library/windows/desktop/bb509561(v=vs.85).aspx
[eval]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/eval
[vtx]: https://www.opengl.org/wiki/Vertex_Shader
[frag]: https://www.opengl.org/wiki/Fragment_Shader
[qualifiers]: https://www.opengl.org/wiki/Type_Qualifier_(GLSL)
[vulkan]: https://www.khronos.org/vulkan/
[mantle]: http://www.amd.com/en-us/innovations/software-technologies/technologies-gaming/mantle
[metal]: https://developer.apple.com/metal/

[tgl-shaders]: http://sampsyo.github.io/tinygl/#section-7
[tgl-compile]: http://sampsyo.github.io/tinygl/#section-18


## Stringly Typed Binding Boilerplate

If string-wrapped shader code is OpenGL's initial investment in pain,
then it collects fantastic pain dividends in the CPU--GPU communication interface.
Check out those variables `position` and `phase` in the vertex and fragment shaders, respectively.
The `in` and `uniform` qualifiers mean they're parameters that come from the CPU.

To use those parameters, the first step is to [look up *location* handles][tgl-locs] for each variable:

```c
GLuint loc_phase = glGetUniformLocation(program, "phase");
GLuint loc_position = glGetAttribLocation(program, "position");
```

Yes, you look up the variable using its name as a string.
The `phase` parameter is just a `float` scalar, but `position` is an array of position vectors, so it requires even more boilerplate, which I won't show here, to [set up a backing buffer][tgl-buffer].

Then, we need to use these handles to [pass new data to the shaders][tgl-pass] to draw each frame:

```c
// The render loop draws each frame.
while (1) {
  // Set the scalar `phase` variable.
  glUniform1f(loc_phase, sin(4 * t));

  // Set the `location` array by copying data into the buffer.
  glBindBuffer(GL_ARRAY_BUFFER, buffer);
  glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(points), points);

  // Use these parameters and our shader program to draw something.
  glUseProgram(shader_program);
  glDrawArrays(GL_TRIANGLE_FAN, 0, NVERTICES);
}
```

The [verbosity][tgl-pass] is distracting, but those [`glUniform1f`][glUniform] and [`glBufferSubData`][glBufferSubData] calls are morally equivalent to
writing `set("variable", value)` instead of `let variable = value`.
The C and GLSL compilers can check and optimize the CPU and GPU code separately,
but the stringly typed CPU--GPU interface prevents either compiler from doing anything useful to the complete program.

[tgl-locs]: http://sampsyo.github.io/tinygl/#section-28
[tgl-buffer]: http://sampsyo.github.io/tinygl/#section-34
[tgl-pass]: http://sampsyo.github.io/tinygl/#section-42
[glBufferSubData]: https://www.opengl.org/sdk/docs/man2/xhtml/glBufferSubData.xml
[glUniform]: https://www.khronos.org/opengles/sdk/docs/man/xhtml/glUniform.xml


## The Age of Heterogeneity Deserves Better

Heterogeneity is rapidly becoming ubiquitous, and we need better ways to write software that spans hardware units with different capabilities.
But OpenGL and its equivalents make miserable standard bearers for the age of hardware heterogeneity.
Its programming model espouses the simplistic view that heterogeneous software should comprise multiple, loosely coupled, independent programs.
We need to bury this 20th-century notion.
If pervasive heterogeneity is going to succeed, we need programming models with *one* program that spans execution contexts.
This won't make the essential complexity of heterogeneity disappear, but it will let us stop treating non-CPU code as a second-class citizen.
