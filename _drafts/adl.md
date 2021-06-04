---
title: From Hardware Description Languages to Accelerator Design Languages
excerpt:
    TK
---
We need to make it easier for to design custom hardware accelerators. High-performance FPGA cards are quickly becoming accessible, and even custom silicon no longer needs to entail an astronomical investment.
With sheer cost fading away as a barrier, the bottleneck for hardware acceleration will soon shift to development: realizing the potential of hardware specialization will require putting the tools into the hands of mainstream software developers.
Putting specialized accelerators within reach of more applications is urgent because the potential upside is so enormous:
domain-specific hardware like [Stanford's Darwin][darwin] can offer five orders of magnitude better performance than software,
and Microsoft successfully [used FPGAs to double server efficiency][catapult] for a Bing workload.

[darwin]: http://bejerano.stanford.edu/papers/p199-turakhia.pdf
[catapult]: https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/Catapult_ISCA_2014.pdf

Today's tools for developing accelerators, however, require rarefied expertise in hardware design.
Two kinds of factors make accelerator design hard:
there is *essential* complexity that is truly fundamental to the problem, and there is *accidental* complexity because the tools are bad.
Accelerator design shares fundamental challenges with high-performance software programming,
such as understanding cost models and grappling with parallelism,
and adds a few more,
such as contending with clock cycles and the freedom to customize memory hierarchies.
In an ideal world, the languages and tools for accelerator design would reflect those fundamental challenges---they would embrace the best techniques we have for high-performance and parallel software programming, and they would incrementally ratchet up the complexity to address the unique problems of hardware.

<img src="{{site.base}}/media/adl/complexity1.png" class="img-responsive">

Personally speaking, I've found the reality to be far more bleak.
When I use a traditional hardware description language (HDL), such as Verilog or Chisel, designing a fast, correct accelerator is
not *incrementally* harder than parallel programming; for me, at least, it is *ridiculously* challenging by comparison.

<img src="{{site.base}}/media/adl/complexity2.png" class="img-responsive">

In an HDL, the essential complexities of hardware design---fine-grained parallelism, orchestrating many distributed memories, and so on---collide with a host of accidental complexities.
Writing in an HDL reminds me of writing entire programs in assembly:
I have granular control over performance, but this control comes at the cost of extreme verbosity and brittleness.
The problem is the abstraction level:
*too much* detail and control over performance can paradoxically make it harder to productively iterate toward a fast implementation.
Just as not all high-performance software needs to drop down to the level of assembly,
not all accelerator design needs the granular control that HDLs offer.

TK HDLs have their place: for designing CPUs, for example. When you need to design truly arbitrary hardware. But when you want to implement hardware to perform a specific computation, we need a different level of abstraction.

TK what we need are programming models that scale with the essential complexity of hardware design. what is that extra complexity, and how should languages express it?

TK HLS tools are awesome and help a lot. but they are just one point in a very large design space. and their ties to legacy software languages (mainly, C and C++) offers familiarity but make for an awkward fit with hardware generation (cite Dahlia).

TK the missing piece: use/multiplexing of physical resources. that's the essential thing about hardware; you are creating computational objects *and then* using them to accomplish something

---

TK let's leave HDLs to what they're good at: arbitrary hardware, designing CPUs, etc. for an algorithmic accelerator...

TK we need a new category of programming languages for this task
there is already C-based HLS, Spatial, HeteroCL, our own Dahlia, TK.
But as with software languages, there will never be one language to rule them all---we need a broad diversity of options that embrace different language paradigms,
strike different trade-offs between performance and productivity,
or offer special features for specific application domains.
The goal is *not* to specify arbitrary hardware! The ability to design a RISC-V CPU, for example, is a non-goal.

TK *critically*, not HLS.
C is a bad language for this.
lots of good stories about how hardware experts bend C-based HLS to their will, but precious few about software developers becoming efficient hardware designers.
we can do better.
and we should have the following revolutionary idea: correct translation is the compiler's responsibility, not the developer's! if the tool generates wrong hardware (down to the bit), that's a compiler bug, not something the developer needs to hunt down and fix.
imagine if you had to constantly check that your C program matched the assembly program and make manual changes to the latter if not! that's life today with mainstream HLS.

TK do *not* get these confused with hardware description languages.
Traditional ones like Verilog or VHDL, newer ones like Chisel or PyMTL

TK also not DSLs. (???)

---

TK what should the goals be? balancing these competing objectives:
- computational semantics. (unlike HDLs.) should be able to understand its input-output behavior by reading the code, not doing a discrete event simulation.
- predictability and transparent cost models. put the tools into the hands of programmers; don't imagine that we'll isolate them from hardware concerns entirely

TK again, different languages will balance these goals differently. hide more to make the semantics more computational and therefore more understandable to programmers. reveal more hardware details to make performance optimization more tractable without relying on a mythical "sufficiently smart compiler."
