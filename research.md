---
title: Research
layout: longy
blurb: |
    Here are a few short descriptions of some research projects that I've
    worked on recently.
---

### <a id="enerj">Disciplined Approximate Computing</a>

The power consumption of CPUs and memory systems has traditionally been
constrained by the need for strict correctness guarantees: processor voltage,
for instance, must allow enough slack as to prevent even the rarest timing
errors. But many modern applications do not require perfect correctness. An
image renderer, for example, can tolerate occasional pixel errors without
compromising overall quality of service. However, it is infeasible to
completely abandon correctness guarantees---to do so would make development of
reliable software difficult or impossible. [EnerJ][enerj-home] is a programming
language that exposes hardware faults in a safe, principled manner. Simulation
of selectively reliable hardware suggests that EnerJ programs can save large
amounts of energy with only slight sacrifices to quality of service.

[enerj-home]: http://sampa.cs.washington.edu/sampa/EnerJ

### Automatic Discovery of Performance and Power Pitfalls in Web Browsers

Web browsers' speed and power consumption have become salient concerns with the
emergence of Web-enabled mobile devices. However, the relationship between page
content and browser performance is poorly understood. [WebChar][webchar] uses
machine learning to automatically discover correlations between page
characteristics and browser behavior. The results can help content providers
deploy better-performing Web sites and assist browser developers in optimizing
their implementations.

[webchar]: http://sampa.cs.washington.edu/sampa/WebChar

### Explicit Shared-Memory Communication

Shared memory is a fast, simple, and ubiquitous model for multiprocessor
computing. However, shared-memory programs are prone to subtle,
hard-to-diagnose concurrency bugs. Much of this difficulty arises because
cross-thread communication in shared-memory programs is transparent and not
easily apparent to the programmer. [Organized Sharing (OSHA)][osha-home]
consists of a language extension that makes communicating code explicit and an
implementation ("OSHAJava") of a high-performance dynamic checker that can
catch concurrency bugs in annotated programs before they cause problems.

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

 * "Expressing and Verifying Probabilistic Assertions."
   Adrian Sampson, Pavel Panchekha, Todd Mytkowicz, Kathryn McKinley, Dan
   Grossman, and Luis Ceze.
   To appear in [PLDI 2014][].
 * ["Approximate Storage in Solid-State Memories."][approxstorage]
   Adrian Sampson, Jacob Nelson, Karin Strauss, and Luis Ceze. In
   [MICRO 2013][]. Selected to appear as an expanded version in [ACM TOCS][].
    * [Local PDF.][storage-local]
    * [Slides.][storage-slides]
    * [Poster.][storage-poster]
    * [Lightning session slides.][storage-lightning]
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

[approxstorage]: http://dl.acm.org/citation.cfm?id=2540708.2540712
[storage-local]: {{ site.base }}/media/papers/approxstorage-micro2013.pdf
[storage-slides]: {{ site.base }}/media/approxstorage-micro-slides.pdf
[storage-poster]: {{ site.base }}/media/approxstorage-micro-poster.pdf
[storage-lightning]: {{ site.base }}/media/approxstorage-micro-lightning.pdf
[MICRO 2013]: http://www.microarch.org/micro46/
[ACM TOCS]: http://tocs.acm.org

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
