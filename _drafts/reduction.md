---
title: "Manual Test Case Reduction"
excerpt: |
    I often find myself recommending to new researchers that they try reducing a buggy test case to understand a problem better. To better explain what I mean by that, I recorded a little video of myself reducing a test for a [bug][] in a [Bril][] interpreter.

    [bril]: https://capra.cs.cornell.edu/bril/
    [bug]: https://github.com/sampsyo/bril/issues/295
---
TK disclaimer
Want to write down basic techniques that "everyone knows" because, well, not everyone knows them.

*Test case reduction* is a useful research skill in my line of work.
We build lots of tools, and those tools are full of bugs: it's a normal part of the work to run into weird problems and to figure out what's going wrong.
Especially for people who are new to a research project, minimal test cases are an extremely powerful communication tool for asking questions and getting help from people who have been around for longer.

The concept behind test case reduction is really simple, but---maybe because it's so simple---sometimes it's hard to convey what I mean when I say, "can you try reducing that test?"
I think the idea might be easier to *show* than to *tell*.
This post will do both.

## The Recipe

Here are the steps in test case reduction:

1. Run into a bug.
2. Capture your input that reproduces the bug. In our research, this input is usually a program. You'll need both the input program and a command you can run on the program that exhibits the bug.
3. Delete stuff from your input. Try to delete as much as possible without making the bug go away. Remember to repeatedly run your command after each little deletion to be sure the bug still happens.
4. Stop when you don't think you can delete anything more without making the bug go away.

Now you have a reduced test case.
The hope here is that you and your collaborators will gain a flash of inspiration by staring at the reduced test case that leads you directly to the root cause.
Critically, that flash of inspiration was impossible with your original, big test case because it had lots of extraneous stuff in it that obscured the real problem.

## A Demo

<div class="embed">
  <iframe src="https://cdnapisec.kaltura.com/p/520801/sp/52080100/embedIframeJs/uiconf_id/31230141/partner_id/520801?iframeembed=true&entry_id=1_65qzqqcd" allowfullscreen></iframe>
</div>

This demo reduces a [bug][] in an interpreter for [Bril][], the instruction-based intermediate language we use in [Cornell's PhD-level compilers course][cs6120].
The [original program][program] that a student found isn't very long---just 25 lines---but it's still pretty hard to see what's wrong with the interpreter.
In this demo, I deleted all but 4 lines:

    @main() {
      .lbl:
        jmp .lbl;
    }

Even if you've never seen Bril before, I hope you agree that it's now pretty easy to imagine where to start looking in the interpreter for a fix.

To follow along at home, check out [revision `c543ae2` of the Bril repo][rev],
follow the README's instructions to get the basic Bril tools set up,
build the buggy interpreter with `cd brilirs ; cargo build`,
get [the original unreduced `problem.bril`][program],
and then try this command:

    $ bril2json < problem.bril | cargo run -- -p false false

You should see a Rust panic message.

[bril]: https://capra.cs.cornell.edu/bril/
[bug]: https://github.com/sampsyo/bril/issues/295
[cs6120]: https://www.cs.cornell.edu/courses/cs6120/2023fa/
[rev]: https://github.com/sampsyo/bril/tree/c543ae2f253f32c6e59580ce1e843f6a2d86a9da
[program]: https://gist.github.com/sampsyo/681f9b5d5dfe5b5c0bf1cca51fa55a5a

---

TK Particularly useful in research because (a) bugs are EVERYWHERE and (b) when onboarding with a project, sheer intuition probably won't find you the bug, so it's particularly helpful.

TK This one is just about manual reduction, quick n' dirty. Automated reduction coming in future post.
