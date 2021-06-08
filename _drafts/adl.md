---
title: From Hardware Description Languages to Accelerator Design Languages
excerpt:
    TK
---
We need to make it easier for to design custom, application-specific hardware accelerators.
The potential [efficiency gains][darwin] gains are [enormous][catapult], and the cost of deploying accelerators is falling rapidly with the [widespread][azurenp] [availability][f1] of [FPGA][intel-pac] [cards][xilinx-alveo] and the increasing accessibility of [custom silicon][google-tapeout].
As the cost of hardware itself falls and the urgency for alternatives to general-purpose processors intensifies, the difficulty of designing custom hardware remains a bottleneck.

The thesis of this post is that hardware description languages (HDLs), while indispensable for implementing arbitrary hardware, are not the key to making application-specific specialization go mainstream.
An emerging and distinct class of languages, which might be called *accelerator design languages* (ADLs), target new abstraction levels with different trade-offs between generality and productivity.
As with software languages, there will never be a one-size-fits all ADL:
and crucially, traditional high-level synthesis (HLS) tools that repurpose C-based programming languages are not the only approach.
This is a call for more research to explore the design space of ADLs, their compilers, and accompanying tools.
An ecosystem of ADL approaches can put the power of specialized computing into the hands of domain experts, not just hardware designers.

[darwin]: http://bejerano.stanford.edu/papers/p199-turakhia.pdf
[catapult]: https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/Catapult_ISCA_2014.pdf
[xilinx-alveo]: https://www.xilinx.com/products/boards-and-kits/alveo.html
[intel-pac]: https://www.intel.com/content/www/us/en/products/details/fpga/platforms/pac.html
[f1]: https://aws.amazon.com/ec2/instance-types/f1/
[azurenp]: https://docs.microsoft.com/en-us/azure/virtual-machines/np-series
[google-tapeout]: https://www.fossi-foundation.org/2020/06/30/skywater-pdk

### Essential vs. Accidental Complexity in Accelerator Design

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
When I use a traditional hardware description language (HDL), such as [Verilog][] or [Chisel][], designing a fast, correct accelerator is
not *incrementally* harder than parallel programming; for me, at least, it is *ridiculously* challenging by comparison.

<img src="{{site.base}}/media/adl/complexity2.png" class="img-responsive">

In an HDL, the essential complexities of hardware design---fine-grained parallelism, orchestrating many distributed memories, and so on---collide with a host of accidental complexities.
Writing in an HDL reminds me of writing entire programs in assembly:
I have granular control over performance, but this control comes at the cost of extreme verbosity and brittleness.
The problem is the abstraction level:
*too much* detail and control over performance can paradoxically make it harder to productively iterate toward a fast implementation.
Just as not all high-performance software needs to drop down to the level of assembly,
not all accelerator design needs the granular control that HDLs offer.

HDLs have their place: they remain the right tool for the job when designing general-purpose processors, for example.
But my thesis here is that their unique ability to express arbitrary circuits is unnecessary for most cases when the goal is to design hardware that implements a specific computation.
HDLs' generality and low-level control, while indispensable for classic hardware design scenarios, is the root cause of the accidental complexity that makes FPGAs so much harder to program than GPUs.

If application-specific accelerator design is going to go mainstream, we need alternatives that embrace different levels of abstraction.
The key challenge is to identify the key factors in the *essential complexity* of hardware design---the fundamental factors that make it harder than other parallel programming---and to embody that complexity in a programming model.
What would a programming language look like that was designed from the ground up for implementing algorithmic accelerators?

### C-Based HLS is Not the Only Answer

Today, the commercially successful answer to this question lies in *high-level synthesis* (HLS) tools.
HLS compilers from [Xilinx][xilinx-hls], [Mentor][mentor-hls], and [Intel][intel-hls] can already generate high-quality HDL implementations from programs written in C, C++, or OpenCL.
To work around C's sequential-first, pointer-based semantics,
HLS tools extend the language with vendor-specific `#pragma` annotations or [SystemC][] constructs to express hardware concepts.
HLS research and products have made huge strides in recent years---Harvard's [EdgeBERT][] and Google's [VCU][] are two high-profile recent examples of hardware accelerators that have relied on HLS for significant parts of their design.
C-based HLS tools automate some of the tedious tasks in hardware design by automatically scheduling and pipelining basic logic to match sequential semantics.

However, traditional C-based HLS tools have succeeded *despite* their grounding in C---not *because* of it.
By reusing a legacy software language, they create a semantic gap that in turn yields correctness and performance pitfalls.
Recently,
researchers at Imperial College London [used fuzz testing to find a torrent of bugs in mature HLS tools][hls-fuzz] when compiling even simple C code,
and our lab at Cornell [identified performance predictability problems][dahlia-paper]
where small, seemingly benign changes in the input program can yield wild changes in the generated hardware's size and speed.
While reusing C offers compatibility and familiarity, it also comes at a cost in reliability and transparency.

What would HLS look like if it were freed from the baggage of software programming languages like C?
Could we build compilers that are faster, more correct, and easier to use?
How big is the design space for languages designed from the ground up for implementing hardware accelerators?

