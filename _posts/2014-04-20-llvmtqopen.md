---
layout: post
title: Developing a Research Tool in the Open
excerpt: |
    As an experiment in open-sourcing research code earlier and often-er than I usually do, I'm developing a [new compiler tool][llvmtq] in the open. It's a system for defining and checking user-specified type systems in C and C++ via the [Clang][] compiler.

    [llvmtq]: https://github.com/sampsyo/llvm-tq
    [Clang]: http://clang.llvm.org/
---
So far in grad school, "research code" has been something I developed in isolation. When the legal stars align, I get to [release associated code][codepost] after a paper is published.

[codepost]: {{ site.base }}/blog/sociallicenses.html

This boring, secretive approach to research development is defensible when building one-off prototypes that are mostly useless to anyone without an accompanying paper. It also makes sense to keep ideas secret when there's a real danger of getting scooped.

In architecture research, the old rules do usually apply: nobody wants to use your [SESC][] patches and making them public will only divulge your design proposal. 
But research code doesn't always have to be hacky and sensitive.
More practically-minded research areas tend to produce legitimately useful software and therefore have a stronger ethic of developing in the open.

[SESC]: http://iacoma.cs.uiuc.edu/~paulsack/sescdoc/

For an ongoing project, I've found myself needing a set of research tools that seem legitimately useful. I've tried implementing the tool as a series of horrible, one-off hacks (four different times!), but it's come time to get serious about building something solid.

So with [this project][llvmtq], I'm going to experiment with developing the tool in the open. My overly-ambitious hopes are that:

* A public development process will encourage me to write better code. If other people could---in principle!---be looking over my GitHub shoulder, maybe I will cut fewer corners.
* No release overhead. I don't have to put a version stamp on this code for it to be useful immediately; other researchers can fork and put the tool to use immediately whenever it becomes useful.
* Collaboration. I can take feedback about where the project should go rather than building in [cathedral-style][catb] isolation.

[catb]: http://www.catb.org/esr/writings/cathedral-bazaar/

I'll post to this blog more as the project develops, but here's what this tool actually does.

## Extensible Type Qualifiers for Clang and LLVM

You're probably familiar with type qualifiers---they're those extra bits that can be attached to any type in your favorite mainstream programming language. Think `const`, `final`, and `volatile` in C or Java.

Usually, a language or a compiler has a fixed set of qualifiers. Users can't define new ones. But user-provided type systems can be incredibly useful. As [Mike Ernst][mike]'s [type annotations][jsr308] project proved, extensible type qualifiers can be surprisingly powerful and versatile static analysis tools: they can avoid null-pointer exceptions, enforce locking disciplines, or track tainted data for security.

My [llvm-tq][llvmtq] brings extensible type qualifiers to C and C++ via the [LLVM][] compiler infrastructure and its [Clang][] frontend. You can use it to write plugins for Clang that define and check new type systems embodied in annotations on declarations.

The project also goes one step further: type qualifiers are carried through to the compiler's intermediate representation. This means that user-defined type systems to not have to be transparent---they can affect the semantics of the program. You can bring LLVM's full arsenal of compiler analyses to bear using information from the programmer.

Compiler-visible type annotations open many possibilities for programmer--compiler collaboration. I want to use the tool for [EnerJ][]-like types, but there are many other feasible applications.

As an example, llvm-tq could be the foundation for a hybrid static/dynamic information flow system. In information flow as in many analyses, static approaches are too conservative while dynamic approaches are too slow; hybrid systems can help realize the best of both worlds. By preserving type information in the LLVM IR, a hybrid system can easily insert dynamic checks for situations where isolation cannot be proven. Achieving something similar at the AST level would be a nightmare (believe me; I've tried).

Read more about the planned approach and the current status in [the project's README][readme]. Please [let me know][email] if you're interested in using extensible types in C and C++; I'd love to hear about other potential use cases.

[Clang]: http://clang.llvm.org/
[llvmtq]: https://github.com/sampsyo/llvm-tq
[jsr308]: http://types.cs.washington.edu/jsr308/
[mike]: https://homes.cs.washington.edu/~mernst/
[enerj]: {{ site.base }}/research.html
[email]: mailto:asampson@cs.washington.edu
[llvm]: http://llvm.org
[readme]: https://github.com/sampsyo/llvm-tq#llvm-tq-type-qualifiers-for-llvmclang
