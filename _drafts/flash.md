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
For that, a weird little Rust library, written in Rust in an endearingly idiosyncratic style, isn't going to cut it.
I can't, in good conscience, tell these collaborators that our API is a convenient and fun way to construct data analysis pipelines for their real, important work.
TK Why not?
TK Something about the command-line interface being a dead end?

TK something about the central challenge being *composition*

I think the right way to "package" a performance-oriented library like FlatGFA might be with an [Ousterhout dichotomy][od]:
the performance-sensitive, bulk routines stay in Rust, but we build bindings to a higher-level language for orchestrating these routines into full workloads.
TK ["vectorized interpreters" talk from Graydon][vecint].
TK I originally thought this would be Python (and we did build those bindings), but this is (a) a lot of work, even with PyO3, (b) reuses Python's interpreter, meaning we get less of a whole-program view, and (c) as it turns out, not even what the genomicists want to do.

TK they like the shell! pipes! concurrency and streaming! files!
TK the moment in the meeting when we disagreed about whether literally reusing the shell could ever be a good idea. the arguments: (1) fundamental disk orientedness, (2) but caching is pretty good, and (3) "everything in memory" doesn't scale anyway.

TK so the idea: a fake shell!

Design
------

reuse a shell syntax parser (it's not great---sorry. obviously hard to parse shell syntax, and I never intended it to be complete.)

"pass-through" for running real commands

IR, interpreter. sets up pipes, opens files.


Optimizations
-------------

the point is to get to do optimizations on the IR. things that would be real weird otherwise.


[flatgfa-post]: {{site.base}}/blog/flatgfa.html
[odgi]: https://odgi.readthedocs.io/en/latest/
[mmap]: https://en.wikipedia.org/wiki/Mmap
[od]: https://en.wikipedia.org/wiki/Ousterhout%27s_dichotomy
[vecint]: https://venge.net/graydon/talks/VectorizedInterpretersTalk-2023-05-12.pdf
[raphamorim-flash]: https://github.com/raphamorim/flash
