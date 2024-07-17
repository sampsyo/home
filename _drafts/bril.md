---
title: "Bril: An Intermediate Language for Teaching Compilers"
---
I created a new "advanced compilers" course for PhD students, called CS 6120, a few years ago.
The organizing principle is a focus on the "middle end," defined broadly:
analysis and optimization, but also runtime services, verification, synthesis, JITs, and so on;
but not lexing, parsing, semantic analysis, register allocation, or instruction selection.
That latter stuff is all cool, but you have to sacrifice something for a coherent focus.

This post is about Bril (the Big Red Intermediate Language), a new compiler intermediate representation I made to embody this focus.
Bril is the only compiler IL I know of that is specifically designed for education.
Focusing on teaching means that Bril prioritizes these goals:

* It is fast to get started working with the IL.
* It is easy to mix and match components that work with the IL, including things that fellow students write.
* It has simple semantics without too many distractions.

Bril is different from other ILs because it ranks those goals above other, more typical goals for an IL:
notably, performance (both of the compiler itself and the code that the compiler generates).

TK other than that, it takes a lot of inspiration from other ILs out there, notably, LLVM IR.
There's a quote from why the lucky stiff where he introduces [Camping][], the original web microframework, as "a little white blood cell in the vein of Rails."
If Bril is a single blood cell, LLVM is an entire circulatory system.

[camping]: https://camping.github.io/camping.io/

---

TK next level of principles:

* JSON is the canonical form. no library required
    * text format is available if you want
* tools are unix commands. so composition works with files & pipes
* not SSA, but with an SSA variant
    * there is an SSA form, but... it is not great (we should do something about that). this goal turns out to have been the hardest to meet
