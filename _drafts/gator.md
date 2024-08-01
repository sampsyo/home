---
title: Geometry Bugs and Geometry Types
mathjax: true
---
<figure style="width: 350px">
  <canvas width="350" height="350" id="diffuse-correct"></canvas>
  <figcaption>The diffuse component of the classic <a href="https://en.wikipedia.org/wiki/Phong_reflection_model">Phong lighting model</a>, implemented (probably) correctly.</figcaption>
</figure>

The ubiquitous [Phong lighting model][phong] has three parts:
some uniform ambient lighting,
a *diffuse* component that looks the same from any angle,
and a *specular* component that adds shiny highlights for direct reflections.

Let's try to implement just the diffuse component.
It's supposed to look like this bunny here.
The idea is to compute the [Lambertian reflectance][lambertian].
At every point on the surface of the object, it's the dot product between the surface's normal vector and the direction from that point to the light source:

$$\mathit{lambertian} = \mathsf{max}(\mathit{lightDir}\cdot\mathit{fragNorm}, 0)$$

We're implementing this in a [fragment shader][frag], so that
$fragNorm$ is the normal vector for a given point in space that we're rendering.
We can get $lightDir$ by normalizing the difference between the current fragment position and some absolute position of the light source:

$$\mathit{lightDir} = \mathsf{normalize}(\mathit{lightPos} - \mathit{fragPos})$$

Here's a direct translation of all that into [GLSL][]:

```glsl
vec3 lightDir = normalize(uLightPos - vPosition);
float lambertian = max(dot(lightDir, vNormal), 0.0);
gl_FragColor = vec4(lambertian * uDiffColor, 1.0);
```

We've set this fragment shader up so it gets its inputs, `uLightPos`, `vPosition`, and `vNormal`, from the CPU.
To finish it off, we multiply the Lambertian reflectance magnitude by an RGB color we've chosen for our light and, finally, use `vec4(..., 1.0)` to set the [alpha channel][alpha] to 1.

<figure style="width: 350px">
  <canvas width="350" height="350" id="diffuse-naive"></canvas>
  <figcaption>What happens if you try to implement that diffuse lighting by translating the math 1-1 into GLSL.</figcaption>
</figure>

This shader looks right, but it is incorrect.
The bunny looks like this: the shading seems mostly right, but the invisible light seems to be rotating along with the model instead of staying put.
The math is right, but it has a *geometry bug*.
The problem is that TK

[phong]: https://en.wikipedia.org/wiki/Phong_reflection_model
[lambertian]: https://en.wikipedia.org/wiki/Lambertian_reflectance
[frag]: https://www.khronos.org/opengl/wiki/Fragment_Shader
[alpha]: https://en.wikipedia.org/wiki/Alpha_compositing
[glsl]: https://developer.mozilla.org/en-US/docs/Games/Techniques/3D_on_the_web/GLSL_Shaders

<script src="{{site.base}}/media/gator/main.js"></script>
