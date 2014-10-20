---
title: "A Grading Rubric for Bug Reports"
kind: article
layout: post
excerpt:
    The world has no shortage of frustratingly unhelpful bug reports, but it can be hard to explain what makes them bad---and how they can improve. Try scoring your next report on this handy five-point scale.
---
So you've written a bug report. Congratulations, and thank you for contributing to the project!

You're probably wondering how your bug report stacks up against other denizens of open source. Are you a changelog champion or a software scoundrel? Use this convenient rubric to score yourself on a five-point scale.

## Zero Points: The Solipsist

You wrote down your problem in the first terms that came to mind.

> The ficus-blitzer crashes.

You believe your perspective to be the only one worth considering. You made no effort for think about anyone else but yourself. You may be a sociopath.

## One Point: The Novice

You may have read a bug report before and you're making some minimal effort to explain what happened. But your sense of appropriate detail is uncalibrated:

> Whenever I run the ficus-blitzer to blitz any fica, it says "NullFicusError" and crashes.

It's okay! Don't worry! Bug reporting is a learned skill. We'll get you there.

## Two Points: The Literalist

You've begun to accept the Gospel of Detail into your heart. If there's a traceback, you include it. But the associated context is a bare-bones, Hemingwayian affair:

> I ran this:
>
>     blitz --ficus ficus1.doc
>
> And it did this:
>
>     NullFicusError on line 13 in blitz.hs
>     could not blitz any fica
>
> I have the blitzer engine configured to use eight chads.

For a minority of bugs, this is enough. You've shown the bare minimum for us to have a shot at understanding what's wrong. But there's probably no hope of reproducing anything but the simplest problem.

Subtract half a point if you have all the output but neglected to paste the input.

## Three Points: The Completionist

You give the Literalist a run for their money by including even *more* detail about what happened:

> Here's a link to my configuration file. Here's the file `ficus1.doc` file I was using as input. This is my version of FicusBlitz:
>
>     $ blitz --version
>     FicusBlitz 96.4.12.beta-8
>
> I'm running on Ubuntu 19.07 with Python 4.2.1 and literally no other software installed, not even a kernel.

Given an infinite amount of time, we can recreate your exact setup and track down the bug.

## Four Points: The Theorist

You have a guess about what might be going wrong:

> That ficus file contains a few French fica, so there are áccêntèd vowels in their names. Maybe this is a Unicode thing.

You may have even lightly tested the hypothesis:

> I have another ficus file with exclusively British fica (see attached) and that works fine. It also works if I omit the `--blitz` flag, but I really need to blitz those fica.

Your critical thinking makes our job an order of magnitude easier. It efficiently encodes valuable debugging intuition. Your hypothesis is falsifiable, so we may give you a counter-example and ask you to keep digging.

## Five Points: The Godsend

You're an emissary from another world. In your world, bug reporting is as ingrained a skill as walking while texting is in ours:

> I narrowed down the crash to the 416th ficus in that file---here's a file that contains only that crashy ficus. I cleared out all the other metadata to show that the crash has to be related to the name field. If I change its name from Sébastien to Sebastien, the crash goes away. I've also attached the *accent-aigu*--free, crash-free version of the file for comparison.
>
> The crash doesn't seem to be platform-specific; I tried it on my Amiga 500 with the same result.

Full credit! Your thorough investigation is probably *more* helpful than a proposed fix. You didn't need to get your hands dirty trying to understand the code, and for us, this will make the fix a *small matter of programming*.
