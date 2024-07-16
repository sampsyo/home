---
title: "Automated Test-Case Reduction"
excerpt: |
    In a [previous post][manual-reduce], I used a simple interpreter bug to demonstrate the research skill of manually reducing test cases.
    This time, I show off the excellent [Shrinkray][] reducer to see how it can automate the same process.
    The tricky part when using automated test-case reducers is writing an *interestingness test* that actually does what you want.
    I list a few tricks that help me write good interestingness tests.

    [manual-reduce]: {{site.base}}/blog/reduction.html
    [shrinkray]: https://github.com/DRMacIver/shrinkray
---
<aside>
This post is the second in a series on <em>research skills</em>.
The plan is to demonstrate techniques that &ldquo;everyone knows&rdquo; because everyone, in fact, does not already know them.
</aside>

[Last time][manual-reduce], we saw how deleting stuff from a test case can be an easy and fun route to the root cause of a bug.
It's less easy and less fun when the test cases get big.
The inner loop of test-case reduction can get old quickly:
delete stuff, run the special command, check the output to decide whether to backtrack or proceed.
It's rote, mechanical, and annoyingly error prone.

Let's make the computer do it instead.
*Automated test-case reducers* in the [C-Reduce][] mold follow essentially the same "algorithm" we saw last time.
They obviously don't know your bug like you do, so they can't apply the intuition you might bring to deciding which things to delete when.
In return, automation can blindly try stuff much faster than a human can, potentially even in parallel.
So the trade-off is often worthwhile.

[manual-reduce]: {{site.base}}/blog/reduction.html
[c-reduce]: https://github.com/csmith-project/creduce

## Automating the Reduction Process

In the [manual test-case reduction "algorithm,"][manual-reduce] there are really only three parts that entailed any human judgment:

1. Picking a part of the test case to delete.
2. Looking at the command's output to decide whether we need to backtrack:
   that is, detecting when a given deletion either removed the bug-triggering code or broke the program entirely.
3. Deciding when to give up: when we probably can't reduce any farther without ruining the test case.

Everything else---running the command after every edit, hitting "undo" after we decide to backtrack---was pretty clearly mechanical.
Automated reducers take control of #1 and #3.
Picking the code to delete (#1) is just guesswork anyway; because we rely on step #2 to detect cases where a deletion went awry, it suffices to guess wildly using a pile of heuristics that have *some* probability of finding a useful deletion.
To decide when to stop (#3), reducers detect a fixed point:
they give up when the heuristics fail to find any more code they can safely delete.

That leaves us with #2: deciding whether a given version of the test case still works to reproduce the bug you're interested in.
Test-case reducers call this the *interestingness test* (in the [C-Reduce][] tradition), and they typically want you to write it down as a shell script.
To use a reducer, then, you usually just need two ingredients:
the original test case you want to reduce and the interestingness test script.

## Writing an Interestingness Test

This post will demonstrate how to use the excellent [Shrinkray][] reducer to debug [the same interpreter bug as last time][manual-reduce].
Shrinkray is language-neutral--and, in any case, no reducer knows about [Bril][].
I think it's pretty cool that reducers can work well even if they don't know anything about the syntax or semantics of the language they're working with.

Like any automated reducer, Shrinkray needs an interestingness test:
a little program that checks whether the bug we care about currently exists.
To make one, "all we need to do" is take the commands we were running manually to check for the bug and put them in a shell script.

The problem, as we'll discover, is that Shrinkray is a little like [the sorcerer's apprentice][tsa].
It will do exactly what we tell it to do, and it will do it with great enthusiasm.
Even tiny gaps in our instructions can lead to surprising results.
So, in my experience, writing a good interestingness test requires (a) a small bag of tricks that may not be intuitive your first time around, and (b) some trial and error.

I recorded a video of my own trial-end-error process, and I've also written it out in prose below.
Here's the video:

<div class="embed">
<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/J06BU6Fj6Qs?si=92qpmGfvC56p206E&amp;start=86&amp;end=101&amp;rel=0" allow="picture-in-picture" allowfullscreen></iframe>
</div>

Hang on; I'm being told that this is the wrong video.
Let's try that again:

<div class="embed">
  <iframe src="https://cdnapisec.kaltura.com/p/520801/sp/52080100/embedIframeJs/uiconf_id/31230141/partner_id/520801?iframeembed=true&entry_id=1_w0bwzism" allowfullscreen></iframe>
</div>

[shrinkray]: https://github.com/DRMacIver/shrinkray
[bril]: https://capra.cs.cornell.edu/bril/
[tsa]: https://en.wikipedia.org/wiki/The_Sorcerer's_Apprentice

## Walkthrough

In essence, an interestingness test is a script that automates the
commands we ran repetitively (with the "up arrow" at the shell prompt) during
[manual reduction][manual-reduce].
Here's the main command we repeatedly ran then:

    $ bril2json < problem.bril | cargo run -- -p false false

I started by just putting this command into a shell script, `interesting.sh`.
[Shrinkray][] wants our script to work from any directory, so I used an absolute
path to the executable:

    #!/bin/sh
    bril2json < $1 | /Users/fabian/Documents/cu/bril/brilirs/target/debug/brilirs -p false false

I also used `$1` for the filename; Shrinkray passes the current version of
the test file as an argument there.
Following the [C-Reduce][] tradition, interestingness tests use a
counter-intuitive (but extremely useful) convention:
the script must exit with status 0 when the test is *interesting* (exhibits
the bug) and nonzero when it's not (e.g., it's bug-free or ill-formed).
So far, our command crashes with a nonzero status---specifically, a Rust
panic---when it *is* interesting, which is the opposite of what we want.

