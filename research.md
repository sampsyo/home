---
title: Research
layout: longy
blurb: |
    My primary research explores the idea of *approximate computing*. Approximation is a cross-cutting concern, so my research interests span hardware, architecture, compilers, programming languages, and development tools.
---

### Practical Approximate Computing

Modern computer systems are to be *correct* at all costs. While predictable,
error-free execution has obvious benefits, its costs can also be vast. For many
applications, perfect correctness is unnecessary---and today's over-provisioned
systems waste time and energy providing precision they don't need.

But many modern applications do not require perfect correctness. An image
renderer, for example, can tolerate occasional pixel errors: the user might not
even notice. Examples of error-robust software abound: computer vision
necessarily tolerates noise; machine learning incorporates uncertainty
fundamentally; lossy compression already throws away information for the sake
of efficiency. *Approximate computing* systems exploit error-resilient software
to reduce resource usage.

Even with all this abundant error tolerance, it would be a mistake to completely abandon correctness guarantees. Without *some* discipline, programming approximate systems reliably would be difficult or impossible. My research focuses on designing practical approximate computing systems that provide predictability without sacrificing efficiency.

#### Approximation Systems

Here the systems our group has developed to make approximation practical.

**EnerJ** is an approximation-aware programming language. It adapts ideas from information flow tracking research to add type qualifiers to Java that encapsulate a wide range of approximation strategies from hardware to software. A compile-time check ensures that approximation cannot corrupt critical data.

**Truffle** is a dual-voltage CPU design and ISA that works as a compilation target for EnerJ. It saves energy by allowing timing errors in caches and functional units.

**Neural Processing Units** are a different approach to safe approximation: they accelerate error-tolerant portions of programs by transforming them to neural networks. NNs can be implemented efficiently in hardware, so pairing a code transformation with a small, specialized hardware structure yields large payoffs in performance and energy.

**Approximate storage** translates the approximate computing paradigm from compute to storage. We show how to exploit the quirks of solid-state memory technologies to build faster, denser, and longer-lasting memory modules.

**Probabilistic assertions** let programmers express the correctness of nondeterministic programs. You can require that a pixel is within some range at least 90% of the time or that GPS sensing errors lead to a wrong decision in at most 5% of the cases. To verify probabilistic assertions, we use a symbolic execution that connects traditional programs to statistics via a Bayesian network representation. Standard statistical properties then act as optimizations to make verification efficient.

[enerj-home]: http://sampa.cs.washington.edu/sampa/EnerJ

### Other Topics: Browsers, Energy, and Parallelism

Web browsers' speed and power consumption have become salient concerns with the
emergence of Web-enabled mobile devices. However, the relationship between page
content and browser performance is poorly understood. [WebChar][webchar] uses
machine learning to automatically discover correlations between page
characteristics and browser behavior. The results can help content providers
deploy better-performing Web sites and assist browser developers in optimizing
their implementations.

[webchar]: http://sampa.cs.washington.edu/sampa/WebChar

I have also worked on safety in shared-memory parallel programming, including a [program annotation system][osha-home] and hardware that can suppress some concurrency bugs.

[osha-home]: http://sampa.cs.washington.edu/sampa/Organized_Sharing_(OSHA)

-------

## Publications

[Look me up at DBLP][dblp] for another view on my publications.

Where possible, the titles below are "magic" links to the ACM database server
that should let you view the PDF for free while letting the ACM keep track of
viewer statistics. Use the "local PDF" links if you prefer bypass this
rigmarole.

