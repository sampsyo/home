---
title: Try Snapshot Testing for Compilers and Compiler-Like Things
excerpt: |
    TK
---

TK the liberation of not writing unit tests, or complicated "expectations" at all

TK this insight is incredibly obvious, but it took me a while to come to it (because I had been trained that "testing == unit testing", basically)

TK write more tests, more quickly. just need a way to easily update them when things changes (since your predicates are not flexible.)

TK [Cram][], [lit][], [Runt][], [insta][]. here we'll see [Turnt][] (which is meant to be as simple as humanly possible while still being reusable/useful). Also consider [Runt][], which is better and fancier and rewritten in Rust

[lit]: https://llvm.org/docs/CommandGuide/lit.html
[cram]: https://bitheap.org/cram/
[runt]: https://github.com/rachitnigam/runt
[turnt]: https://github.com/cucapra/turnt
[insta]: https://insta.rs

## Trying Out Turnt

To feel what snapshot testing is like, let's try using [Turnt][].
You can install it with [pip][]:

    pip install --user turnt

We'll also need something to test.
For this contrived example, I'll test the venerable [Unix `wc` command][wc].

The first thing we need is an input file.
This is a critical thing about Turnt: it assumes the thing you want to test is a program that transforms text into text.
Fortunately, that describes lots of compiler-like things, and it also describes our SUT, `wc`.


1. introduce an example tool
2. an input and a command to run it. show piping the file to the output. imagine a "manual" version.
3. Turnt and `turnt.toml` with just `command`. `turnt`, `turnt --diff`, `turnt --save`
4. inline stuff and `ARGS`, `RETURN`
5. `turnt -vp` for interactive work

TK other Turnt stuff: multiple outputs, differential testing (multiple commands), etc.

[pip]: https://pip.pypa.io/en/stable/
[wc]: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/wc.html

*[SUT]: system under test

## Snapshot Philosophy

TK

- as above, better to write more tests than great tests. especially regression tests
- forces (or just encourages) you to make your thing a Unixy input/output command, with well-defined input and output files
- a primitive form of "documentation" in the form of input/output examples
