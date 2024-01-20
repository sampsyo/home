---
title: "Automated Test-Case Reduction"
excerpt: |
    TK
---
<aside>
This post is the first in a series on <em>research skills</em>.
The plan is to demonstrate techniques that &ldquo;everyone knows&rdquo; because everyone, in fact, does not already know them.
</aside>

[Last time][manual-reduce], we saw how deleting stuff from a test case can be an easy and fun route to the root cause of a bug.
It's less easy and less fun when the test cases get big.
The cycle can get old quickly:
delete stuff, run the special command, check the output to decide whether to backtrack or proceed.
It's rote, mechanical, and annoyingly error prone.

Let's make the computer do it instead.
*Automated test-case reducers* follow essentially the same "algorithm" we saw last time.
They obviously don't know your bug like you do, so they can't apply the intuition you might bring to deciding which things to delete when.
In return, automation can blindly try stuff much faster than a human can, potentially even in parallel.
So the trade-off is often worthwhile.

TK link to some examples above? C-reduce...

## Automating the Reduction Process

In the [manual test-case reduction "algorithm"][manual-reduce], there are really only three parts that entailed any human judgment:

1. Picking a part of the test case to delete.
2. Looking at the command's output to decide whether we need to backtrack.
3. Deciding when to give up: when we probably can't reduce any farther without ruining the test case.

Everything else---running the command after every edit, hitting "undo" after we decide to backtrack---was pretty clearly mechanical.
Automated reducers take control of #1 and #3.
Picking the code to delete is guesswork anyway---we'll catch cases where deletion went awry in step #2 anyway---so it suffices to use a bunch of heuristics that only work out occasionally.
To decide when to stop, reducers detect a fixed point:
they give up when the heuristics fail to find any more code to delete.

That leaves us with #2: deciding whether a given version of the test case still works to reproduce the bug you're interested in.
Test-case reducers call this the *interestingness test* (in the [C-Reduce][] tradition), and they typically want you to write it down as a shell script.
To use a reducer, then, you usually just need two ingredients:
the original test case you want to reduce and the interestingness test script.

## Writing an Interestingness Test

TK the interesting part of using a reducer is the interestingness test
TK sourcer's apprentice

TK there are also language-specific reducers, but I think it's remarkable how well a language-neutral reducer can do. No reducer knows about Bril specifically, for example, and yet...

Here's the video:

<div class="embed">
<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/J06BU6Fj6Qs?si=92qpmGfvC56p206E&amp;start=86&amp;end=101&amp;rel=0" allow="picture-in-picture" allowfullscreen></iframe>
</div>

Hang on; I'm being told that this is the wrong video.
Let's try that again:
