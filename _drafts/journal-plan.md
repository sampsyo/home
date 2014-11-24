---
title: "Bootstrapping Credibility, or: My Secret Evil Superplan for World Domination"
excerpt: |
    I've written before about... xxxx
---
If you were to start an [independent, lightweight, open-access journal][journals], the main obstacle will be bootstrapping credibility. How do you go from an unknown, probably-[spam][multiconference], scare-quotes "journal" with zero issues to a venue that people might actually consider submitting to?

[multiconference]: http://en.wikipedia.org/wiki/World_Multiconference_on_Systemics,_Cybernetics_and_Informatics
[journals]: {{site.base}}/blog/newjournals.html

Part of the answer is clearly brute force: coerce good people into reviewing or submitting on blind faith, or be so famous that your name alone engenders reverence and awe. But the design of the venue's purpose and operation also matter. There must be better ways to begin than blithely going head-to-head with the venues we already have and love/hate.

Here are two ideas for making a new venue easier to trust---and, incidentally, more exciting.

## Incentivize Good Reviews

Reviewing in computer science is not as good as it could feasibly be.
I can't provide hard evidence for this perspective, since reviews are generally secret and sensitive, but [I](http://cacm.acm.org/blogs/blog-cacm/123611-the-nastiness-problem-in-computer-science/fulltext) [am](http://portal.acm.org/citation.cfm?id=1462581) [not](http://www.sigcomm.org/sites/default/files/SIGCOMM%2009%20Comm%20FB.pdf) [the](http://cacm.acm.org/blogs/blog-cacm/100284-how-should-peer-review-evolve/fulltext) [only](http://ccr.sigcomm.org/online/files/p3-v41n3ed-keshav-editorial.pdf) [one][anderson] [who](http://pages.cs.wisc.edu/~naughton/naughtonicde.pptx) [has](http://www.annemergmed.com/article/S0196-0644%2810%2901266-7/abstract) [it][fortnow].

Reviewing is not problematic because reviewers are lazy or malicious; they are almost universally not. It's primarily because our conferences are unintentionally architected to incentivize quick decisions and conservatism. [High PC load][regehr], [short PC meetings][fortnow], [secret reviews][crowcroft], [limited author--reviewer dialogue][godfrey], and the [conference-to-conference resubmission cycle][anderson] all contribute to an environment where the expedient reviewer looks for a low-hanging reason to reject (or delegates to a student to do so).

[regehr]: http://blog.regehr.org/archives/306
[godfrey]: http://youinfinitesnake.blogspot.com/2011/08/whats-wrong-with-computer-science.html
[fortnow]: http://cacm.acm.org/magazines/2009/8/34492-viewpoint-time-for-computer-science-to-grow-up/fulltext
[anderson]: http://www.pgbovine.net/PhD-memoir/anderson-09.pdf
[crowcroft]: https://www.usenix.org/legacy/event/wowcs08/tech/full_papers/crowcroft/crowcroft.pdf

On the assumption that authors are tired of reading rushed evaluations and reviewers are tired of writing them, a new venue could make itself attractive by carefully constructing its process to invert the incentives. I envision a journal where:

* Reviewers produce a public, signed review the accompany every accepted paper. The goal of reviewing would be outward-facing, to add peer context to the authors' own "marketing," rather than inward-facing, to convince a program committee to accept or reject. Attaching names to reviews will create a way for reviewers to cultivate a reputation as a careful observer of others' work, a skill that we do not celebrate enough. (Reviewers would remain anonymous before publication to avoid retaliation.)
* A rolling deadline keeps reviewer load low. Instead of organizing papers into batches---conference programs or journal issues---the venue should review and publish papers without a fixed schedule. Each reviewer will be responsible for one or two papers at a time rather than dozens as current PC members are.
* Iterated revision is a dialogue between authors and reviewers. As in current journals, reviewers should be able to recommend substantial changes to the paper---*and then review those changes* after the author makes them. A good final product needs input from invested outsiders, of which the conference system's reject-and-resubmit cycle is a remarkably inefficient implementation.

The prospect of a better way to go about peer review attracts me as a reviewer, and the promise of careful reviewing attracts me as an author. I hope the same is true of the community in general.

## Address an Underserved Market

To avoid competing with existing conferences, a new venue should focus on kinds of papers that they do not serve well. Some subgenres that are a poor match for conferences in my community include:

* Interdisciplinary work: i.e., research that is always "too *X* for a *Y* conference, and too *Y* for an *X* conference." My community has [ASPLOS][], but this means that work that fits well neither at [PLDI][] nor at [ISCA][] has only one conference a year.
* Implementation-heavy work: papers that bridge the gap between research and practice. This kind of work is notorious for garnering informal respect at the same time as reviews that complain of a lack of novelty.
* Pre-publication ideas: short (say, three-page) gists of an upcoming project as a way to elicit early-stage feedback.
* Post-publication recognition: authors nominate papers that have already appeared in an established conference. The venue recognizes and adds peer perspective to the "best" of the program, not unlike [SIGPLAN Research Highlights][] or [IEEE MICRO Top Picks][]. (This idea is due to my advisor, [Luis][], who's running Top Picks this year along with [Karin Strauss][].)
* A student-focused forum: for instance, single-author papers in which students envision long-term research agendas (which their advisors may not approve of).

[SIGPLAN Research Highlights]: http://www.sigplan.org/Highlights/
[IEEE MICRO Top Picks]: https://sites.google.com/site/ieeemicro/call-for-papers/cfp---top-picks-2015-1
[Karin Strauss]: http://research.microsoft.com/en-us/people/kstrauss/
[Luis]: http://homes.cs.washington.edu/~luisceze/
[PLDI]: http://conf.researchr.org/home/pldi2015
[ISCA]: http://www.ece.cmu.edu/calcm/isca2015/
[ASPLOS]: http://asplos15.bilkent.edu.tr

A new venue can build initial credibility by attracting papers that can't go anywhere else. But even if it starts modestly---by highlighting existing publications, say---the venue can capitalize on an initial reputation to build something bigger. I am optimistic enough to believe that a niche publication that *does it right* could eventually expand to displace an established venue---or at least encourage it to evolve.
