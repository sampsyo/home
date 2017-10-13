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
For too many people I meet, *approximate computing* is a synonym for *voltage overscaling*. Voltage overscaling when you turn up the clock or turn down the $V_{\text{DD}}$ beyond their safe ranges and allowing occasional timing errors. I accept some of the blame for solidifying voltage overscaling’s outsized mindshare by co-authoring [a paper about “hardware support for approximate computing”][truffle] that exclusivley used voltage as its error/energy knob.

The problem with voltage overscaling is that it’s nearly impossible to evaluate. It’s easy to model its effects on energy and frequency, but the pattern of timing errors depends on a chip’s design, synthesis, layout, manufacturing process, and even environmental conditions such as temperature. Even a halfway-decent error analysis for voltage overscaling requires a full circuit simulator. To account for process variation, we’d need to tape out real silicon at scale. In a frustrating Catch-22 of research evaluation, it’s hard to muster the enthusiasm for a tapeout before we can prove that the results are likely to be good.

There’s even a credible argument that the results are likely to be bad. In voltage overscaling, the circuit’s critical path fails first. And in many circuits, the longest paths in the design contribute the most to the output accuracy. In a functional unit, for example, the most significant output bits arise from the longest paths. So instead of a smooth degradation in accuracy as the voltage decreases, these circuits are likely to fall off a steep accuracy cliff when the critical path first fails to meet timing.

Research should stop using voltage overscaling as the “default” approximate computing technique. In fact, we should stop using it altogether until we have evidence *in silica* that the technique’s voltage--error trade-offs are favorable.

**In general, no more fine-grained approximate operations.**
TK Benefits are overwhelmed by control. Maybe OK if you’re designing accelerators
granularity is the common thread!

## Instead…

TK CGRAs and other configurable accelerators. Minimize control overhead so these techniques can be useful again.

# Programming

**No more automatic approximability analysis.**
The idea is—sometimes explicitly—to lift [EnerJ][]'s annotation burden.
TK

**No more generic unsound compiler transformation.**
TK loop perforation, with all due respect, is the world’s dumbest approximate program transformation.
And it’s surprisingly hard to meaningfully beat.

**No more end-to-end framework development.**
TK ACCEPT Is out there, useful, and mostly unused. I wanted to make life easier for everyone, but it turns out that everyone is fine building all their infrastructure from scratch.

## Instead…

- debugger: explain *why* quality was so low this time
- practical OS support (scheduler balances resources/quality)

# Quality

**No more weak statistical guarantees.**
TK lots of fancy-seeming approaches are fundamentally unable to defend against adversarial inputs that get reused lots of times. This means that their statistical guarantees all start with the same assumption: at development time, we know exactly the probability distribution that the program will encounter in deployment. This assumption is extremely hard to defend. It means that, in the real world, the statistical guarantee is useless.
TK link to “probably correct” blog post

Instead:

- trustworthy "Quality SLAs" for SaaS
- run-time verification — actually *sound* checks for large errors

# Domains

**No more sadness about the imperfection of quality metrics.**
TK we know they’re not perfect. Let’s standardize and move on
TK I think we invented the 10% quality threshold in the EnerJ paper. It sucks, but it’s what we have

**No more benchmark-oriented research?**
TK using PARSEC-like applications, or little kernels, paired with dubious quality metrics of our own invention, and necessarily arbitrary quality thresholds, with no attempt to ground utility in how people really want to use software—all of this is getting kind of old. It may be time for a completely new approach.

## Instead…

compulsory approximation
TK link to WAX paper
Cloud services for ML are a perfect target!
