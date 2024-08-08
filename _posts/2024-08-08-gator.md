---
title: Geometry Bugs and Geometry Types
mathjax: true
tail: |
    <script src="BASE/media/gator/main.js"></script>
excerpt: |
    A special kind of bug exists in code that has to deal with geometric concepts like positions, directions, coordinate systems, and all that.
    Long ago, in [an OOPSLA 2020 paper][gator-paper], we defined *geometry bugs* and designed a [type system][gator] to catch them.
    This post demonstrates the idea through some buggy [GLSL][] shaders.

    [gator-paper]: https://dl.acm.org/doi/10.1145/3428241
    [gator]: https://github.com/cucapra/gator
    [glsl]: https://developer.mozilla.org/en-US/docs/Games/Techniques/3D_on_the_web/GLSL_Shaders
---
<figure style="width: 350px">
  <canvas width="350" height="350" id="diffuse-correct"></canvas>
  <figcaption>The diffuse component of the classic <a href="https://en.wikipedia.org/wiki/Phong_reflection_model">Phong lighting model</a>, implemented (probably) correctly.</figcaption>
</figure>

The [Phong lighting model][phong] is the "hello world" of 3D rasterization effects.
Implementing it seems like an appropriate level of challenge for me, a total graphics neophyte.
Even a textbook rendering effect, however, entails some geometric thinking that in turn creates the possibility for its own special category of bug.
Let's follow our nose and run into some geometry bugs.

Phong lighting has three parts:
some uniform *ambient* lighting,
a *diffuse* component that looks the same from any angle,
and a *specular* component that adds shiny highlights for direct reflections.
To make things even easier, let's try to implement just the diffuse component.
It's supposed to look like this bunny here.

The idea is to compute the [Lambertian reflectance][lambertian].
At every point on the surface of the object, it's the dot product between the surface's normal vector and the direction from that point to the light source:

$$\mathit{lambertian} = \mathsf{max}(\mathit{lightDir}\cdot\mathit{fragNorm}, 0)$$

That $\mathsf{max}$ helps us ignore light coming from behind the rabbit's surface.
We're implementing this in a [fragment shader][frag], so that
$\mathit{fragNorm}$ is the normal vector for a given point on the triangle that we're rendering.
We can get $\mathit{lightDir}$ by normalizing the difference between the current fragment position and some absolute position of the light source:

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

This shader is incorrect.
The bunny looks like this: the shading seems mostly right, but the invisible light seems to be rotating along with the model instead of staying put.

The math is right, but the code has a *geometry bug*.
The problem is that, when you translate geometric math into rendering code, you have to represent the abstract vectors as concrete tuples of floating-point numbers.
When the math's $\mathit{fragPos}$ becomes the shader's `vPosition`, we need to decide on its *reference frame:*
will it be local coordinates relative to the bunny itself,
relative to the camera,
or using some absolute coordinates for the whole scene?
We also need to pick a coordinate system, like
ordinary Cartesian coordinates, polar coordinates, or the more graphics-specific system of [homogeneous coordinates][hom].

The real problem here is that none of these choices show up in the type system.
In GLSL, all our vectors are [`vec3`s][glsl-type].
There are several different reference frames at work here, but none of them show up in the programming language.
GLSL is perfectly happy to add and subtract vectors that use completely different representations, yielding meaningless results.

This post will walk through fixing the implementation of this math.
It's written for people who don't know much about graphics or geometry, i.e., people like me.
The goal here is to convince you that this kind of programming needs a type system.

## Managing Reference Frames

<figure style="max-width: 300px">
  <img src="{{site.base}}/media/gator/spaces.svg" class="bonw"
    alt="A 2D artist's interpretation of the model, world, and view reference frames in graphics rendering.">
  <figcaption>Rendering a whole scene usually involves several <em>model</em> reference frames, a fixed <em>world</em> frame, and a <em>view</em> frame for the camera's perspective.</figcaption>
</figure>

The first thing that's wrong is that our vectors are in different reference frames.
It's useful to imagine a single, fixed *world* frame that contains the entire scene:
here, both our bunny and our light source.
The geometric data describing individual objects arrives each object's own individual *model* reference frame.
When you download the [`.obj` file][obj] for the [Stanford bunny][bunny], it doesn't know about your renderer's world frame:
the vertex positions and surface normals have to come represented in an intrinsic bunny-specific space.

