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
file]({{ site.base }}/media/approximation.bib).

<ul class="bib2xhtml">
<!-- Authors: Agarwal Anant and Rinard Martin and Sidiroglou Stelios and
  Misailovic Sasa and Hoffmann Henry --><li>
<a name="perforationtr"></a>Anant Agarwal, Martin Rinard,
  Stelios Sidiroglou, Sasa Misailovic, and
  Henry Hoffmann.
<a href="/web/20130212064944/http://hdl.handle.net/1721.1/46709">Using code perforation to improve
  performance, reduce energy consumption, and respond to failures</a>.
Technical report, MIT, 2009.</li>
<!-- Authors: Akgul BES and Chakrapani LN and Korkmaz P and Palem KV -->
<li>
<a name="pcmossurvey"></a>B.E.S.
  Akgul, L.N. Chakrapani, P. Korkmaz, and
  K.V. Palem.
<a href="/web/20130212064944/http://dx.doi.org/10.1109/VLSISOC.2006.313282">Probabilistic CMOS
  technology: A survey and future directions</a>.
In <cite>IFIP Intl. Conference on VLSI</cite>, 2006.</li>
<!-- Authors: Alvarez Carlos and Corbal Jesus and Valero Mateo -->
<li>
<a name="fuzzymemo"></a>Carlos
  Alvarez, Jesus Corbal, and Mateo Valero.
<a href="/web/20130212064944/http://dx.doi.org/10.1109/TC.2005.119">Fuzzy memoization for
  floating-point multimedia applications</a>.
<cite>IEEE Trans. Comput.</cite>, 54(7), 2005.</li>
<!-- Authors: Baek Woongki and Chilimbi Trishul M -->
<li>
<a name="green"></a>Woongki
  Baek and Trishul M. Chilimbi.
<a href="/web/20130212064944/http://dx.doi.org/10.1145/1806596.1806620">Green: a framework for
  supporting energy-conscious programming using controlled approximation</a>.
In <cite>PLDI</cite>, 2010.</li>
<!-- Authors: Chakrapani Lakshmi N and Akgul Bilge E S and Cheemalavagu Suresh
  and Korkmaz Pinar and Palem Krishna V and Seshasayee Balasubramanian -->
<li>
<a name="pcmos"></a>Lakshmi N. Chakrapani, Bilge
  E. S. Akgul, Suresh Cheemalavagu, Pinar
  Korkmaz, Krishna V. Palem, and Balasubramanian
  Seshasayee.
<a href="/web/20130212064944/http://portal.acm.org/citation.cfm?id=1131790">Ultra-efficient
  (embedded) soc architectures based on probabilistic CMOS (PCMOS)
  technology</a>.
In <cite>DATE</cite>, 2006.</li>
<!-- Authors: de Kruijf M and Sankaralingam K -->
<li>
<a name="dekruijf-selse09"></a>M. de Kruijf and
  K. Sankaralingam.
<a href="/web/20130212064944/http://pages.cs.wisc.edu/~dekruijf/docs/selse2009.pdf">Exploring the
  synergy of emerging workloads and silicon reliability trends</a>.
In <cite>SELSE</cite>, 2009.</li>
<!-- Authors: de Kruijf Marc and Nomura Shuou and Sankaralingam Karthikeyan -->
<li>
<a name="relax"></a>Marc
  de Kruijf, Shuou Nomura, and Karthikeyan
  Sankaralingam.
<a href="/web/20130212064944/http://dx.doi.org/10.1145/1815961.1816026">Relax: an architectural
  framework for software recovery of hardware faults</a>.
In <cite>ISCA</cite>, 2010.</li>
<!-- Authors: Ernst D and Nam Sung Kim and Das S and Pant S and Rao R and Toan
  Pham and Ziesler C and Blaauw D and Austin T and Flautner K and Mudge T -->
<li>
<a name="razor"></a>D. Ernst,
  Nam Sung Kim, S. Das, S. Pant,
  R. Rao, Toan Pham, C. Ziesler,
  D. Blaauw, T. Austin,
  K. Flautner, and T. Mudge.
<a href="/web/20130212064944/http://dx.doi.org/10.1145/1150343.1150348">Razor: a low-power pipeline
  based on circuit-level timing speculation</a>.
In <cite>MICRO</cite>, 2003.</li>
<!-- Authors: Hegde Rajamohana and Shanbhag Naresh R -->
<li>
<a name="ant"></a>Rajamohana Hegde and Naresh R.
  Shanbhag.
<a href="/web/20130212064944/http://dx.doi.org/10.1145/313817.313834">Energy-efficient signal
  processing via algorithmic noise-tolerance</a>.
In <cite>ISLPED</cite>, 1999.</li>
<!-- Authors: Kahng AB and Seokhyeong Kang and Kumar R and Sartori J -->
<li>
<a name="hpca10cam"></a>A.B.
  Kahng, Seokhyeong Kang, R. Kumar, and
  J. Sartori.
<a href="/web/20130212064944/http://dx.doi.org/10.1109/HPCA.2010.5416652">Designing a processor
  from the ground up to allow voltage/reliability tradeoffs</a>.
