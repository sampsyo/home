---
title: "PyPy and CPython’s Broken Multithreaded Semantics"
kind: article
layout: post
excerpt: |
    The team behind [PyPy][], an astoundingly successful Python JIT, has been
    working on improving the performance of multithreaded Python programs. The
    tactic so far has been to adhere closely to the *semantics* of CPython's
    global interpreter lock, or GIL, while mitigating its performance impact.
    But GIL semantics are expensive to enforce and encourge Python programmers
    to write subtly incorrect parallel programs. High-performance Python
    implementations should abandon not just the GIL but also its model for
    parallel programming.

    [PyPy]: http://pypy.org
---

[PyPy][] is an astoundingly successful endeavor to simplify the implementation of fast JITs for dynamic languages. It's also, of course, a great implementation of [Python][], a language that has historically lacked serious, production-grade JITs. Anecdotally, I've seen 3--10x speedups on nontrivial compute-bound programs I've written.

For more than year now, the developers behind PyPy have been [working on adding software transactional memory to their JIT infrastructure][tmblog]. The plan is not, however, just to bring TM's optimistic atomicity to Python programmers. Although it's very exciting that PyPy will get [STM-powered `with thread.atomic:` isolated blocks][multicoreblog] as a side effect, the [original idea][tmblog] was to use STM at the meta level to achieve that holy grail of Python concurrency: removing the GIL.

For the uninitiated, the [Global Interpreter Lock][gil] is CPython's coarse-grained mutex that serializes the operations of each Python thread. It makes many operations in CPython implicitly atomic and, in doing so, eliminates any potential CPU speedup from multithreading your Python program.

The PyPy project's goal is to use STM in the interpreter implementation to remove the GIL and allow true parallelism among threads. The effect will be similar to [Jython's complex fine-grained locking][jythongil] but with a much simpler implementation and precise adherence to CPython semantics. The goal to simplify the implementation of atomic operations is noble and aligned with PyPy's overarching purpose to simplify the implementation of efficient interpreters. But I believe CPython's multithreaded semantics encourage bad programming practices that lead to silently broken parallel programs. Without a specific alternative in mind, I urge the PyPy team---and all runtime implementors---to explore different options that move beyond CPython's misguided consistency model.

[jythongil]: http://www.jython.org/jythonbook/en/1.0/Concurrency.html
[gil]: http://wiki.python.org/moin/GlobalInterpreterLock

## The Problem with CPython Semantics

PyPy with meta-level STM will attempt to closely replicate the semantics of CPython but with better parallelism. Here, I'll briefly describe the consistency guarantees given to multithreaded CPython programs and then try to convince you that they do more harm than good.

CPython only releases and acquires the GIL [between bytecode instructions][atomicops]. Another way to say this is that the GIL imposes multithreaded semantics in which every bytecode instruction is atomic: any execution of a multithreaded Python program appears to behave as an interleaving of each thread's instructions. It's impossible for one thread to make any changes when another thread is halfway through executing a bytecode instruction.

Bytecode instructions perform small operations: get a value from a variable, add two numbers together, jump to the top of a loop, etc. And it's certainly useful that, for example, writing to a local variable is an atomic operation. But many very simple operations in Python comprise multiple bytecode instructions. For example, this statement:

	votes += 1

takes four instructions: load variable, load constant 1, add, store variable. It's not atomic. Another thread manipulating `votes` can interleave between the load and store and lose the update. If you want this operation to be atomic, and you almost certainly do, you need to carefully synchronize this code with [locks][] or some other construct.

[locks]: http://docs.python.org/library/threading.html#threading.Lock

So the first problem is that every nontrivial operation is nonatomic. CPython's bytecode-atomicity semantics can't even help you with operations as simple as `votes += 1`. But a deeper problem lies in the fact that [bytecode in an implementation detail][dis] that's allowed to change from version to version. Python programmers, even really clever ones, shouldn't need to reason about the interpreter's bytecode format.

