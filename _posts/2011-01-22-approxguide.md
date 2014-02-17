---
title: Some Literature on Application-Level Error Exposure
kind: article
layout: post
ignore: _x
bibliography: media/approximation.bib
excerpt: |
    My recent research has focused on power efficiency gains available by
    compromising on strict correctness guarantees. That is, many applications
    (like audio or video processors) can tolerate occasional errors in their
    execution---and permitting some errors can yield large gains in power
    or performance. Many researchers have come to a similar realization
    independently, so here I'll try to collect together a few different
    approaches to the issue.
---

Many modern resource-intensive applications can be considered "soft": their
computation is inherently approximate. A lossy image or audio compressor, for
example, must deal with built-in uncertainty in its data. And if the algorithm
makes a few "mistakes"---gets a few pixels wrong, for instance---the user is
unlikely to notice (depending on the situation). Machine learning algorithms,
vision applications, and signal processing can also exhibit this error-tolerant
property.

Many recent research projects have taken advantage of this "soft" category of
applications. The approaches to this problem, however, have been varied and have
come from several different computer science and electrical engineering research
communities. This is a compilation of different views on the issue. It's
unlikely to be complete, though, so please [get in
touch](mailto:asampson@cs.washington.edu) if you know of other relevant work!


### Studies of Application-Level Error Tolerance

A few papers focus on exploring the
tolerance of selected applications to transient faults. These studies run some
applications under some kind of simulation infrastructure that injects faults
and measure the resulting output QoS.
The papers then advocate for further
exploration into mechanisms for exploiting this quality.

Xuanhua Li and Donald Yeung from Maryland authored a
[series of papers](http://maggini.eng.umd.edu/soft-computing/) in this vein
([2006](#li06), [2007](#li07), [2008](#li08)).
de Kruijf ([2009](#dekruijf-selse09)) focuses
on disparity between critical and non-critical instructions. Wong
([2006](#wong-selse06))
focuses on probabilistic inference applications in particular.

The consensus among these papers is that some parts of the application (some
memory regions, some instructions) are much more tolerant to error than others.
For instance, corruption in a jump target pointer is likely to be catastrophic,
but faults in image pixel data is usually benign.

Two of the papers mentioned above were published in a workshop called [Silicon
Errors in Logic: System Effects (SELSE)](http://softerrors.info/selse/), which
is as close as this topic has to a home.


### Architectural Approximation Techniques

The architecture and VLSI communities have contributed a few techniques for
saving energy (and sometimes performance) with circuit- and architecture-level
techniques.

One paper ([Tong 2000](#bitwidthred)) examines adapting the floating-point mantissa width to suit
the application. Because FP computations implicitly incorporate imprecision in
the form of rounding, coarsening the imprecision has a predictably mild effect
on some applications. Similarly, Alvarez ([2005](#fuzzymemo)) exploits
FP operation memoization,
a correctness-preserving energy-saving technique, to prove "fuzzy memoization"
that compromises some accuracy and saves even more energy. A paper 
by Phillip Stanley-Marbell ([2009](#smitw2009)) at IBM exploits number
representations to mitigate
the semantic effect of bit flips; the work seeks to provide guaranteed bounds on
each value's deviation from its "correct" value.

[A group at Illinois](http://passat.crhc.illinois.edu/projects.html) proposes
"stochastic processors"
([Narayanan 2010](#stochasticproc)), which should include logic circuits
(i.e., ALUs and FPUs) that are amenable to voltage-overscaling, possibly
alongside units with strict guarantees. Their group page contains a long list
of [related work](http://passat.crhc.illinois.edu/publications.html). A paper
in HPCA 2010 ([Kahng 2010](#hpca10cam)) is of particular interest: it
proposes a design technique for processors that gracefully scale their error
frequencies in the face of voltage overscaling. Their technique relies on
reducing the number of near-critical paths.

"Probabilistic CMOS"
([Chakrapani 2006](#pcmos), [Akgul 2006](#pcmossurvey))
is a similar concept from the VLSI
community that advocates codesign of the technology, architecture, and
application to produce approximate ASICs for particular "soft" applications.

[Joe Bates](http://web.media.mit.edu/~bates/Summary.html) at MIT's Media Lab
purports to have a design for a very-small-area, very-low-power FPU that
exhibits transient faults with low absolute value. Details are slim, and there
don't seem to be any publications from the project yet.


### Compiler Techniques

On the other end of the computer science spectrum, language and compiler
researchers have explored software-only optimizations that trade away strict
correctness guarantees. In particular,
[Martin Rinard](http://people.csail.mit.edu/rinard/)'s group at MIT proposes
unsound code transformations such as "loop perforation"
([Agarwal 2009](#perforationtr)). A paper
at Onward! explores patterns that are amenable to this kind of transformation
([Rinard 2010](#rinard-onward)),
and another paper proposes "quality-of-service profiling" to
help programmers identify code that can be safely relaxed.

Green ([Baek 2010](#green)) is a different technique that allows the
programmer to write
several implementations of a single function: a "precise" one and several
of varying
imperfect precision. A runtime system then monitors application QoS online and
dynamically adapts to provide a target QoS value. The main contribution here is
a approach to dynamically and holistically controlling a whole application's output
fidelity.


### Language-Exposed Hardware Relaxations

Another category of approaches combines a particular architecture-level
loss of accuracy with a programming construct for exploiting it. Relax
([de Kruijf 2010](#relax))
lets the programmer annotate regions of code for which hardware error recovery
mechanisms should be turned off. The hardware still performs error *detection*,
however, and the programmer can choose how to handle hardware faults. Flicker
([Liu 2009](#flicker))
is distinct in its focus on soft memory rather than logic: it lets
the programmer allocate some data in a failure-prone region of memory. The DRAM
behind this address space then reduces its refresh rate, saving power but
introducing occasional bit flips. Finally, Stanley-Marbell
([2006](#smpmup2006))
proposes a parallel
architecture that uses language-level error bound expressions to map
messages to higher- or lower-reliability communication channels.


### Citations

The following citations are also available as [a BibTeX
file](/media/approximation.bib).
