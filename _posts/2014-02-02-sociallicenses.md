---
title: Setting Expectations for Academic Code Releases
kind: article
layout: post
excerpt: |
    There are lots of reasons to release code as an academic. Be careful to think about which ones apply to your code release---and communicate them with the world.
---
Source code releases are an essential part of good computer systems research. Every paper that has a system-building or experimental component---anything that's not purely theoretical, in other words---should come with code.

While this point of view is getting more popular, code releases are still the exception rather than the rule. I think part of the reason is, paradoxically, that there are too many good, diverse justifications for releasing code. There are basic reasons that apply to everyone and secondary reasons that don't. If we can be clearer about which justifications apply when, we might release more code and avoid some dangerous time sinks.

The main reasons for code releases are:

* **Reproducibility.** Other researchers should be able to run exactly the code you ran for your experiments and get the same results.
* **Debuggability.** All code (well, [almost all][verification]) has bugs. Research code probably has more bugs than most. It's unrealistic to hope that other people will find all your bugs for you, of course, but if code is locked away in a digital prison-cave after publication, those bugs don't stand a chance of being found.
* **Collaboration.** We sometimes forget it, but everyone in academia is on the same side. The work you put into your code gains value when it helps other people do good research. It might not always be obvious how other people can benefit from your code, but in my experience, even components I thought were special-purpose one-offs have been reused.

[verification]: http://en.wikipedia.org/wiki/Formal_verification

These essential reasons are enough. When you finish a research project, upload a tarball to your Web site and you'll meet these goals. [Messy code is OK][crapl]; even buggy code is a fact of life. If you spend too much time cleaning up, you damage your reproducibility.

[crapl]: http://matt.might.net/articles/crapl/

There are other good reasons to release code that apply in some cases. For example:

* **Proof of utility.** You've built a tool that should be useful---that's the value proposition in your paper. To prove it, you should distribute the tool and hope that people put it to work; if you can't do that, then perhaps the tool isn't really all that useful.
* **Dissemination.** People are more likely to be interested in running a demo than reading a paper. If you can release a program that demonstrates your idea, your research might garner more attention.

This second set of reasons is less universal than the first set. Not all papers that have experiments also have tools. A "tool" that just collects data for a longitudinal performance study, for example, might not have a bright future in industry. Even system-building papers can be high-quality work when their software artifact is preliminary. You might have a compiler that only works on a toy subset of a language, for example. In these cases, there might not be much value in trying to disseminate a prototype.

But it's still important that other researchers be able to reproduce, debug, and reuse your work. The inapplicability of the second set of justifications doesn't release anyone from the first set.

I think researchers would be better off if we explicitly acknowledged the difference between code releases meant for research and those meant for wider dissemination. I've heard some people explain their avoidance of code releases because it will require lots of cleanup effort and create an ongoing maintenance burden. This is a completely justified fear. Some of my public code has generated mountains of email asking for help I don't have time to give. But perhaps if we were to explicitly mark code as "for research purposes only," we can make our ongoing obligations clear---at least to ourselves---and justify releasing more code more quickly.

The "dusty tarball on an academic's Web site" antipattern is so frequently derided that it's almost a cliché. Sometimes this is justified---the authors should be disseminating a truly valuable tool. But sometimes a bitrotted tarball is not the alternative to a maintained, supported software package---it's the alternative to no code at all.

For future code releases, I plan on making my intentions clearer. The README in my next repository should set expectations before even giving installation instructions. I'm starting to think of this as the *social license* for the code: the (real) license defines what you're allowed to do with the code; the social license describes what I *hope* you do. I think this will help me get code out into the world more quickly---and maybe cut down on that deluge of email.
