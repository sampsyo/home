---
title: "LLVM for Grad Students"
excerpt: |
    [LLVM][] is a godsend of a research tool. Here are some detailed notes on what LLVM is, why you would want to use it for research, and how to get started as a compiler hacker.

    [llvm]: http://llvm.org/
highlight: true
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

A compiler infrastructure is useful whenever you need to *do stuff with programs*. Which, in my experience, is kind of a lot. You can analyze programs to see how often they do a certain behavior you're interested in, transform them to work better with your system, or change them to pretend to use your hypothetical new architecture or OS without actually fabbing a new chip or writing an kernel module. For grad students, a compiler infrastructure is more often the right tool than most people give it credit for. I encourage you to reach for LLVM by default before hacking any of these tools unless you have a really good reason:

* An [architectural simulator][wddd]
* A dynamic binary instrumentation tool like [Pin][]
* Source-level transformation (from simple stuff like `sed` to complicated stuff like AST parsing and serialization)
* Hacking the kernel to intercept system calls
* Anything resembling a hypervisor

[pin]: http://www.pintool.org/
[wddd]: http://research.cs.wisc.edu/vertical/papers/2014/wddd-sim-harmful.pdf

Even if a compiler doesn't seem like a *perfect* match for your task, it can often get you 90% of the way there far easier than, say, a source-to-source translation.

Here are some nifty examples of research projects that used LLVM to do things that are not necessarily all that compilery:

* [Virtual Ghost][] from UIUC showed you could use a compiler pass to protect processes from compromised OS kernels.
* [CoreDet][] from UW makes multithreaded programs deterministic.
* In our approximate computing work, we use an LLVM pass to inject errors into programs to simulate error-prone hardware.

So, to emphasize, LLVM is not just for implementing new compiler optimizations!

[virtual ghost]: http://sva.cs.illinois.edu/pubs/VirtualGhost-ASPLOS-2014.pdf
[coredet]: http://homes.cs.washington.edu/~djg/papers/asplos10-coredet.pdf

## The Pieces

Here's a picture that shows the major components of LLVM's architecture (and, really, any modern compiler):

<img src="{{ site.base }}/media/llvm/compiler-arch.svg" alt="Front End, Passes, Back End" class="img-responsive">

There are:

* The *front end*, which takes your source code and turns it into an *intermediate representation* or IR. This translation simplifies the job of the rest of the compiler, which doesn't want to deal with the full complexity of C++ source code. You, an intrepid grad student, probably do not need to hack this part; you can use [Clang][] unmodified.
* The *passes*, which transform IR to IR. In ordinary circumstances, passes usually optimize the code: that is, they produce an IR program as output that does the same thing as the IR they took as input, except that it's faster. **This is where you want to hack.** Your research can work by looking at and changing IR as it flows through the compilation process.
* The *back end*, which generates actual machine code. You almost certainly don't need to touch this part.

Although this architecture describes most compilers these days, one novelty about LLVM is worth noting here: programs use *the same IR* throughout the process. In other compilers, each pass might produce a program in a different form with different structure. LLVM opts for the opposite approach, is great for us as hackers: we don't have to worry too much about where in the process our code gets to see the IR, as long as it's somewhere between the front end and back end.

[clang]: http://clang.llvm.org/

## Getting Oriented

Let's start hacking.

### Get LLVM

You'll need to need to install LLVM. Linux distributions often have LLVM and Clang packages you can use off the shelf. But you'll need to ensure you get a version that includes all the headers necessary to hack with it. The OS X build that comes with [Xcode][], for example, is not complete enough. Fortunately, it's not hard to [build LLVM from source][buildllvm] using CMake. Usually, you only need to build LLVM itself---your system-provided Clang will do just fine (although there are [instructions for that][buildclang] too).

On OS X in particular, [Brandon Holt][bholt] has [good instructions for doing it right][bholt-osx]. There's also a [Homebrew formula][homebrew-llvm].

### RTFM

You will need to get friendly with the documentation. I find these links in particular are worth coming back to periodically:

