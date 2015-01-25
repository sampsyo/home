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

For Top Picks 2014, [Luis][] and [Karin][] tried something new in the selection process: they asked for [community input][cinput], meaning that even a lowly grad student could submit short comments on each paper. This inevitably made me play "fantasy Top Picks committee" in my mind. And the other night, [Tim][] suggested that folks should share their own Pitchforkesque year-end top-ten lists.

The architecture community needs more of this kind of research commentary. So let's give this a shot.

[toppicks]: http://www.computer.org/web/computingnow/micfp3
[luis]: http://homes.cs.washington.edu/~luisceze/
[karin]: http://research.microsoft.com/en-us/people/kstrauss/
[cinput]: http://homes.cs.washington.edu/~luisceze/toppicks15-community-input.md.html
[tim]: http://www.cs.ucsb.edu/~sherwood/

## My 2014 Top Picks

My favorite papers from the 2014 Top Picks slate (in alphabetical order):

* ["Aladdin: a Pre-RTL, Power-Performance Accelerator Simulator Enabling Large Design Space Exploration of Customized Architectures,"][aladdin] by Yakun Sophia Shao, Brandon Reagen, Gu-Yeon Wei, and David Brooks.

  For the rare feat of publishing a no-holds-barred research tool for other architects. The idea is simple: Aladdin mashes up C-to-gates tools with a pile of heuristics. It sidesteps the persistent weaknesses of HLS by solving a different problem. Extra points for inventing something useful that we didn't know we needed.

* ["Race Logic: a Hardware Acceleration for Dynamic Programming Algorithms,"][racelogic] by Advait Madhavan, Timothy Sherwood, and Dmitri Strukov.

  For expanding the definition of computation with a deeply wacky yet eminently implementable idea. Race logic is an exemplar of the balance between creativity and rigor that makes architecture research exciting.

* ["Flipping Bits in Memory Without Accessing Them,"][flipping] by Yoongu Kim, Ross Daly, Jeremie Kim, Chris Fallin, Ji Hye Lee, Donghyuk Lee, Chris Wilkerson, Konrad Lai, and Onur Mutlu.

  For revealing a shocking and terrifying harbinger of the end of useful DRAM scaling.

* ["Heterogeneous-Race-Free Memory Models,"][hrf] by Derek Hower, Blake Hechtman, Bradford Beckmann, Benedict Gaster, Mark Hill, Steven Reinhardt, and David Wood.

  For asking the question: What is the *minimum* common memory consistency model that heterogeneous CPU/GPU hybrid systems should enforce? Put another way, what is the equivalent to "sequential consistency for race-free programs" on homogeneous multiprocessors? I don't agree with all of this paper's answers, but I strongly agree with the question.

* ["Load Value Approximation for Tackling Massive Data Sets,"][lva] by Joshua San Miguel, Mario Badr, Natalie Enright Jerger.

  For an thorough design-space exploration that converges on an elegant, effective implementation of approximation. Approximate computing is close to my heart and LVA is an exemplary execution.

* ["Memory Persistency,"][persistency] by Steven Pelley, Peter M. Chen, and Thomas F. Wenisch.

  For drawing a connection between memory ordering in multiprocessors and the equivalent in systems that mix non-volatile main memory with volatile caches. The future seems inevitable: systems will get non-volatile main memories, they will combine them with volatile on-chip state, and programmability bugbears will abound. As with the HRF paper, I love this paper for the questions that "memory persistency" poses.

* ["PipeCheck: Specifying and Verifying Microarchitectural Enforcement of Memory Consistency Models,"][pipecheck] by Daniel Lustig, Michael Pellauer, and Margaret Martonosi.

  For demonstrating a new level of abstraction for verifying a microarchitecture, for being the first [Coq][] paper I know of to appear in ISCA or MICRO, and for fixing no-shit memory model bugs in [gem5][].

* ["Q100: The Architecture and Design of a Database Processing Unit,"][q100] by Lisa Wu, Andrea Lottarini, Timothy Paine, Martha Kim, and Kenneth Ross.

  For demonstrating a workflow for designing domain-specific accelerators that emphasizes empiricism over intuition. The end result is a model of thorough accelerator evaluation.

[racelogic]: http://dl.acm.org/citation.cfm?id=2665747
[q100]: http://dl.acm.org/citation.cfm?id=2541961
[pipecheck]: https://www.princeton.edu/~dlustig/dlustig_MICRO14.pdf
[persistency]: http://dl.acm.org/citation.cfm?id=2665712
[lva]: http://www.eecg.toronto.edu/~enright/lva-micro2014.pdf
[hrf]: http://dl.acm.org/citation.cfm?id=2541981&preflayout=tabs
[flipping]: http://dl.acm.org/citation.cfm?id=2665726
[aladdin]: http://dl.acm.org/citation.cfm?id=2665689
[gem5]: http://gem5.org/Main_Page
[coq]: https://coq.inria.fr

## Honorable Conflicts

I had clear conflicts with two great submissions to Top Picks. I can't in good conscience list them above, but I also can't go without mentioning them. Both are veritable landmarks:

* ["A Reconfigurable Fabric for Accelerating Large-Scale Datacenter Services,"][catapult] by Andrew Putnam, Adrian Caulfield, Eric Chung, Derek Chiou, Kypros Constantinides, John Demme, Hadi Esmaeilzadeh, Jeremy Fowers, Gopi Prashanth Gopal, Jan Gray, Michael Haselman, Scott Hauck, Stephen Heil, Amir Hormati, Joo-Young Kim, Sitaram Lanka, Jim Larus, Eric Peterson, Simon Pope, Aaron Smith, Jason Thong, Phillip Yi Xiao, and Doug Burger.

* ["Uncertain&lt;T&gt;: A First-Order Type for Uncertain Data,"][uncertaint] by James Bornholt, Todd Mytkowicz, and Kathryn S. McKinley.

[catapult]: http://research.microsoft.com/pubs/212001/Catapult_ISCA_2014.pdf
[uncertaint]: http://research.microsoft.com/pubs/208236/asplos077-bornholtA.pdf

## Your Turn?

These lists are subjective and noisy---I'd be shocked if your list is the same as mine or the official picks (whenever they're announced). So concoct your own! And then [email me][me] so I can link to your post here.

[me]: mailto:asampson@cs.washington.edu