### Trick 1: Shell Negation

So here's a trick you can use in interestingness tests in general:
try the
[shell's negation operator, `!`,][bash-pipe] to invert the sense of the exit status.
Like this:

    #!/bin/sh
    ! ( bril2json < $1 | /Users/fabian/Documents/cu/bril/brilirs/target/debug/brilirs -p false false )

Now our tests says the input is interesting (status 0) when the interpreter
*does* crash.
Let's try it:

    $ shrinkray interesting.sh problem.bril

With this script, Shrinkray immediately reduces our file down to nothing.
And it's not wrong: a zero-byte file does elicit an error from our
interpreter!
As usual, the sorcerer's apprentice did exactly what we said, not what
we wanted, and did it with wondrous alacrity.

### Trick 2: The "Not Bogus" Check and `set -e`

This leads us to our second trick for writing interestingness tests:
before you try to expose the bug, include a "not bogus" check.
You want to make sure your test is well-formed in some sense:
it parses successfully,
or it doesn't throw an exception,
or whatever else.

In our case, we're debugging a crashy interpreter, but we also have access to
a [reference interpreter][brili] that doesn't have the same bug.
So we can add a "not bogus" check that requires any well-formed test to
succeed in that reference interpreter.
Here's a new script that includes that check:

    #!/bin/sh
    set -e
    bril2json < problem.bril | brili false false
    ! ( bril2json < $1 | /Users/fabian/Documents/cu/bril/brilirs/target/debug/brilirs -p false false )

Check out that `set -e` line, which is super useful for interestingness
scripts and "not bogus" checks in particular.
[The `-e` option][bash-set] makes a shell script immediately abort with an
error (signalling "uninteresting") when any line fails.
In `-e` mode, you're free to write a bunch of commands that should succeed in
the normal case but might fail when the test really goes off the rails:
as soon as any command fails, the script will bail out and indicate that we're
on the wrong path.
So in my script here, we're requiring the `brili` (reference interpreter)
invocation to succeed before we even bother trying to expose the
bug.

Let's restore our test input from the backup Shrinkray saved for us and try
again:

    $ cp problem.bril.bak problem.bril
    $ shrinkray interesting.sh problem.bril

Shrinkray will again sorcerer's-apprentice its way into a much too small test
case.
Not zero bytes this time, but too small to be useful.
To see what went wrong, we can run our two commands ("not bogus" and bug
check) manually:

    $ bril2json < problem.bril | brili false false
    $ bril2json < problem.bril | ./target/debug/brilirs -p false false
    error: Expected a primitive type like int or bool, found l

Shrinkray has isolated for us a *different error* with the same shape, i.e.,
the reference interpreter accepts the program but the buggy interpreter
rejects it.
This one is not really a bug: it's just a case where the second interpreter is
more strict than the first.
And even if this misalignment is curious, it's not the bug we were looking
for.

### Trick 3: `grep` for Your Error Message

So here's trick number three for writing interestingness tests:
use `grep` to check for the error message we actually want.
In our case, the program panics with an "out of bounds" message.
Let's restore from backup and grep for that in both stdout and stderr like this:

    $ cp problem.bril.bak problem.bril
    $ bril2json < problem.bril | ./target/debug/brilirs -p false false 2>&1 | grep 'out of bounds'

Conveniently, `grep` does exactly what you want for an interestingness test:
its exit status is 0 when it finds the string (interesting because this is the
bug we are looking for)
and 1 when it fails to find the string (some other error).
So here's our new script:

    #!/bin/sh
    set -e
    bril2json < problem.bril | brili false false
    bril2json < $1 | /Users/fabian/Documents/cu/bril/brilirs/target/debug/brilirs -p false false 2>&1 | grep 'out of bounds'

With this script, Shrinkray does a great job and reduces quite a bit of code,
which is awesome.
One thing it can't reduce, however, is the way the program uses arguments.
It's actually hopeless for Shrinkray to remove the arguments because it would
require changing the interestingness test script to remove those `false false`
command-line arguments we keep on passing.

### Trick 4: Occasional Manual Help

We can help Shrinkray out a bit by turning those inputs into constants in the code.
We can replace `main`'s arguments with two new Bril instructions:

    b0: bool = const false;
    b1: bool = const false;

Accordingly, we need to change our interestingness test to pass zero arguments
to both interpreter invocations:

    #!/bin/sh
    set -e
    bril2json < problem.bril | brili
    bril2json < $1 | /Users/fabian/Documents/cu/bril/brilirs/target/debug/brilirs -p 2>&1 | grep 'out of bounds'

At this point, it's probably a good idea to do `./interesting.sh problem.bril`
to manually check that everything's in order.

### Success!

Everything looks good in this case, so we can fire up Shrinkray again.
It gives us this reduced test case:

    @main{
        jmp .A;
        .A:ret;
        .A:jmp  .A;
    }

This is not quite the same as the reduced version we arrived at with [manual
reduction][manual-reduce].
The one we wrote found last time actually an infinite loop---so it wouldn't
pass our interestingness test!
So this one is actually a little more useful in that sense: you can run it
through the reference interpreter to immediately see what it's *supposed* to
do.
It's sort of weird that the reduced test has a multiply defined label, but
apparently neither interpreter cares about that...
if we wanted to, we could imagine avoiding this by adding a second "not bogus"
check based on some static error checking.

[bash-pipe]: https://www.gnu.org/software/bash/manual/html_node/Pipelines.html
[bash-set]: https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
[brili]: https://capra.cs.cornell.edu/bril/tools/interp.html