- The [automatically generated Doxygen pages][llvmdoxygen] are *super important*. You will need to live inside these API docs to make any progress at all while hacking on LLVM. Those pages can be hard to navigate, though, so I recommend going through Google. If you append "LLVM" to any function or class name, Google [usually finds the right Doxygen page](https://google.com/search?q=basicblock+llvm). (If you're diligent, you can usually train Google to give you LLVM results first even without typing "LLVM"!) I realize this sounds ridiculous, but you really need to jump around LLVM's API docs like this to survive---and if there's a better way to navigate the API, I haven't found it.
- The [language reference manual][langref] is handy if you ever get confused by syntax in an LLVM IR dump.
- The [programmer's manual][progman] describes the toolchest of data structures peculiar to LLVM, including efficient strings, STL alternatives for maps and vectors and the like, etc. It also outlines the fast type introspection tools (`isa`, `cast`, and `dyn_cast`) that you'll run into everywhere.
- Read the [*Writing an LLVM Pass*][passtut] whenever you have questions about what your pass can do. Because you're a researcher and not a day-to-day compiler hacker, this article disagrees with that tutorial on some details. (Most urgently, ignore the Makefile-based build system instructions and skip straight to the CMake-based ["out-of-source" instructions][outofsource].) But it's nonetheless the canonical source for answers about passes in general.
- The [GitHub mirror][llvm-gh] is sometimes convenient for browsing the LLVM source online.

[homebrew-llvm]: https://github.com/Homebrew/homebrew/blob/master/Library/Formula/llvm.rb
[bholt-osx]: http://homes.cs.washington.edu/~bholt/posts/building-llvm.html
[bholt]: http://homes.cs.washington.edu/~bholt/
[buildllvm]: http://llvm.org/docs/CMake.html
[buildclang]: http://clang.llvm.org/get_started.html
[llvm-gh]: https://github.com/llvm-mirror/llvm
[langref]: http://llvm.org/docs/LangRef.html
[progman]: http://llvm.org/docs/ProgrammersManual.html
[passtut]: http://llvm.org/docs/WritingAnLLVMPass.html
[llvmdoxygen]: http://llvm.org/doxygen/
[xcode]: https://developer.apple.com/xcode/
[outofsource]: http://llvm.org/docs/CMake.html#cmake-out-of-source-pass

## So We're Going to Write a Pass

Productive research with LLVM usually means writing a custom pass. This section will guide you through building and running a simple pass that transforms programs on the fly.

### A Skeleton

I've put together a [template repository][skel] that contains a useless LLVM pass. I recommend you start with the template: when starting from scratch, getting the build configuration set up can be especially painful.

Clone the [llvm-pass-skeleton][skel] repository from GitHub:

```none
$ git clone git@github.com:sampsyo/llvm-pass-skeleton.git
```

The real work gets done in `skeleton/Skeleton.cpp`, so open up that file. Here's the relevant part where the business happens:

[skel]: https://github.com/sampsyo/llvm-pass-skeleton

```cpp
virtual bool runOnFunction(Function &F) {
  errs() << "I saw a function called " << F.getName() << "!\n";
  return false;
}
```

There are several kinds of LLVM pass, and we're using one called a *function pass* (it's a good place to start). Exactly as you would expect, LLVM invokes the method above with every function it finds in the program we're compiling. For now, all it does is print out the name.

Details:

* That `errs()` thing is an LLVM-provided C++ output stream we can use to print to the console.
* The function returns `false` to indicate that it didn't modify `F`. Later, when we actually transform the program, we'll need to return `true`.

### Build It

Build the pass with [CMake][]:

```sh
$ cd llvm-pass-skeleton
$ mkdir build
$ cd build
$ cmake ..  # Generate the Makefile.
$ make  # Actually build the pass.
```

If LLVM isn't installed globally, you will need to tell CMake where to find it. You can do that by giving it the path to the `share/llvm/cmake/` directory inside wherever LLVM resides in the `LLVM_DIR` environment variable. Here's an example with the path from Homebrew:

```none
$ LLVM_DIR=/usr/local/opt/llvm/share/llvm/cmake cmake ..
```

Building your pass produces a shared library. You can find it at `build/skeleton/libSkeletonPass.so` (or a similar name, depending on your platform). In the next step, we'll load this library to run the pass on some real code.

[cmake]: http://www.cmake.org/

### Run It

To run your new pass, invoke `clang` on some C program and use some freaky flags to get it in place:

```none
$ clang -Xclang -load -Xclang build/skeleton/libSkeletonPass.* something.c
I saw a function called main!
```

That `-Xclang -load -Xclang path/to/lib.so` dance is all you need to [load and activate your pass in Clang][autoclang]. So if you need to process larger projects, you can just add those arguments to a Makefile's `CXXFLAGS` or the equivalent for your build system.

(You can also run passes one at a time, independently from invoking `clang`. This way, which uses LLVM's `opt` command, is the [official documentation-sanctioned way][optload], but I won't cover it here.)

Congratulations; you've just hacked a compiler! In the next steps, we'll extend this no-op pass to do something interesting to the program.

[autoclang]: http://adriansampson.net/blog/clangpass.html
[optload]: http://llvm.org/docs/WritingAnLLVMPass.html#running-a-pass-with-opt

## Understanding LLVM IR

<figure style="max-width: 250px;">
<img src="{{ site.base }}/media/llvm/llvm-containers.svg" alt="Module, Function, BasicBlock, Instruction">
<figcaption><a href="http://llvm.org/docs/doxygen/html/classllvm_1_1Module.html">Module</a>s contain <a href="http://llvm.org/docs/doxygen/html/classllvm_1_1Function.html">Function</a>s, which contain <a href="http://llvm.org/docs/doxygen/html/classllvm_1_1BasicBlock.html">BasicBlock</a>s, which contain <a href="http://www.llvm.org/docs/doxygen/html/classllvm_1_1Instruction.html">Instruction</a>s. Everything but Module is a <a href="http://www.llvm.org/docs/doxygen/html/classllvm_1_1Value.html">Value</a>.</figcaption>
</figure>

To work with programs in LLVM, you need to know a little about how the IR is organized.

### Containers

Here's on overview of the most important components in an LLVM program:

* A [Module][] represents a source file (roughly) or a *translation unit* (pedantically). Everything else is contained in a Module.
* Most notably, Modules house [Function][]s, which are exactly what they sound like: named chunks of executable code. (In C++, both functions and methods correspond to LLVM Functions.)
* Aside from declaring their name and arguments, Functions are mainly containers of [BasicBlock][]s. The [basic block][] is a familiar concept from compilers, but for our purposes, it's just a contiguous chunk of instructions.
* An [Instruction][], in turn, is a single code operation. The level of abstraction is roughly the same as [RISC][]-like machine code: an instruction might be an integer addition, a floating-point divide, or a store to memory, for example.

Most things in LLVM---including Function, BasicBlock, and Instruction---are C++ classes that inherit from an omnivorous base class called [Value][]. A Value is any data that can be used in a computation---a number, for example, or the address of some code. Global variables and constants (like 5) are also Values.

### An Instruction

Here's an example of an Instruction (in the human-readable text form of LLVM IR):

```llvm
%5 = add i32 %4, 2
```

This instruction adds two 32-bit integer values (indicated by the type `i32`). It adds the number in register 4 (written `%4`) and the literal number 2 (written `2`) and places its result in register 5. This is what I mean when I say LLVM IR looks like idealized RISC machine code: we even use the same terminology, like *register*, but there are an infinite number of registers.

That same instruction is represented inside the compiler as an instance of the [Instruction][] C++ class. The object has an opcode indicating that it's an addition, a type, and a list of operands that are pointers to other Value objects. In our case, it points to a [Constant][] object representing the number 2 and another [Instruction][] corresponding to the register %5. (Since LLVM IR is in [static single assignment][ssa] form, registers and Instructions are actually one and the same.)

[module]: http://llvm.org/docs/doxygen/html/classllvm_1_1Module.html
[function]: http://llvm.org/docs/doxygen/html/classllvm_1_1Function.html
[basicblock]: http://llvm.org/docs/doxygen/html/classllvm_1_1BasicBlock.html
[instruction]: http://www.llvm.org/docs/doxygen/html/classllvm_1_1Instruction.html
[value]: http://www.llvm.org/docs/doxygen/html/classllvm_1_1Value.html
[basic block]: https://en.wikipedia.org/wiki/Basic_block
[risc]: https://en.wikipedia.org/wiki/Reduced_instruction_set_computing
[constant]: http://www.llvm.org/docs/doxygen/html/classllvm_1_1Constant.html
[ssa]: https://en.wikipedia.org/wiki/Static_single_assignment_form

By the way, if you ever want to see the LLVM IR for your program, you can instruct Clang to do that:

```none
$ clang -emit-llvm -S -o - something.c
```

### Inspecting IR in Our Pass

Let's get back to that LLVM pass we were working on. We can inspect all of the important IR objects using a convenient common method in LLVM named `dump()`. It just prints out the human-readable representation of an object in the IR. Since our pass gets handed Functions, let's use it to iterate over each Function's BasicBlocks, and then over each BasicBlock's set of Instructions.

Here's some code to do that. You can get it by checking out [the `containers` branch][containers branch] of the `llvm-pass-skeleton` git repository:

```cpp
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
```

Using C++11's fancy `auto` type and foreach syntax makes it easy to navigate the hierarchy in LLVM IR.

If you build the pass again and run a program through it, you should now see the various parts of the IR split out as we traverse them.

[containers branch]: https://github.com/sampsyo/llvm-pass-skeleton/tree/containers

## Now Make the Pass Do Something Mildly Interesting

The real magic comes in when you *look for patterns in the program* and, optionally, *change the code* when you find them. Here's a really simple example: let's say we want to replace the first binary operator (`+`, `-`, etc.) in every function with a multiply.Sounds useful, right?

Here's the code to do that. This version, along with an example program to try it on, is available in [the `mutate` branch][mutate branch] of the `llvm-pass-skeleton` git repository:

```cpp
for (auto &B : F) {
  for (auto &I : B) {
    if (auto *op = dyn_cast<BinaryOperator>(&I)) {
      // Insert at the point where the instruction `op` appears.
      IRBuilder<> builder(op);

      // Make a multiply with the same operands as `op`.
      Value *lhs = op->getOperand(0);
      Value *rhs = op->getOperand(1);
      Value *mul = builder.CreateMul(lhs, rhs);

      // Everywhere the old instruction was used as an operand, use our
      // new multiply instruction instead.
      for (auto &U : op->uses()) {
        User *user = U.getUser();  // A User is anything with operands.
        user->setOperand(U.getOperandNo(), mul);
      }

      // We modified the code.
      return true;
    }
  }
}
```

Details:

* That `dyn_cast<T>(p)` construct is an [LLVM-specific introspection utility][llvm rtti]. It uses some conventions from the LLVM codebase to made type checks and such really efficient, since, in practice, compilers have to use them all the time. This particular construct returns a null pointer if `I` is not a `BinaryOperator`, so it's perfect for special-casing like this.
* The [`IRBuilder`][irbuilder] is for constructing code. It has a million methods for creating any kind of instruction you could possibly want.
* To stitch our new instruction into the code, we have to find all the places it's used and swap in our new instruction as an argument. Recall that an Instruction is a Value: here, the multiply Instruction is used as an operand in another Instruction, meaning that the product will be fed in as an argument.
* We should probably also remove the old instruction, but I left bit that off for brevity.

[mutate branch]: https://github.com/sampsyo/llvm-pass-skeleton/tree/mutate
[llvm rtti]: http://llvm.org/docs/ProgrammersManual.html#isa
[irbuilder]: http://llvm.org/docs/doxygen/html/classllvm_1_1IRBuilder.html

Now if we compile a program like this (`example.c` in the repository):

```cpp
#include <stdio.h>
int main(int argc, const char** argv) {
    int num;
    scanf("%i", &num);
    printf("%i\n", num + 2);
    return 0;
}
```

Compiling it with an ordinary compiler does what the code says, but our plugin makes it double the number instead of adding 2:

```none
$ ./a.out
10
12
$ clang -Xclang -load -Xclang build/skeleton/libSkeletonPass.so example.c
$ ./a.out
10
20
```

Like magic!

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

---

*Thanks to the UW architecture and systems groups, who sat through an out-loud tutorial version of this post.*
