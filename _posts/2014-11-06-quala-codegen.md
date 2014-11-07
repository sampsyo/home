---
title: "Quala: Type Annotations in LLVM IR"
kind: article
excerpt: |
    My C and C++ type annotation project, Quala, aims to enable type-aware compiler research. This post demonstrates a type system that can insert dynamic null-pointer dereference checks to stop segfaults before they happen.
---
My perennial open-source side project, [Quala][], adds custom type annotations to a C and C++ compiler. One critical feature for me is that Quala's annotations are visible throughout the entire compilation lifecycle. The annotations don't end in the frontend; you can use an LLVM pass to do things with your annotations that would be difficult or impossible with a purely syntactic system.

For example, Quala makes it easy to implement *type-driven program instrumentation*. Unlike syntax-level systems along the lines of [CQual][], you can do your instrumentation and heavyweight analysis in the comfort of the compiler IR while exploiting language-level type information.

This kind of hybrid language/compiler work comes up surprisingly often in my research and that of similarly-inclined, [ASPLOS][]y academics.

I recently added a library to Quala to help use this pattern. To demonstrate it, I built a type system and compiler pass that, together, can prevent null-pointer dereferences.

## Null Check Insertion

In [my previous post about Quala][quala-post], I wrote about [Quala's "nullness" type system][nullness]. The idea is to imitate the safety of [optionals][] from languages like [ML][] or, now, [Swift][]. The checker emits warnings wherever you *might* dereference a null pointer. You use a new type qualifier, `NULLABLE`, to make some pointers as possibly-null:

    int * NULLABLE p = 0;
    ...;
    *p = ...;

and dereferencing null pointers (as in the last line above) will give you a warning.

The new version of the nullness checker goes one step further: it can insert a *dynamic check* to detect when a null pointer is dereferenced. It only puts these checks where a null dereference is possible: a non-null (unannotated) pointer needs no check.

Here's a program whose whole purpose in life is to dereference a null pointer:

    #include <stdio.h>
    #include <stdlib.h>

    #define NULLABLE __attribute__((type_annotate("nullable")))

    int qualaHandleNull() {
      fprintf(stderr, "saved from a null dereference!\n");
      exit(1);
    }

    int main(int argc, char **argv) {
      int * NULLABLE foo = 0;
      return *foo;
    }

Quala's null check insertion will call our custom `qualaHandleNull` function before any dereference to a null pointer. Unsurprisingly, if I compile this program with an ordinary compiler, it crashes:

    $ clang test.c
    (warning about an unrecognized attribute)
    $ ./a.out
    segmentation fault

But compiling the same program with Quala's `nullness-cc` shows that the handler gets called instead:

    $ ./nullness-cc test.c
    test.c:13:10: warning: dereferencing nullable pointer
      return *foo;
             ^
    $ ./a.out
    saved from a null dereference!

This example is a bit contrived---exiting with a message is not much better than crashing with a segfault. But at least you avoid the spooky spectre of undefined behavior! You could even use this instrumentation system to implement a form of [failure-oblivious computing][foc] if inspiration struck.

## How It Works

Quala produces [LLVM instruction metadata][md] that indicates the type qualifiers for every value produced in a program. It then provides an [LLVM analysis pass][pass] that gathers this information---so you can write your own pass that looks up these types. The nullness instrumentation pass, for example, [asks][checkline]:

    if (AI.hasAnnotation(Ptr, "nullable"))
      // instrument the instruction

to minimize overhead by only checking nullable pointers.

By pairing a type checker plugin for [Clang][] with an instrumentation pass for [LLVM][], you can create new kinds of language extensions that wouldn't be possible with either component alone.

## Get In Touch

Quala is still a prototype. But it's ready for experimentation now. If you have a project that could exploit type systems with semantics, I implore you to [get in touch][contact].

[foc]: http://dl.acm.org/citation.cfm?id=1251275
[cqual]: http://www.cs.umd.edu/~jfoster/cqual/
[quala]: https://github.com/sampsyo/quala
[asplos]: http://asplos15.bilkent.edu.tr
[quala-post]: {{site.base}}/blog/quala.html
[md]: http://dl.acm.org/citation.cfm?id=1251275
[pass]: http://llvm.org/docs/WritingAnLLVMPass.html
[contact]: {{site.base}}/contact.html
[optionals]: http://en.wikipedia.org/wiki/Option_type
[ml]: http://en.wikipedia.org/wiki/ML_(programming_language)
[swift]: https://developer.apple.com/swift/
[nullness]: https://github.com/sampsyo/quala/tree/master/examples/nullness
[checkline]: https://github.com/sampsyo/quala/blob/0ecbb1c70305c2410c1d05d818f956dd8614c7c5/examples/nullness/NullChecks.cpp#L42
[clang]: http://clang.llvm.org
[llvm]: http://llvm.org