In <cite>HPCA</cite>, 2010.</li>
<!-- Authors: Leem Larkhoon and Cho Hyungmin and Bau Jason and Jacobson Quinn A
  and Mitra Subhasish -->
<li>
<a name="ersa"></a>Larkhoon
  Leem, Hyungmin Cho, Jason Bau,
  Quinn A. Jacobson, and Subhasish Mitra.
<a href="/web/20130212064944/http://portal.acm.org/citation.cfm?id=1871302">ERSA: error resilient
  system architecture for probabilistic applications</a>.
In <cite>DATE</cite>, 2010.</li>
<!-- Authors: Xuanhua Li and Donald Yeung -->
<li>
<a name="li06"></a>Xuanhua Li
  and Donald Yeung.
<a href="/web/20130212064944/http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.78.2997">Exploiting soft computing for increased fault tolerance</a>.
In <cite>ASGI</cite>, 2006.</li>
<!-- Authors: Li Xuanhua and Yeung Donald -->
<li>
<a name="li07"></a>Xuanhua Li
  and Donald Yeung.
<a href="/web/20130212064944/http://dx.doi.org/10.1109/HPCA.2007.346196">Application-level
  correctness and its impact on fault tolerance</a>.
In <cite>HPCA</cite>, 2007.</li>
<!-- Authors: Xuanhua Li and Donald Yeung -->
<li>
<a name="li08"></a>Xuanhua Li
  and Donald Yeung.
<a href="/web/20130212064944/http://www.jilp.org/vol10/v10paper10.pdf">Exploiting application-level
  correctness for low-cost fault tolerance</a>.
<cite>Journal of Instruction-Level Parallelism</cite>, 2008.</li>
<!-- Authors: Song Liu and Karthik Pattabiraman and Thomas Moscibroda and
  Benjamin G Zorn -->
<li>
<a name="flicker"></a>Song Liu,
  Karthik Pattabiraman, Thomas Moscibroda, and
  Benjamin G. Zorn.
<a href="/web/20130212064944/http://research.microsoft.com/apps/pubs/default.aspx?id=102932">Flicker: Saving refresh-power in mobile devices through critical data
  partitioning</a>.
Technical Report MSR-TR-2009-138, Microsoft Research, 2009.</li>
<!-- Authors: Sasa Misailovic and Stelios Sidiroglou and Hank Hoffman and
  Martin Rinard -->
<li>
<a name="qosprof"></a>Sasa
  Misailovic, Stelios Sidiroglou, Hank Hoffman,
  and Martin Rinard.
<a href="/web/20130212064944/http://dx.doi.org/10.1145/1806799.1806808">Quality of service
  profiling</a>.
In <cite>ICSE</cite>, 2010.</li>
<!-- Authors: Narayanan Sriram and Sartori John and Kumar Rakesh and Jones
  Douglas L -->
<li>
<a name="stochasticproc"></a>Sriram Narayanan, John
  Sartori, Rakesh Kumar, and Douglas L. Jones.
<a href="/web/20130212064944/http://portal.acm.org/citation.cfm?id=1871008">Scalable stochastic
  processors</a>.
In <cite>DATE</cite>, 2010.</li>
<!-- Authors: Rinard Martin and Hoffmann Henry and Misailovic Sasa and
  Sidiroglou Stelios -->
<li>
<a name="rinard-onward"></a>Martin Rinard, Henry
  Hoffmann, Sasa Misailovic, and Stelios
  Sidiroglou.
<a href="/web/20130212064944/http://dx.doi.org/10.1145/1869459.1869525">Patterns and statistical
  analysis for understanding reduced resource computing</a>.
In <cite>Onward!</cite>, 2010.</li>
<!-- Authors: Phillip Stanley Marbell and Diana Marculescu -->
<li>
<a name="smpmup2006"></a>Phillip Stanley-Marbell and
  Diana Marculescu.
<a href="/web/20130212064944/http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.121.9864">A
  programming model and language implementation for concurrent failureprone
  hardware</a>.
In <cite>PMUP</cite>, 2006.</li>
<!-- Authors: Stanley Marbell Phillip -->
<li>
<a name="smitw2009"></a>Phillip Stanley-Marbell.
<a href="/web/20130212064944/http://dx.doi.org/10.1109/ITW.2009.5351408">Encoding efficiency of
  digital number representations under deviation constraints</a>.
In <cite>ITW</cite>, 2009.</li>
<!-- Authors: Tong Jonathan Ying Fai and Nagle David and Rutenbar Rob A -->
<li>
<a name="bitwidthred"></a>Jonathan Ying Fai Tong, David
  Nagle, and Rob. A. Rutenbar.
<a href="/web/20130212064944/http://dx.doi.org/10.1109/92.845894">Reducing power by optimizing the
  necessary precision/range of floating-point arithmetic</a>.
<cite>IEEE Trans. VLSI Syst.</cite>, 8(3), 2000.</li>
<!-- Authors: Vicky Wong and Mark Horowitz -->
<li>
<a name="wong-selse06"></a>Vicky Wong and Mark Horowitz.
<a href="/web/20130212064944/http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.77.6301">Soft
  error resilience of probabilistic inference applications</a>.
In <cite>SELSE</cite>, 2006.</li>
</ul>