The slides linked below are PDF files. Keynote files are available on request.
(I don't have PowerPoint versions; sorry.)

[dblp]: http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/s/Sampson:Adrian.html

### Conference Papers

 * ["Expressing and Verifying Probabilistic Assertions."][passert-acm]
   Adrian Sampson, Pavel Panchekha, Todd Mytkowicz, Kathryn McKinley, Dan
   Grossman, and Luis Ceze.
   To appear in [PLDI 2014][].
    * [Local PDF.][passert]
    * [Artifact evaluated!][pldi14-aec]
    * [Full semantics and proof.][passert-aux]
    * [Slides.][passert-slides]
    * [Poster.][passert-poster]
    * ["Teaser" slide.][passert-teaser]
 * ["Approximate Storage in Solid-State Memories."][approxstorage]
   Adrian Sampson, Jacob Nelson, Karin Strauss, and Luis Ceze. In
   [MICRO 2013][]. Selected to appear as an expanded version in [ACM TOCS][].
    * [Local PDF.][storage-local]
    * [Slides.][storage-slides]
    * [Poster.][storage-poster]
    * [Lightning session slides.][storage-lightning]
    * [Talk video.][storage-video]
 * ["Neural Acceleration for General-Purpose Approximate Programs."][npu-micro]
   Hadi Esmaeilzadeh, Adrian Sampson, Luis Ceze, and Doug Burger. In
   [MICRO 2012][].
    * [Local PDF.][npu-local]
    * [Slides.][npu-slides]
    * [Poster.][npu-poster]
    * [Lightning session slides.][npu-lightning] (Winner of the "best
      lightning session presentation" award.)
    * Version in [IEEE MICRO Top Picks 2013][npu-toppicks].
    * Version in CACM Research Highlights to appear in October 2014.
 * ["Automatic Discovery of Performance and Energy Pitfalls in HTML and
   CSS."][webchar-extabs]
   Adrian Sampson, Călin Caşcaval, Luis Ceze, Pablo Montesinos, and Dario
   Suarez Gracia. Poster and extended abstract in [IISWC 2012][].
    * [Extended technical report.][webchar-tr]
    * [Source code and data.][webchar]
    * [Poster.][webchar-poster]
    * [Slides.][webchar-slides]
 * ["Architecture Support for Disciplined Approximate Programming."][truffle]
   Hadi Esmaeilzadeh, Adrian Sampson, Luis Ceze, and Doug Burger. In
   [ASPLOS 2012][].
    * [Local PDF.][truffle-local]
    * [Slides.][truffle-slides]
 * ["EnerJ: Approximate Data Types for Safe and General Low-Power
   Computation."][enerj-local]
   Adrian Sampson, Werner Dietl, Emily Fortuna, Danushen Gnanapragasam, Luis
   Ceze, and Dan Grossman. In [PLDI 2011][].
    * [Slides.][enerj-slides]
    * [Poster.][enerj-poster]
    * [Technical report with full proofs.][enerj-tr]
    * [Checker, simulator, and benchmark source code.][enerj-code]
 * ["Composable Specifications for Structured Shared-Memory
   Communication."][osha]
   Benjamin Wood, Adrian Sampson, Luis Ceze, and Dan Grossman.
   In [OOPSLA 2010][]. [Local PDF.][osha-local]
 * <a href="http://dx.doi.org/10.1109/ICC.2008.984">"On-line Distributed Traffic Grooming."</a>
   R. Jordan Crouser, Brian Rice, Adrian Sampson, and Ran Libeskind-Hadas.
   In [ICC 2008][].

[PLDI 2014]: http://conferences.inf.ed.ac.uk/pldi2014/
[pldi14-aec]: http://pldi14-aec.cs.brown.edu
[passert]: {{ site.base }}/media/papers/passert-pldi2014.pdf
[passert-aux]: {{ site.base }}/media/papers/passert-aux.pdf
[passert-slides]: {{ site.base }}/media/passert-pldi-slides.pdf
[passert-poster]: {{ site.base }}/media/passert-pldi-poster.pdf
[passert-teaser]: {{ site.base }}/media/passert-pldi-teaser.pdf
[passert-acm]: http://dl.acm.org/citation.cfm?id=2594294

[approxstorage]: http://dl.acm.org/citation.cfm?id=2540708.2540712
[storage-local]: {{ site.base }}/media/papers/approxstorage-micro2013.pdf
[storage-slides]: {{ site.base }}/media/approxstorage-micro-slides.pdf
[storage-poster]: {{ site.base }}/media/approxstorage-micro-poster.pdf
[storage-lightning]: {{ site.base }}/media/approxstorage-micro-lightning.pdf
[MICRO 2013]: http://www.microarch.org/micro46/
[ACM TOCS]: http://tocs.acm.org
[storage-video]: https://www.youtube.com/watch?v=YCoGNXSSMJo

[npu-poster]: {{ site.base }}/media/npu-micro-poster.pdf
[npu-slides]: {{ site.base }}/media/npu-micro-slides.pdf
[npu-lightning]: {{ site.base }}/media/npu-micro-lightning.pdf
[npu-micro]: http://dl.acm.org/citation.cfm?id=2457519
[npu-local]: {{ site.base }}/media/papers/npu-micro2012.pdf
[MICRO 2012]: http://www.microsymposia.org/micro45/
[npu-toppicks]: https://sites.google.com/site/ieeemicro/call-for-papers/top-picks-2013

[iiswc 2012]: http://www.iiswc.org/iiswc2012/
[webchar-tr]: {{ site.base }}/media/papers/webchar-tr.pdf
[webchar-extabs]: {{ site.base }}/media/papers/webchar-iiswc2012-extabs.pdf
[webchar-slides]: {{ site.base }}/media/webchar-iiswc-slides.pdf
[webchar-poster]: {{ site.base }}/media/webchar-iiswc-poster.pdf

[truffle]: http://dl.acm.org/authorize?6607704
[truffle-local]: {{ site.base }}/media/papers/truffle-asplos2012.pdf
[truffle-slides]: {{ site.base }}/media/truffle-asplos-slides.pdf

[enerj]: http://dl.acm.org/authorize?436230
[enerj-local]: {{ site.base }}/media/papers/enerj-pldi2011.pdf
[enerj-slides]: {{ site.base }}/media/enerj-pldi-slides.pdf
[enerj-poster]: {{ site.base }}/media/enerj-poster.pdf
[enerj-code]: http://sampa.cs.washington.edu/sampa/EnerJ#Source_Release
[enerj-tr]: {{ site.base }}/files/enerjproofs.pdf

[osha]: http://dl.acm.org/authorize?390121
[osha-local]: http://sampa.cs.washington.edu/public/uploads/e/e9/Osha-oopsla2010.pdf

[ASPLOS 2012]: http://research.microsoft.com/en-us/um/cambridge/events/asplos_2012/
[PLDI 2011]: http://pldi11.cs.utah.edu/
[OOPSLA 2010]: http://www.splashcon.org/index.php?option=com_content&amp;view=article&amp;id=47:oopsla-research-papers&amp;catid=34:due-march-25-2010&amp;Itemid=55
[ICC 2008]: http://www.ieee-icc.org/2008/

### Workshop Papers

 * ["Two Approximate-Programmability Birds, One Statistical-Inference
   Stone."][approx-paper]
   Adrian Sampson.
   In [APPROX 2014][]. [Slides.][approx-slides]
 * ["Tuning Approximate Computations with Constraint-Based Type
   Inference."][wacas-inference-paper]
   Brett Boston, Adrian Sampson, Dan Grossman, and Luis Ceze.
   In [WACAS 2014][].
 * ["Approximate Semantics for Wirelessly Networked
   Applications."][wacas-wireless-paper]
   Benjamin Ransford, Adrian Sampson, and Luis Ceze.
   In [WACAS 2014][].
 * ["Profiling and Autotuning for Energy-Aware Approximate
   Programming."][wacas-profiling-paper]
   Michael F. Ringenburg, Adrian Sampson, Luis Ceze, and Dan Grossman.
   In [WACAS 2014][].
 * Design Tradeoffs of Approximate Analog Neural Accelerators.
   Renée St. Amant, Hadi Esmaeilzadeh, Adrian Sampson, Luis Ceze, Arjang
   Hassibi, and Doug Burger. In [NIAC 2013][].
 * ["Addressing Dark Silicon Challenges with Disciplined Approximate
   Computing."][dasi-paper] Hadi Esmaeilzadeh, Adrian Sampson, Michael
   Ringenburg, Dan Grossman, Luis Ceze, and Doug Burger. In [DaSi 2012][]
   (co-located with ISCA).
 * ["Towards Neural Acceleration for General-Purpose Approximate
   Computing."][weed-paper] Hadi Esmaeilzadeh, Adrian Sampson, Luis Ceze and
   Doug Burger. In [WEED 2012][] (co-located with ISCA).
 * ["Greedy Coherence."][greco] Emily Fortuna, Brandon Lucia, Adrian Sampson,
   Benjamin Wood and Luis Ceze. In [HPPC 2011][] (co-located with MICRO).

[approx-paper]: {{ site.base }}/media/approx2014.pdf
[approx-slides]: {{ site.base }}/media/approx2014-slides.pdf
[approx 2014]: http://approx2014.cs.umass.edu
[wacas-inference-paper]: http://sampa.cs.washington.edu/wacas14/papers/boston.pdf
[wacas-wireless-paper]: http://sampa.cs.washington.edu/wacas14/papers/ransford.pdf
[wacas-profiling-paper]: http://sampa.cs.washington.edu/wacas14/papers/ringenburg.pdf
[WACAS 2014]: http://sampa.cs.washington.edu/wacas14/
[NIAC 2013]: http://arch2neu.saclay.inria.fr/NIAC/
[weed-paper]: http://research.ihost.com/weed2012/pdfs/paper%20G.pdf
[dasi-paper]: http://sampa.cs.washington.edu/public/uploads/b/bc/Npu-dasi12.pdf
[DaSi 2012]: http://darksilicon.ucsd.edu/
[WEED 2012]: http://research.ihost.com/weed2012/
[greco]: http://abstract.cs.washington.edu/~blucia0a/pubs/greco.pdf
[HPPC 2011]: http://hppc.lsc.ic.unicamp.br/

### Other Stuff

 * ["EnerJ, the Language of Good-Enough Computing."][spectrum]
   Adrian Sampson, Luis Ceze, and Dan Grossman.
   *IEEE Spectrum*, October 2013.
 * ["Dense Approximate Storage in Phase-Change Memory."](http://asplos11.cs.ucr.edu/selected_submissions/phase-change-memory.pdf)
   Jacob Nelson, Adrian Sampson, and Luis Ceze.
   Presented in the <a href="http://asplos11.cs.ucr.edu/crazyidea.html">Ideas
   &amp; Perspectives</a> session at
   <a href="http://asplos11.cs.ucr.edu/">ASPLOS 2011</a>.

[spectrum]: http://spectrum.ieee.org/computing/software/enerj-the-language-of-goodenough-computing
