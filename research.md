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

<ul>
{% for paper in site.data.pubs %}
    {% if paper.type == 'conference' %}
        {% include paper_human.html %}
    {% endif %}
{% endfor %}
</ul>

### Workshop Papers

<ul>
{% for paper in site.data.pubs %}
    {% if paper.type == 'workshop' %}
        {% include paper_human.html %}
    {% endif %}
{% endfor %}
</ul>

### Other Stuff

<ul>
{% for paper in site.data.pubs %}
    {% if paper.type != 'conference' and paper.type != 'workshop' %}
        {% include paper_human.html %}
    {% endif %}
{% endfor %}
</ul>
