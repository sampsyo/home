---
title: "LLVM for Grad Students"
excerpt: |
    [LLVM][] is a godsend of a research tool. Here are some detailed notes on what LLVM is, why you would want to use it for research, and how to get started as a compiler hacker.

    [llvm]: http://llvm.org/
---
These are some notes on doing research with the [LLVM][] compiler infrastructure. It should be enough for a grad student to go from mostly uninterested in compilers to excited to learn more about how to use it.

[llvm]: http://llvm.org/

## What is LLVM?

LLVM is a compiler. It's a *really nice* ahead-of-time compiler for "native" languages like C and C++.

Of course, since LLVM is so awesome, you will also hear that it is much more than this (it can also be a JIT; it powers a great diversity of un-C-like languages; it is the bytecode format for the App Store; etc.; etc.) These are all true, but for all purposes, the above definition is what matters.

A few huge things make LLVM different from other compilers:

* LLVM's intermediate representation (IR) is its great innovation. LLVM works on a representation of programs that you can *actually read* if you are reasonably familiar with assembly. This may not seem like a great revelation, but it is: other compilers' IRs tend to be in-memory structures so complicated that you can't really write them down. This makes other compilers harder for humans to understand and messier to implement.
* LLVM is really nicely written: its architecture is *way* more modular than other compilers. Part of the reason for this niceness comes from its original implementor, who is [one of us][lattner].
* Despite being the [research tool of choice][acmaward] for squirrelly academic hackers like us, LLVM is also an industrial-strength compiler backed by the largest company in the world. This means you don't have to compromise between a *great* compiler and a *hackable* compiler, as you do in Javaland when you choose between [HotSpot][] and [Jikes][].

[lattner]: http://nondot.org/sabre/
[acmaward]: http://awards.acm.org/award_winners/lattner_5074762.cfm
[hotspot]: http://java.com/en/download/
[jikes]: http://www.jikesrvm.org/

## Why Would a Grad Student Care About LLVM?

LLVM is a great compiler, but who cares if you don't do compilers research?

A compiler infrastructure is useful whenever you need to *do stuff with programs*. Which, in my experience, is kind of a lot. You can analyze programs to see how often they do a certain behavior you're interested in, transform them to work better with your system, or change them to pretend to use your hypothetical new architecture or OS without actually fabbing a new chip or writing an kernel module. For grad students, a compiler infrastructure is more often the right tool than most people give it credit for. I encourage you to reach for LLVM by default before any of these tools unless you have a really good reason:

* An architectural simulator
* A dynamic binary instrumentation tool like Pin
* Source-level transformation (from simple stuff like `sed` to complicated stuff like AST parsing and serialization)
* Hacking the kernel to intercept system calls
* Anything resembling a hypervisor

Even if a compiler doesn't seem like a *perfect* match for your task, it can often get you 90% of the way there far easier than, say, a source-to-source translation.

Here are some nifty examples of research projects that used LLVM to do things that are not necessarily all that compilery:

* [Virtual Ghost][] from UIUC showed you could use a compiler pass to protect processes from compromised OS kernels.
* We use a compiler pass in our approximate computing work to inject errors into programs to simulate error-prone hardware.
* [CoreDet][] from UW makes multithreaded programs deterministic.

So, to emphasize, LLVM is not just for implementing new compiler optimizations! 

[virtual ghost]: http://sva.cs.illinois.edu/pubs/VirtualGhost-ASPLOS-2014.pdf
[coredet]: http://homes.cs.washington.edu/~djg/papers/asplos10-coredet.pdf

## The Pieces

* Frontend. (Probably don't need to touch this. Just use Clang.)
* Passes.
* Code generation. (Almost certainly shouldn't touch this.)

A picture, which could be a picture of basically any realistic compiler.

## Getting Oriented

Documentation. Doxygen. Source code (from the git (GitHub?) mirror). Build instructions. Packages from Homebrew, etc.

Often, the version of LLVM that comes with your OS doesn't have all the headers necessary to hack with it. You'll need to install it from source. Brandon Holt has [good instructions for building it "right" on OS X][bholt-osx]. There's also a [Homebrew formula][homebrew-llvm], to which you'll want to pass the `--with-clang` option.

[homebrew-llvm]: https://github.com/Homebrew/homebrew/blob/master/Library/Formula/llvm.rb
[bholt-osx]: http://homes.cs.washington.edu/~bholt/posts/building-llvm.html

## So We're Going to Write a Pass

An example template to start from, including build system.

You may also want to check out the ["Writing an LLVM Pass"][passtut] tutorial. If you do, ignore the Makefile-based build system instructions and skip straight to the CMake-based ["out-of-source" instructions][outofsource], which is the only rational course of action.)

[outofsource]: http://llvm.org/docs/CMake.html#cmake-out-of-source-pass
[passtut]: http://llvm.org/docs/WritingAnLLVMPass.html

### A Skeleton

Clone the [llvm-pass-skeleton][skel] repository from GitHub. It contains a useless LLVM pass where we can do our work.

[skel]: https://github.com/sampsyo/llvm-pass-skeleton

Here's the relevant part of `Skeleton.cpp`:

    virtual bool runOnFunction(Function &F) {
      errs() << "I saw a function called " << F.getName() << "!\n";
      return false;
    }

There are several kinds of LLVM pass, and we're using one called a *function pass* (it's a good place to start). Exactly as you would expect, LLVM invokes that function above with every function it finds in the program we're compiling. For now, all it does is print out the name.

