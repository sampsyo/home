---
title: From Hardware Description Languages to Accelerator Design Languages
excerpt:
    TK
---
We need to make it easier for to design custom hardware accelerators. High-performance FPGA cards are quickly becoming accessible, and even custom silicon no longer needs to entail an astronomical investment. With sheer cost fading away as a barrier, the bottleneck will soon shift to development: realizing the potential of hardware specialization will require putting the tools into the hands of mainstream software developers.

TK something about eye-watering performance, maybe genomics

Today's tools, however, require rarefied hardware expertise.
Hardware accelerator design has both essential complexity, but the languages and tools available today complement it with a generous helping of accidental complexity.

<img src="{{site.base}}/media/adl/complexity1.png" class="img-responsive">

Personally speaking, however, I've found the actual complexity to be far worse.
When I use a traditional hardware description language (HDL), such as Verilog or Chisel, designing a fast, correct accelerator is
not *incrementally* harder than parallel programming; for me, at least, it is *ridiculously* challenging by comparison.

<img src="{{site.base}}/media/adl/complexity2.png" class="img-responsive">

In an HDL, the essential complexities of hardware design---fine-grained parallelism, orchestrating many distributed memories, and so on---collide with a host of accidental complexities.
Writing in an HDL reminds me of writing entire programs in assembly:
I have granular control over performance, but this control comes at the cost of extreme verbosity and brittleness.

TK the fundamental problem is the abstraction level.
worrying about gates & wires loses the forest for the trees.

TK HLS tools are awesome and help a lot. but they are just one point in a very large design space. and their ties to legacy software languages (mainly, C and C++) offers familiarity but make for an awkward fit with hardware generation (cite Dahlia).

TK what we need are programming models that scale with the essential complexity of hardware design. what is that extra complexity, and how should languages express it?

TK the missing piece: use/multiplexing of physical resources. that's the essential thing about hardware; you are creating computational objects *and then* using them to accomplish something

---

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
