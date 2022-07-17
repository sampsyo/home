---
title: Try Snapshot Testing for Compilers and Compiler-Like Things
excerpt: |
    TK
---

TK the liberation of not writing unit tests, or complicated "expectations" at all

TK write more tests, more quickly. just need a way to easily update them when things changes (since your predicates are not flexible.)

TK [Cram][], [lit][], [Runt][], [insta][]. here we'll see Turnt (which is meant to be as simple as humanly possible while still being reusable/useful). Also consider [Runt][], which is better and fancier and rewritten in Rust

[lit]: https://llvm.org/docs/CommandGuide/lit.html
[cram]: https://bitheap.org/cram/
[runt]: https://github.com/rachitnigam/runt
[turnt]: https://github.com/cucapra/turnt
[insta]: https://insta.rs

1. introduce an example tool
2. an input and a command to run it. show piping the file to the output. imagine a "manual" version.
3. Turnt and `turnt.toml` with just `command`. `turnt`, `turnt --diff`, `turnt --save`
4. inline stuff and `ARGS`, `RETURN`
5. `turnt -vp` for interactive work

TK other Turnt stuff: multiple outputs, differential testing (multiple commands), etc.

TK philosophy:

- as above, better to write more tests than great tests. especially regression tests
- forces (or just encourages) you to make your thing a Unixy input/output command, with well-defined input and output files
- a primitive form of "documentation" in the form of input/output examples
