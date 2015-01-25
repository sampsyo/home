---
title: "My Top Picks from the 2014 Computer Architecture Conferences"
excerpt: |
    [IEEE Micro Top Picks][toppicks] is an annual special issue that collects the best of each year's computer architecture conferences. This year, [the][luis] [chairs][karin] experimented with a [community input process][cinput], which meant that even a lowly grad student could read the submissions and contribute comments. Here are my favorite papers from the year.

    [toppicks]: http://www.computer.org/web/computingnow/micfp3
    [luis]: http://homes.cs.washington.edu/~luisceze/
    [karin]: http://research.microsoft.com/en-us/people/kstrauss/
    [cinput]: http://homes.cs.washington.edu/~luisceze/toppicks15-community-input.md.html
---
I love reading each year's [IEEE Micro Top Picks][toppicks] special issue. It's the lazy computer architect's source for a distilled handful of must-read papers from the last year.

For Top Picks 2014, [Luis][] and [Karin][] tried something new in the selection process: they asked for [community input][cinput], meaning that even a lowly grad student could submit short comments on each paper. This inevitably made me play "fantasy Top Picks committee" in my mind. And the other night, [Tim][] suggested that folks should put together their own Pitchforkesque year-end top-ten lists

The architecture community needs more of this kind of research commentary. So let's give this a shot.

[toppicks]: http://www.computer.org/web/computingnow/micfp3
[luis]: http://homes.cs.washington.edu/~luisceze/
[karin]: http://research.microsoft.com/en-us/people/kstrauss/
[cinput]: http://homes.cs.washington.edu/~luisceze/toppicks15-community-input.md.html
[tim]: http://www.cs.ucsb.edu/~sherwood/

## My 2014 Top Picks

My favorite papers from the 2014 Top Picks slate (in alphabetical order):

* ["The Aladdin Approach to Accelerator Design and Modeling,"][aladdin] by XXX. For the rare feat of publishing a no-holds-barred research tool for other architects. The idea mashes up C-to-gates tools with a pile of heuristics. It sidesteps the persistent weaknesses of HLS by solving a different problem. Extra points for inventing something useful that we didn't know we needed.
* ["Dynamic Programming through Hardware Race Conditions,"][racelogic] by Advait Madhavan, Timothy Sherwood, and Dmitri Strukov.
* ["Flipping Bits in Memory Without Accessing Them,"][bits] by XXX. For revealing a shocking and terrifying harbinger of the end of useful DRAM scaling.
* ["Heterogeneous-Race-Free Memory Models,"][hrf] by XXX. For asking the question: What is the *minimum* common memory consistency model that heterogeneous CPU/GPU hybrid systems should enforce? Put another way, what is the equivalent to "sequential consistency for race-free programs" on homogeneous multiprocessors? I don't agree with all of this paper's answers, but I strongly agree with the question.
* ["Load Value Approximation for Tackling Massive Data Sets,"][lva] by XXX, for an incredibly thorough design-space exploration that converges on an elegant, effective implementation of approximation. Approximate computing is close to my heart and LVA is an exemplary execution.
* ["Memory Persistency,"][persistency] by XXX. For drawing a connection between memory ordering in multiprocessors and the equivalent in systems that mix non-volatile main memory with volatile caches. The future seems inevitable: systems will get non-volatile main memories, they will combine them with volatile on-chip state, and programmability bugbears will abound. As with the HRF paper, this one is more significant for the question it poses than for the answers it provides.
* ["PipeCheck: Specifying and Verifying Microarchitectural Enforcement of Memory Consistency Models,"][pipecheck] by XXX. For demonstrating a new level of abstraction for verifying a microarchitecture, for being the first [Coq][] paper I know of to appear in ISCA or MICRO, and for fixing no-shit memory model bugs in [gem5][].
* ["Q100: The Architecture and Design of a Database Processing Unit,"][q100] by XXX. For demonstrating a workflow for designing domain-specific accelerators that emphasizes empiricism over intuition. The end result is a model of thorough accelerator evaluation.

[gem5]: http://gem5.org/Main_Page
[coq]: https://coq.inria.fr

## Honorable Conflicts

I had clear conflicts with two great submissions to Top Picks. I can't in good conscience list them above, but I also can't go without mentioning them:

* ["A Reconfigurable Fabric for Accelerating Large-Scale Datacenter Services,"][catapult] by XXX. The "Catapult" paper is a landmark.
* ["Uncertain&lt;T&gt;: A First-Order Type for Uncertain Data,"][uncertaint] by XXX.

## Your Turn?

These lists are subjective and noisy---I'd be shocked if your list is the same as mine or the official picks (whenever they're announced). So concoct your own! And then [email me][me] so I can link to your post here.

[me]: mailto:asampson@cs.washington.edu
