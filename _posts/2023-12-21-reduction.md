---
title: "Manual Test-Case Reduction"
excerpt: |
    I often find myself recommending to new researchers that they try reducing a buggy test case to understand a problem better. To better explain what I mean by that, I recorded a little [video][] of myself reducing a test for a [bug][] in a [Bril][] interpreter.

    [bril]: https://capra.cs.cornell.edu/bril/
    [bug]: https://github.com/sampsyo/bril/issues/295
    [video]: https://vod.video.cornell.edu/media/1_65qzqqcd
---
<aside>
This post is the first in a series on <em>research skills</em>.
The plan is to demonstrate techniques that &ldquo;everyone knows&rdquo; because everyone, in fact, does not already know them.
</aside>

*Test-case reduction* is a useful research skill in my line of work.
We build lots of tools, and those tools are full of bugs: it's a normal part of the work to run into weird problems and to figure out what's going wrong.
Especially for people who are new to a research project:

* Reduced test cases are an extremely powerful communication tool for asking questions and getting help from people who have been around longer.
* When you don't have intuition yet for where bugs usually come from, reducing a test case can help with your guesswork.

The concept behind test-case reduction is really simple, but---maybe because it's so simple---sometimes it's hard to convey what I mean when I say, "can you try reducing that test?"
I think the idea might be easier to *show* than to *tell*.
This post will do both.

## The Recipe

Here are the steps in test-case reduction:

1. Run into a bug.
2. Capture your input that reproduces the bug. In our research, this input is usually a program. You'll need both the input program and a command you can run on the program to trigger the bug.
3. Delete stuff from your input. Try to delete as much as possible without making the bug go away. Remember to repeatedly run your command after each little deletion to be sure the bug still happens.
4. Stop when you don't think you can delete anything more without making the bug go away.

Now you have a reduced test case.
The hope here is that you and your collaborators will gain a flash of inspiration by staring at the reduced test case that leads you directly to the root cause.
Critically, that flash of inspiration was impossible with your original, big test case because it had lots of extraneous stuff in it that obscured the real problem.

Because this recipe is so mechanical, there are many good *automated test-case reducer* tools out there that can do it for you.
Automation is especially important for big programs.
Manually reducing test cases is still a useful skill: it helps to understand what the automated tools are doing for you, and it might be faster when your test case is already pretty small.
I'll demonstrate an automated reducer in a follow-up post.

## A Demo

<div class="embed">
  <iframe src="https://cdnapisec.kaltura.com/p/520801/sp/52080100/embedIframeJs/uiconf_id/31230141/partner_id/520801?iframeembed=true&entry_id=1_65qzqqcd" allowfullscreen></iframe>
</div>

This video tries to convey what it feels like to manually reduce a test case.
This one revealed a [bug][] in an interpreter for [Bril][], the instruction-based intermediate language we use in [Cornell's PhD-level compilers course][cs6120].
A student helpfully reported a [program][] that crashes the interpreter:

    $ bril2json < problem.bril | cargo run -- -p false false
    thread 'main' panicked at src/interp.rs:543:45:
    index out of bounds: the len is 0 but the index is 1

The [original program][program] from the report isn't very long---just 25 lines---but it still does enough stuff that it's hard to see exactly what went wrong in the interpreter.
To help find the problem, we want a program that does nothing other than trigger the bug.

In this demo, I deleted all but 4 lines:

    @main() {
      .lbl:
        jmp .lbl;
    }

Even if you've never seen Bril before, I hope you agree that it's now easy to imagine where to start looking in the interpreter for a fix.

To follow along at home, check out [revision `c543ae2` of the Bril repo][rev],
follow the README's instructions to get the basic Bril tools set up,
build the buggy interpreter with `cd brilirs ; cargo build`,
get [the original unreduced `problem.bril`][program],
and then try the command above to see the Rust panic message.

[bril]: https://capra.cs.cornell.edu/bril/
[bug]: https://github.com/sampsyo/bril/issues/295
[cs6120]: https://www.cs.cornell.edu/courses/cs6120/2023fa/
[rev]: https://github.com/sampsyo/bril/tree/c543ae2f253f32c6e59580ce1e843f6a2d86a9da
[program]: https://gist.github.com/sampsyo/681f9b5d5dfe5b5c0bf1cca51fa55a5a

## See Also

For more practical guides on reducing test cases, see [the WebKit project's instructions][wk]
or [Stack Overflow's guidelines for "Minimal, Reproducible Examples" (MREs)][so].
I'll demonstrate automated test-case reducers in a follow-up post,
but you can also check out [this Trail of Bits post demonstrating one][tob],
a wonderful [SIGPLAN blog post about reducers][sigplan],
or [David R. MacIver's extensive notes on the topic][drmaciver].
The famous [C-Reduce paper in PLDI 2012][creduce] is also worth your time.

[wk]: https://webkit.org/test-case-reduction/
[so]: https://stackoverflow.com/help/minimal-reproducible-example
[tob]: https://blog.trailofbits.com/2019/11/11/test-case-reduction/
[sigplan]: https://blog.sigplan.org/2021/03/30/an-overview-of-test-case-reduction/
[drmaciver]: https://www.drmaciver.com/2019/01/notes-on-test-case-reduction/
[creduce]: https://users.cs.utah.edu/~regehr/papers/pldi12-preprint.pdf