Details:

* The `errs()` thing is an LLVM-provided C++ output stream we can use to print to the console
* The function returns `false` to indicate that it didn't modify `F`.

### Build It

Build the pass with [CMake][]:

    $ cd llvm-pass-skeleton
    $ mkdir build
    $ cd build
    $ cmake ..  # Generate the Makefile.
    $ make  # Actually build the pass.

If LLVM isn't installed globally, you will need to tell CMake where to find it. You can do that by giving it the path to the `share/llvm/cmake/` directory inside wherever LLVM resides in the `LLVM_DIR` environment variable. Here's an example with the path from Homebrew:

    $ LLVM_DIR=/usr/local/opt/llvm/share/llvm/cmake cmake ..

[cmake]: http://www.cmake.org/

### Run It

To run your new pass, you just have to invoke `clang` on some C program and use some freaky flags to get it in place:

    $ clang -Xclang -load -Xclang build/skeleton/libSkeletonPass.* something.c
    I saw a function called main!

(You can also run passes one at a time, independently from invoking `clang`, with LLVM's `opt` command. I won't cover that here.)

## Understanding a Program in LLVM

Modules, Functions, Basic Blocks, instructions

We can inspect all of these objects with a convenient common method in LLVM named `dump()`. It just prints out the human-readable representation of an object in the IR. Here's some code to do that, which is available in the `containers` branch of the `llvm-pass-skeleton` repository:

    errs() << "Function body:\n";
    F.dump();

    for (auto &B : F) {
      errs() << "Basic block:\n";
      B.dump();

      for (auto &I : B) {
        errs() << "Instruction: ";
        I.dump();
      }
    }

Using C++11's fancy `auto` and foreach syntax makes the containment of LLVM's object hierarchy clear.

Most things are Values (including globals and constants, like 5)

The SSA graph (what is SSA?).

## Now Make the Pass Do Something Mildly Interesting

The real magic comes in when you *look for patterns in the program* and, optionally, *change the code* when you find them. Here's a really simple example: let's say we want to switch the order of every binary operator in the program. So `a + b` will be come `b + a`. Sounds useful, right?

    for (auto &B : F) {
      for (auto &I : B) {
        if (auto *op = dyn_cast<BinaryOperator>(&I)) {
          op->swapOperands();
        }
      }
    }

Details:

* To find out that there's a `swapOperands()` method, you just have to dig around. The best way is to click around in Doxygen (here's [the page for Binary Operator][bo]). Or you can train Google to love to look in the LLVM docs (when I search for "binaryoperator", it knows exactly what I want).
* That `dyn_cast<T>(p)` construct is LLVM-specific. It uses some conventions from the LLVM codebase to made type checks and such really efficient, since, in practice, compilers have to use them all the time. This particular construct returns a null pointer if `I` is not a `BinaryOperator`, so it's perfect for special-casing like this.

Now if we compile a program like this:

    #include <stdio.h>
    int main(int argc, const char **argv) {
        printf("%i\n", argc - 2);
    }

You can see the substraction goes the wrong way!

[bo]: http://llvm.org/docs/doxygen/html/classllvm_1_1BinaryOperator.html

That would be incredibly challenging to do as a raw source-code transformation. It would be easier at the AST level, but do you really want to worry about templates, etc.?

Eventually, explain IRBuilder.

## Linking With a Runtime Library

Probably want to use some code you wrote at run time. Don't write it by generating LLVM instructions!

## Annotations

Most projects eventually need to interact with the programmer. Some ways to do this:

* The crude way: magic functions.
* `__annotate__`
* Quala.

## Not Covered Here

* Using the vast array of analyses and optimizations available to you.
* Generating any special instructions (as architects often want to do) by modifying the backend.
* Exploiting debug info, so you can connect back to lines and columns and such in the source code.