In our little shader, `vPosition` and `vNormal` are vectors in the bunny's model frame while `uLightPos` is a point in world space.
So the subtraction `uLightPos - vPosition` doesn't yield a geometrically meaningful vector,
and we should probably be careful about that `dot(lightDir, vNormal)` too.

Renderers use transformation matrices to convert between reference frames.
Let's suppose that we have a `uModel` matrix that transforms bunny space to world space.
Then the GLSL we need should look something like this:

```glsl
vec3 lightDir = normalize(uLightPos - uModel * vPosition);
float lambertian = max(dot(lightDir, uModel * vNormal), 0.0);
```

With all our vectors converted to the common (world) reference frame, these operations should mean something!

However, in realistic renderers, the `uModel` transformation will actually be a `mat4`, not a `mat3`.
The reason has to do with affine transformations and coordinate systems---we'll address that next.

[obj]: https://en.wikipedia.org/wiki/Wavefront_.obj_file
[bunny]: https://faculty.cc.gatech.edu/~turk/bunny/bunny.html

## Converting Coordinate Systems

In 3-dimensional space, a square 3&times;3 matrix is a nice way to represent *linear* transformations:
rotations, scaling, shearing, all that.
But renderers typically also want to do translation, which requires generalizing to *affine* transformations.
You can't represent those in a 3&times;3 matrix, so what can we do?

The usual way is to use [homogeneous coordinates][hom].
Where ordinary Cartesian coordinates represent a point in 3-space using a GLSL `vec3`, homogeneous coordinates use a `vec4`.
The extra coordinate is a scaling factor, so the 4-tuple $[x, y, z, w]$ represents the point at $[x/w, y/w, z/w]$.
Transformation matrices are `mat4`s that can represent the full range of affine transformations in 3-dimensional space.

In our example (and in any typical renderer setup),
`vPosition` and `vNormal` come to us in Cartesian coordinates (i.e., GLSL `vec3`s)
and the `uModel` transformation matrix comes in homogeneous coordinates (i.e., a `mat4`).
To fix our transformation expression `uModel * vPosition`, we'll need something like this:

```glsl
vec4 posWorldHom = uModel * vec4(vPosition, 1.0);
vec3 posWorldCart = vec3(posWorldHom / posWorldHom.w);
```

<figure style="width: 350px">
  <canvas width="350" height="350" id="diffuse-alltrans"></canvas>
  <figcaption>The same shader after applying the same coordinate-system juggling to both input vectors. (Particularly mysterious in dark mode.)</figcaption>
</figure>

We convert `vPosition` to homogeneous coordinates by tacking on a scaling factor $w=1$,
transform with `uModel`,
and then convert back to Cartesian coordinates by dividing by $w$ again.

With this, we finally have our vertex position in world reference frame.
Let's try repeating exactly the same process with `vNormal`, the other model-space vector involved in our computation.
Sadly, something's still very wrong---in fact, the bunny somehow looks every worse than it did before.
<span class="dark-only">
If you're viewing this page in dark mode, it may not be visible at all.
</span>

The problem now is that, while the code we wrote to juggle homogeneous coordinates for `vPosition` is correct,
the same treatment doesn't work for `vNormal`.
The reason has to do with the different kinds of geometric objects that these variables represent.

## Kinds of Geometric Objects

Yet again, we've been bitten by a geometric concept that remains invisible in the GLSL code.
There's an important difference between `vPosition` and `vNormal`: both are 3-dimensional Cartesian vectors,
but one represents a *position* while the other is just a *direction*.
These might seem like the same thing: what is a direction other than a unit-magnitude position?

<figure style="max-width: 350px">
  <img src="{{site.base}}/media/gator/translation.svg" class="bonw"
    alt="Two reference frames, one a translation of the other. There is a point and a direction in each. The point gets translated; the direction stays the same.">
  <figcaption>We want reference-frame translations to affect positions but not directions.</figcaption>
</figure>

The distinction matters when we convert between reference frames.
Remember that our homogeneous-coordinates transformation matrix `uModel` can encode a translation (in addition to rotation and scaling and all that).
We absolutely want to translate positions when going from the model frame to the world frame,
but *we do not want to translate directions*.
When you shift a reference frame over some distance, all the points should move, but directions stay pointing in the same direction---they should not get shifted over by the same amount.

Homogeneous coordinates have a trick to deal with positions.
If you set their scaling factor, $w$, to zero, then transformation matrices will treat them correctly: they'll apply all the linear transformations and none of the (affine) translation.
Then, to convert back to Cartesian coordinates, we have to ignore $w$ to avoid dividing by zero.
Here's how it looks in GLSL:

