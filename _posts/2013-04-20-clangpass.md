---
title: "Run an LLVM Pass Automatically with Clang"
kind: article
layout: post
excerpt: |
    Lots of research projects need to instrument code while it gets compiled.
    While LLVM passes are a convenient way to implement instrumentation, the
    official LLVM documentation doesn't make it clear how to use them that way
    easily. Here's a trick that lets you instrument programs when compiling
    them with the Clang command-line compiler driver.
---

In lots of research projects that I've worked on, I have needed to instrument programs while compiling them. Ideally, I want to do my instrumentation on big, real-world applications that assume a `gcc`- or `g++`-like command-line compiler driver in their Makefiles. While the obvious choice for this kind of instrumentation is an [LLVM pass][], the official docs for LLVM make running your custom pass sound tricky. According to them, you need this sort of rigmarole:

1. Compile each source file to bitcode with `clang -c -emit-llvm code.c`.
2. Run your pass by itself with `opt -load mypass.so -mypass < code.bc > code_inst.bc`.
3. Run the rest of the standard optimizations with `opt -O3 < code_inst.bc > code_opt.bc`.
4. Compile the optimized bitcode into assembly with `llc` and then use your favorite assembler and linker to get the rest of the way to an executable.

This process is a pain when what you really need is to run `clang`, which is command-line-compatible with `gcc`, just with your own pass slipped in among the rest of the optimizations. Ideally, you would type `clang -mypass code.c` to do everything at once.

Here's a trick to enable something like that. You can use LLVM's [pass registry][] to enable your pass automatically when its shared library is loaded. To do that, just put something like this at the end of your pass code:

    static void registerMyPass(const PassManagerBuilder &,
                               PassManagerBase &PM) {
        PM.add(new MyPass());
    }
    static RegisterStandardPasses
        RegisterMyPass(PassManagerBuilder::EP_EarlyAsPossible,
                       registerMyPass);

where `MyPass` is the name of your pass class. This way, as soon as your shared library, `mypass.so`, is linked into any LLVM-using tool, it will ask for `MyPass` to be run. (You can choose when the pass runs by selecting a [ExtensionPointTy][].)

Now, to load and register your pass, just type:

    $ clang -Xclang -load -Xclang mypass.so ...

and you'll have a full-fledged compiler driver augmented with your instrumentation.

[ExtensionPointTy]: http://llvm.org/docs/doxygen/html/classllvm_1_1PassManagerBuilder.html#a575d14758794b0997be4f8edcef7dc91
[pass registry]: http://llvm.org/docs/doxygen/html/classllvm_1_1PassRegistry.html
[LLVM pass]: http://llvm.org/docs/WritingAnLLVMPass.html