And there's a good reason not to know too much about the interpreter's  internal bytecode architecture: from the programmer's perspective, it makes no sense whatsoever. Creating a list or a dict, for example, is a single bytecode instruction, but creating a set is not. Calling `pop` on lists, which are implemented in C, is (probably) atomic, but calling `pop` on user-defined list-like objects is not. Here, quiz yourself: is this statement atomic?

	o.f = 2

It depends, of course. If the object `o` overrides `__setattr__`, then this operation could consist of many bytecode instructions. With these myriad inconsistencies from the perspective of the Python language, mistakes are certain.

The upshot of this mess is that, under GIL semantics, *you need to synchronize every time you modify shared state*. It's virtually impossible to reason correctly about the atomicity guarantees afforded by the GIL, so you can't depend on them to make your program correct. Only explicit synchronization (e.g., locking) has any hope of producing correct multithreaded programs.

[dis]: http://docs.python.org/library/dis.html
[atomicops]: http://docs.python.org/faq/library.html#what-kinds-of-global-value-mutation-are-thread-safe

## Costly Madness

Unsynchronized access to shared state are called *data races*.[^race] CPython's atomic bytecode instructions prevent things from going *completely* wrong in the presence of races. For example, a race can't make a CPython program [segfault][]. But things can still go *very* wrong. In fact, they can still go wrong in inscrutable, subtle, [heisenbug][]-y ways---and they likely will. To continue our earlier example, say that two threads try to run `votes += 1` at the same time. If the bytecode instructions interleave in a certain way, `votes` will only be incremented once. One vote is silently lost and the program continues.

[^race]:  Pedantically, a data race---or just a "race" for short---occurs when one thread writes somewhere in memory and another thread, without synchronizing with the first, reads or writes the same variable.

[heisenbug]: http://en.wikipedia.org/wiki/Heisenbug

So racy programs, even under GIL semantics, are probably incorrect programs.[^racebugs] You still need to use locks to write correct multithreaded programs.
The only advantage that GIL semantics affords is that these buggy, racy programs don't segfault or cause arbitrary memory corruption.

[^racebugs]: This position can be summed up as "races are bugs." That assertion is still controversial in the academic community, where [some still believe][portend] in "benign" races and [others don't][boehm]. But we generally talk about C-like languages where (some) programmers can reasonably be expected to want to reason about the hardware's memory model. I think it's a safer assumption that Python programmers should be protected from consistency details.

To take an extreme stance for a moment, even this property is suspect. While it might at first sound desirable to prevent undefined behavior when races occur, remember that the alternative is silent, subtle, nondeterministic incorrect program behavior. If you had a race in your program, would you rather it crash---alerting you that something's wrong---or silently continue, obscuring the root cause in the sands of time? While I won't go so far as to say that a segfaulting interpreter would be a good thing, I *do* want to emphasize that the alternative---the GIL or PyPy with an STM technique that mimics it---is a terrible situation too. Because the impact of data races is so subtly pernicious, CPython encourages programmers to permit them under the mistaken assumption that they're harmless.

[tmblog]: http://morepypy.blogspot.com/2011/08/we-need-software-transactional-memory.html
[multicoreblog]: http://morepypy.blogspot.com/2012/08/multicore-programming-in-pypy-and.html

Constructing PyPy to emulate GIL semantics, then, pays a steep price in complexity and performance for very little in return. A better Python should reconsider not just the GIL but the multithreaded semantics it imposes. It should provide a consistency model that discourages data races instead of encouraging them. Or, more radically, it should forbid implicitly shared state altogether and adopt a [Concurrent ML][cml]-like channel API or explicit sharing. But paying STM's overheads to preserve an unfortunate relic from CPython---and conceal bugs in the broken programs that depend on it---is in no one's best interest.

[cml]: http://cml.cs.uchicago.edu
[segfault]: http://en.wikipedia.org/wiki/Segmentation_fault
[boehm]: http://static.usenix.org/event/hotpar11/tech/final_files/Boehm.pdf
[PyPy]: http://pypy.org
[Python]: http://python.org
[portend]: http://infoscience.epfl.ch/record/173730
