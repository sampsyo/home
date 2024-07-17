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

## Bril is JSON

TK next level of principles, all interrelated

* students can use any programming language they want
* no library/framework required
* tools are unix commands. so composition works with files & pipes

so, JSON is the canonical form. no library required.
text format is available if you want, but it is only for human foibles

show the actual syntax off

## TK the available tools

draw a graph of all the stuff?
definitely link to the cool web playground

highlight things that people have built. distinguish the extremely tiny set of tools we started with, and where we are at now (in the monorepo and beyond).

## downsides/future work?

* not SSA, but with an SSA variant. this is important so (1) students can feel the pain of working with non-SSA programs, and (2) so that they an implement the to-SSA/from-SSA passes as an assignment, and (3) makes it easy to emit from frontends that have mutation *without needing memory in the IL*
    * there is an SSA form, but... it is not great (we should do something about that). this goal turns out to have been the hardest to meet
    * maybe switch to BB arguments, for a more radical departure in the SSA form? I think a lot of the complexity/bugs come from trying to treat SSA as just a small tweak on the non-SSA base language
