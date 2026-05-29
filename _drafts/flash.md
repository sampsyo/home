title: A Fake Shell for Pangenomics
excerpt: |
    TK
---
For a while now, I have been working on [a fast toolkit for pangenomics, called FlatGFA][flatgfa-post].
Relative to other pangenomics tools like [odgi][], FlatGFA has one trick:
a zero-copy data format.
The in-memory data format is identical to the on-disk format, so FlatGFA can skip all serialization and deserialization costs;
opening a file consists of an [mmap(2)][mmap].
For unfairly cherry-picked workloads, FlatGFA can be thousands of times faster than odgi.

Now comes the hard part:
I want my genomicist colleagues to actually use FlatGFA.
I want to write an inventory of high-performance operations and let the _real_ scientists compose them into complete workflows.

To let them do that kind of composition, there were two clear options:
we could either
(1) make a command-line interface that exposes all the operators and let the scientists write shell scripts to compose them, or
(2) design a Rust API and have the scientists write Rust code.
Neither option is all that compelling:

1. The CLI approach really limits the kind of composition you can do.
   All intermediates need to be either files or pipes,
   which can get awkward and surely comes with some overhead.
2. Our internal Rust API is, because of all the data-structure tricks we play, written an endearingly idiosyncratic style.
   Even though our biologist collaborators are already Rust hackers, I can't in good conscience say that we have a _good_ API that they'd be happy to use.

This post is about the very silly alternative that we recently built:
a "fake shell" that _pretends_ to be like option 1 but approximates the performance of option 2.

Ousterhout Dichotomies and Vectorized Interpreters
--------------------------------------------------

For a long time, I thought that the right way to "package" a performance-oriented library like FlatGFA might be with an [Ousterhout dichotomy][od].
The performance-sensitive, bulk routines stay in Rust, but we build bindings to a higher-level language for composing whole workflows.
The result would look a lot like [PyTorch][]: it doesn't matter to ML engineers that Python isn't very fast because more than 99% of the time is spent in optimized kernel routines written in C++ and CUDA.

Python is the natural choice for the "glue language" part of an Ousterhout dichotomy in the modern era.
(Sorry, Tcl.)
So we actually started building Python bindings for FlatGFA using the excellent [PyO3][] project, which eliminates a lot of the boilerplate you'd otherwise have to write when making a Python extension.

TK ["vectorized interpreters" talk from Graydon][vecint].
TK I originally thought this would be Python (and we did build those bindings), but this is (a) a lot of work, even with PyO3, (b) reuses Python's interpreter, meaning we get less of a whole-program view, and (c) as it turns out, not even what the genomicists want to do.

TK they like the shell! pipes! concurrency and streaming! files!
TK the moment in the meeting when we disagreed about whether literally reusing the shell could ever be a good idea. the arguments: (1) fundamental disk orientedness, (2) but caching is pretty good, and (3) "everything in memory" doesn't scale anyway.

TK so the idea: a fake shell!

[pyo3]: https://pyo3.rs/

Design
------

reuse a [shell syntax parser][brush-parser] from [a "rewrite it in rust" shell project][brush] (thanks!)

"pass-through" for running real commands

IR, interpreter. sets up pipes, opens files.


Optimizations
-------------

the point is to get to do optimizations on the IR. things that would be real weird otherwise.


[flatgfa-post]: {{site.base}}/blog/flatgfa.html
[odgi]: https://odgi.readthedocs.io/en/latest/
[mmap]: https://linux.die.net/man/2/mmap
[od]: https://web.stanford.edu/~ouster/cgi-bin/papers/scripting.pdf
[vecint]: https://venge.net/graydon/talks/VectorizedInterpretersTalk-2023-05-12.pdf
[brush]: https://crates.io/crates/brush
[brush-parser]: https://crates.io/crates/brush-parser
