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

## An Example

To feel what snapshot testing is like, let's test something contrived but convenient.
We'll test the venerable [Unix `wc` command][wc].

The first thing we need is an input file.
This is a critical thing about this style of testing: it assumes the thing you want to test is a program that transforms text into text.
Fortunately, that describes lots of compiler-like things, and it also describes our SUT, `wc`.
Let's make a test file, `hi.t`:

    hello, world!

You can probably guess what `wc < hi.t` will say:

           1       2      14

The idea in snapshot testing is to "lock in" this output so, as we make changes in the future, we can easily make sure we didn't break `wc`'s correct behavior.
It's easy to generate a snapshot file:

    $ wc < hi.t > hi.out

If we were really working on a `wc` implementation, we would check both `hi.t` and `hi.out` into version control.

Now all we need is a convenient way to make sure `wc < hi.t` still matches `hi.out`.
That way, we can write a whole slew of these input files and get into the habit of checking that they *all* still do the same thing.

## Trying Out Turnt

That's what [Turnt][] does.
(And that's *all* that it does, more or less.)
You can install it with [pip][]:

    $ pip install --user turnt

We need to tell Turnt what command to run.
Put this into a file called `turnt.toml`:

    command = "wc < {filename}"

Then run Turnt on our little test:

    $ turnt hi.t
    1..1
    ok 1 - hi.t

Success!
Turnt tells us that it ran a grand total of one (1) test, and it succeeded---in the sense that `wc < hi.t` produced, on its standard output, exactly the same stuff that's saved in `hi.out`.

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
