---
title: Closed Problems in Approximate Computing
---
<aside>
  These are notes for a talk I will give at the <a href="http://nope.pub">NOPE</a> workshop at MICRO 2017, where the title is <i>Approximate Computing Is Dead; Long Live Approximate Computing</i>.
</aside>

[Approximate computing][approx] has reached an adolescent phase as a research area. We have picked bushels of low-hanging fruit. While there are many approximation papers left to write, it's a good time to enumerate the *closed* problems: research problems that are probably no longer worth pursuing.

[approx]: {{site.base}}/research.html#approximate-computing

# Hardware

- approximate adders (DAC paper???)
- voltage overscaling
- generalizing from that: per-op optimizations without a new approach. granularity is the common thread!

> existing approximate adders and multipliers tend to be dominated by truncated or rounded fixed-point ones

[DATE 2017 paper by Barrois et al.][barrois]

The gist is that if you're approximating below a given bit position, it's usually just as good not to compute those bits at all. Then you get systemic benefits from reducing the data size too (i.e., the rest of the application can benefit from that too!).

[barrois]: https://hal.inria.fr/hal-01423147

instead:

- CGRAs and other configurable accelerators

# Programming

- eliminate EnerJ's annotation burden
- program transformations that are worse than loop perforation
- compiler infrastructure (ACCEPT)

instead:

- run-time verification -- actually *sound* checks for large errors
- debugger: explain *why* quality was so low this time

# Quality

- fully general ""statistical guarantees"" (adversarial inputs)

Instead:

- trustworthy "Quality SLAs" for SaaS
- practical OS support (scheduler balances resources/quality)

# Domains

- don't balk at the idea of quality metrics being imperfect
- in fact, general "benchmark-oriented" approximate computing techniques are starting to get tired

Instead:

- compulsory approximation
