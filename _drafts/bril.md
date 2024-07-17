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
