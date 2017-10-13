---
title: Closed Problems in Approximate Computing
---
<aside>
  These are notes for a talk I will give at the <a href="http://nope.pub">NOPE</a> workshop at MICRO 2017, where the title is <i>Approximate Computing Is Dead; Long Live Approximate Computing</i>.
</aside>

[Approximate computing][approx] has reached an adolescent phase as a research area. We have picked bushels of low-hanging fruit. While there are many approximation papers left to write, it's a good time to enumerate the *closed* problems: research problems that are probably no longer worth pursuing.

[approx]: {{site.base}}/research.html#approximate-computing

# Hardware

**No more approximate functional units.**
Especially for people who love VLSI work, a natural first step in approximate computing is designing approximate adders, multipliers, and other basic functional units. Cut a carry chain here, drop a block of intermediate results there, or use an automated search to find “unnecessary” gate---there are lots of ways to design an FU that’s mostly right most of the time. Despite dozens of papers in this vein, however, the gains seem to range from minimal to nonexistent. A lovely [DATE 2017 paper by Barrois et al.][barrois] recently studied some of these approximate FUs and found that:

> existing approximate adders and multipliers tend to be dominated by truncated or rounded fixed-point ones.

In other words, plain old fixed-point FUs with a narrower bit width are usually at least as good as fancy “approximate” FUs. The problem is that, if you’re approximating the values below a given bit position, it’s usually not worth it to compute those approximate bits at all. In fact, by dropping the approximate bits altogether, you can exploit the smaller data size for broader advantages in the whole application. Applications using approximate adders and multipliers, on the other hand, software ends up copying around and operating on worthless, incorrect trailing bits for no benefit in precision.

This paper has raised the bar for FU-level approximation research. We should no longer publish VLSI papers that measure approximate adders in isolation and insist on whole-application benefits over narrow arithmetic. Without a radically different approach, we should stop designing approximate functional units altogether.

[barrois]: https://hal.inria.fr/hal-01423147

**No more voltage overscaling.**
TK voltage overscaling is incredibly hard to evaluate without real tape-outs on modern processes
Basically nobody knows the error/energy trade-offs
Despite this being synonymous with “approximate computing” for some. (I accept some blame for this—cite Truffle.)

**In general, no more fine-grained approximate operations.**
TK Benefits are overwhelmed by control. Maybe OK if you’re designing accelerators
granularity is the common thread!

## Instead

TK CGRAs and other configurable accelerators. Minimize control overhead so these techniques can be useful again.

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