```glsl
vec3 normWorld = normalize(vec3(uModel * vec4(vNormal, 0.0)));
```

The key thing to notice is that Cartesian/homogeneous conversion needs to work differently for positions and directions.
So programmers have to keep track of the different kinds of geometric objects they're dealing with in their heads.

## The Correct Shader

Here's a complete version of the correct shader:

```glsl
// lightDir = normalize(lightPos - fragPos)
vec4 posWorldHom = uModel * vec4(vPosition, 1.0);
vec3 posWorldCart = vec3(posWorldHom / posWorldHom.w);
vec3 lightDir = normalize(uLightPos - posWorldCart);

// lambertian = max(dot(lightDir, fragNorm), 0)
vec3 normWorld = normalize(vec3(uModel * vec4(vNormal, 0.0)));
float lambertian = max(dot(lightDir, normWorld), 0.0);

gl_FragColor = vec4(lambertian * uDiffColor, 1.0);
```

This shader produces the bunny at the top of this post.

## Geometry Types

At [OOPSLA 2020][], [Prof. Dietrich Geisler][dietrich] published [a paper][gator-paper] about geometry bugs
and a type system that can catch them.
The idea hasn't exactly taken over the world, and I wish it would.
The paper's core insight is that, to do a good job with this kind of type system, you need your types to encode three pieces of information:

* the reference frame (like model, world, or view space)
* the coordinate scheme (like Cartesian, homogeneous, or polar coordinates)
* the geometric object (like positions and directions)

In Dietrich's language, these types are spelled `scheme<frame>.object`.
Dietrich implemented these types in a language called [Gator][] with help from [Irene Yoon][irene], [Aditi Kabra][aditi], [Horace He][horace], and Yinnon Sanders.
With a few helper functions, you can get Gator to help you catch all the geometric pitfalls we saw in this post.
Here's a version of our shader in Gator:

```glsl
cart3<world>.point posWorld = hom_reduce(uModel * homify(vPosition));
cart3<world>.vector lightDir = normalize(uLightPos - posWorld);

cart3<world>.direction normalWorld = normalize(hom_reduce(uModel * homify(vNormal)));
scalar lambertian = max(dot(lightDir, normalWorld), 0.0);
```

The standard library comes with overloaded `homify` and `hom_reduce` functions that do the right thing when converting a given geometric object between coordinate systems.
Gator also distinguishes `vector` from `direction`, which is a subtype that is guaranteed to have unit magnitude.
If you forget a transformation or conversion, Gator will report a type error.

With geometry baked into the type system, we can also go one step farther and automatically generate the transformation code.
Gator supports an `in` expression that searches for a transformation from one reference frame or coordinate system to another.
For example, if we mark `uModel` as the *canonical* transformation from model space to world space, then `in world` suffices to manage both the reference-frame change and the detour through homogeneous coordinates:

```glsl
auto lightDir = normalize(uLightPos - (vPosition in world));
scalar lambertian = max(dot(lightDir, normalize(vNormal in world)), 0.0);
```

We at last have a version of the shader that looks kind of like the math.

I know the world of [shading languages][sl] is not exactly a hotbed of rapid innovation these days.
Even so, I think geometry types are a pretty good idea and I hope that some future generation of rendering systems borrows an idea or two from Gator.

[phong]: https://en.wikipedia.org/wiki/Phong_reflection_model
[lambertian]: https://en.wikipedia.org/wiki/Lambertian_reflectance
[frag]: https://www.khronos.org/opengl/wiki/Fragment_Shader
[alpha]: https://en.wikipedia.org/wiki/Alpha_compositing
[glsl]: https://developer.mozilla.org/en-US/docs/Games/Techniques/3D_on_the_web/GLSL_Shaders
[hom]: https://en.wikipedia.org/wiki/Homogeneous_coordinates
[gator-paper]: https://dl.acm.org/doi/10.1145/3428241
[gator]: https://github.com/cucapra/gator
[oopsla 2020]: https://2020.splashcon.org/track/splash-2020-oopsla
[sl]: https://en.wikipedia.org/wiki/Shading_language
[dietrich]: https://www.cs.cornell.edu/~dgeisler/
[irene]: https://www.cis.upenn.edu/~euisuny/
[aditi]: https://aditink.github.io
[horace]: https://horace.io
[glsl-type]: https://www.khronos.org/opengl/wiki/Data_Type_(GLSL)
