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

*[SUT]: system under test
[pip]: https://pip.pypa.io/en/stable/
[wc]: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/wc.html

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
Turnt tells us that it ran a grand total of one (1) test, and it succeeded---in the sense that `wc < hi.t` printed, on its standard output, exactly the same stuff that's saved in `hi.out`.

Let's add a second test.
Put this in in `2lines.t`:

    hello,
    world!

The first time around, we created the `*.out` file for our test ourselves.
But Turnt will happily do it for us with the `--save` flag:

    1..1
    not ok 1 - 2lines.t # skip: updated 2lines.out
    # missing: 2lines.out

It might be a good idea to `cat 2lines.out` to make sure it looks OK.
Then we can run our entire little test suite:

    $ turnt *.t
    1..2
    ok 1 - 2lines.t
    ok 2 - hi.t

Success again!
We're already two tests into the business of growing a thorough test suite.
The cornerstone of the snapshot testing philosophy is that it should be *extremely easy* to add new tests:
we just need to write an input file and `turnt --save` its output, and our test suite will grow.

Turnt's spartan output is in [TAP][] format, so you can make it prettier using one of a million TAP consumers, like [Faucet][]:

<pre><code>$ turnt *.t | faucet
<span class="ansi-green">✓ 2lines.t
✓ hi.t</span></code></pre>

[tap]: https://testanything.org
[faucet]: https://github.com/substack/faucet

## Adapting to Changes

The trade-off for snapshot testing's convenience is that its "specifications" are brittle.
Because tests have to match the saved output exactly, even tiny changes count as failures.
The remedy is to rely on human review---and to make these manual checks as convenient as possible.

Let's change one of our tests and watch it fail:

<pre><code>$ echo goodbye >> 2lines.t
$ turnt *.t | faucet
<span class="ansi-red">⨯ 2lines.t # differing: 2lines.out</span>
<span class="ansi-green">✓ hi.t</span>
<span class="ansi-red">⨯ fail  1</span></code></pre>

We want to see what changed in our failing test.
Running `turnt --diff` shows the change:

    $ turnt --diff 2lines.t
    1..1
    --- 2lines.out	2022-07-17 16:04:35.000000000 -0400
    +++ /tmp/tmpnim30l99	2022-07-20 14:55:21.000000000 -0400
    @@ -1 +1 @@
    -       2       2      14
    +       3       3      22
    not ok 1 - 2lines.t # differing: 2lines.out

That looks good, so we can now `turnt --save` to accept the new output.
In fact, since we've checked our output files into version control, it's sometimes easier to skip `turnt --diff` altogether:
you can just `turnt --save` the new output and then run `git diff` to see what's new.
Rolling back is just a `git stash` away.

If you use pull requests and code reviews, changes to test outputs will appear there too.
Your reviewers might appreciate these diffs as an easy way to see what behavior has changed.

## Overrides

With Turnt, a test is just a pair of an input file and an output file.
If either output is a program of some kind, this setup means that the files also work as standalone examples of the input or output language.
(You might want to [configure the output][turnt-output] so it uses the right filename extension for your language.)

If you need to configure something special about a test, there's a way to do that inside the input file.
It works by assuming your input language has some way of commenting out text, and it extracts options from that text.
For example, you can configure your `turnt.toml` to use `{args}` as a placeholder for per-test command-line flags:

    command = "wc {args} {filename}"

Then, you put a special marker in your input file:

    // ARGS: -l

Turnt doesn't care what comments look like in your language; it just looks for the string `ARGS:` anywhere inside it.
This test will run `wc -l` instead of just plain `wc`.

TK
4. inline stuff and `ARGS`, `RETURN`
5. `turnt -vp` for interactive work

Turnt also supports gathering [multiple output files from one command][turnt-output], running [several commands on the same input file][turnt-env], and comparing the output from different commands as a form of [differential testing][difftest].

[turnt-output]: https://github.com/cucapra/turnt#output
[turnt-env]: https://github.com/cucapra/turnt#multiple-environments
[difftest]: https://en.wikipedia.org/wiki/Differential_testing

## The Snapshot Philosophy

TK

- as above, better to write more tests than great tests. especially regression tests
- forces (or just encourages) you to make your thing a Unixy input/output command, with well-defined input and output files
- a primitive form of "documentation" in the form of input/output examples

TK [blog](https://borretti.me/article/lessons-writing-compiler#tests)