[hls-fuzz]: https://yannherklotz.com/papers/esrhls_fccm2021.pdf
[dahlia-paper]: https://rachitnigam.com/files/pubs/dahlia.pdf
[intel-hls]: https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/hls-compiler.html
[mentor-hls]: https://resources.sw.siemens.com/en-US/fact-sheet-catapult-high-level-synthesis-and-verification
[xilinx-hls]: https://www.xilinx.com/products/design-tools/vivado/integration/esl-design.html
[edgebert]: https://arxiv.org/abs/2011.14203
[vcu]: https://dl.acm.org/doi/abs/10.1145/3445814.3446723
[systemc]: https://accellera.org/community/systemc

### What Makes an Accelerator Design Language?

We need a name for the emerging class of programming languages meant for designing computational accelerators---to distinguish them from fully general hardware description languages (HDLs).
I'll call them *accelerator design languages* (ADLs).

Traditional HLS tools have accidentally created their own ADLs by extending C++ with vast suites of [custom annotations][legup-pragma] or [special libraries][hls-stream].
As a research area, it's heating up:
Stanford's [Spatial][] is a Scala embedded DSL for accelerator design;
Cornell's [HeteroCL][] uses an algorithm/schedule decoupling strategy;
and our own lab's [Dahlia][] features a novel type system for controlling hardware resources.
Similar efforts are underway in industry:
Microsoft has previewed an in-house ADL called [Sandpiper][],
and Google's open-source [XLS][] builds a custom ADL on a new intermediate representation.

All these ADLs differ from HDLs, from [Verilog][] and [Bluespec][] to [Chisel][] and [PyMTL][], in one critical way:
*they do not attempt to enable the design of arbitrary hardware*.
If you want to design the next great out-of-order RISC-V CPU, you'll want a proper HDL.
In exchange for full generality,
ADLs can offer *computational semantics:*
to understand what an ADL program does, you can read it like an algorithm mapping inputs to outputs.
To interpret an HDL design, in contrast, there is not really any general way around running an iterative, time-based hardware simulation.

These ADLs are different from domain-specific languages (DSLs).
While DSLs have also shown promise as an approach to making it easier to design accelerators in TK domains,
ADLs are different because they span application domains.
As important as DSLs will surely be in the era of specialized hardware designs, we will always need more general-purpose alternatives to fill in the gaps between popular computational domains.

[xls]: https://google.github.io/xls/
[sandpiper]: https://twitter.com/pldrnt/status/1300851721829261312
[dahlia]: https://capra.cs.cornell.edu/dahlia/
[heterocl]: https://heterocl.csl.cornell.edu/
[spatial]: https://spatial-lang.org/
[hls-stream]: https://www.xilinx.com/html_docs/xilinx2020_2/vitis_doc/hls_stream_library.html#mes1539734221433
[legup-pragma]: https://download-soc.microsemi.com/FPGA/HLS-EAP/docs/legup-9.1-docs/pragmas.html#pragmas
[pymtl]: https://www.chisel-lang.org/
[chisel]: https://www.chisel-lang.org/
[vhdl]: https://en.wikipedia.org/wiki/VHDL
[verilog]: https://en.wikipedia.org/wiki/Verilog
[bluespec]: http://wiki.bluespec.com/bluespec-systemverilog-and-compiler

### Challenges for the Next Generation of ADLs

As with software languages, there will never be one ADL to rule them all---we need a broad diversity of options that embrace different language paradigms,
strike different trade-offs between performance and productivity,
or offer special features for specific application domains.

TK
what are the fundamental concepts that ADLs will need to confront?
The challenge in designing an ADL is finding a way to express the essential complexity of accelerator design without adding too much accidental complexity.
Accelerator design inherits all the same challenges as parallel software programming and adds new concerns.
We need to identify those underlying concepts that form the marginal complexity of the accelerator setting and design languages to embody those.

<img src="{{site.base}}/media/adl/complexity3.png" class="img-responsive">

use/multiplexing of physical resources. that's the essential thing about hardware; you are creating computational objects *and then* using them to accomplish something

TK what should the goals be? balancing these competing objectives:

- computational semantics. (unlike HDLs.) should be able to understand its input-output behavior by reading the code, not doing a discrete event simulation. be up-front that I don't know exactly what "computational semantics" means.
- predictability and transparent cost models. put the tools into the hands of programmers; don't imagine that we'll isolate them from hardware concerns entirely

TK again, different languages will balance these goals differently. hide more to make the semantics more computational and therefore more understandable to programmers. reveal more hardware details to make performance optimization more tractable without relying on a mythical "sufficiently smart compiler."

TK *correctness*.
we should have the following revolutionary idea: correct translation is the compiler's responsibility, not the developer's! if the tool generates wrong hardware (down to the bit), that's a compiler bug, not something the developer needs to hunt down and fix.
imagine if you had to constantly check that your C program matched the assembly program and make manual changes to the latter if not! that's life today with mainstream HLS.
