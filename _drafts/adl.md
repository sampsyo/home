---
title: From Hardware Description Languages to Accelerator Design Languages
excerpt:
    TK
---
We need to make it easier to design custom, application-specific hardware accelerators.
The potential [efficiency gains][darwin] gains are [enormous][catapult], and the cost of deploying accelerators is falling rapidly with the [widespread][azurenp] [availability][f1] of [FPGA][intel-pac] [cards][xilinx-alveo] and the increasing accessibility of [custom silicon][google-tapeout].
As the cost of domain-specific hardware itself falls, the difficulty of designing custom accelerators remains a bottleneck.

The mainstream way to design custom hardware is with a general-purpose hardware description language (HDL) like [Verilog][] or [Chisel][].
The thesis of this post is that HDLs, while indispensable for implementing arbitrary hardware, are not the key to making computational specialization go mainstream.
We need a new name for an emerging and distinct class of languages that directly address the problem of accelerating applications:
let's call them *accelerator design languages* (ADLs).

As with software languages, there will never be a one-size-fits all ADL.
We need a diversity of approaches that strike different balances between generality, optimality, and productivity.
Industry's current focus is on *high-level synthesis* (HLS) tools, which repurpose C-based programming languages with restrictions and extensions to form ADLs that prioritize familiarity for C programmers.
This post is a call for more research to explore the broader, C-free design space of ADLs, their compilers, and their accompanying tools.
A healthy ecosystem of ADLs can distribute the power of specialized computing to all domain experts, not just hardware designers.

[darwin]: http://bejerano.stanford.edu/papers/p199-turakhia.pdf
[catapult]: https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/Catapult_ISCA_2014.pdf
[xilinx-alveo]: https://www.xilinx.com/products/boards-and-kits/alveo.html
[intel-pac]: https://www.intel.com/content/www/us/en/products/details/fpga/platforms/pac.html
[f1]: https://aws.amazon.com/ec2/instance-types/f1/
[azurenp]: https://docs.microsoft.com/en-us/azure/virtual-machines/np-series
[google-tapeout]: https://www.fossi-foundation.org/2020/06/30/skywater-pdk

### Essential vs. Accidental Complexity in Accelerator Design

Two kinds of factors make accelerator design hard today:
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

The problem is the abstraction level.
*Too much* detail and control over performance can paradoxically make it harder to productively iterate toward a fast implementation.
Just as not all high-performance software needs to drop down to the level of assembly,
not all accelerator design needs the granular control that HDLs offer.

HDLs have their place: they remain the right tool for the job when designing general-purpose processors, for example.
But my thesis here is that their ability to express arbitrary circuits is unnecessary when the goal is to design fixed-function hardware for a specific computation.
HDLs are indispensable for standard circuit construction, in the same way that assembly programming today remains indispensable for extreme performance tuning, embedded systems, and other niches.
And in the same way that a vanishing minority of software in the 21st century is written directly in assembly, even in performance-sensitive scenarios, HDLs impose more complexity than mainstream accelerator designers of the future should need to deal with.

If hardware acceleration is going to go mainstream, we need alternatives that embrace different levels of abstraction.
The key challenge is to identify the key factors in the *essential complexity* of hardware design---the fundamental factors that make it harder than other parallel programming---and to embody that complexity in a programming model.
What would a programming language look like that was designed from the ground up for implementing efficient algorithmic accelerators?

### Under the C

Today, the commercially successful answer to this question lies in *high-level synthesis* (HLS) tools.
HLS compilers from [Xilinx][xilinx-hls], [Mentor][mentor-hls], and [Intel][intel-hls] can already generate high-quality HDL implementations from programs written in C, C++, or OpenCL.
To work around C's sequential-first, pointer-based semantics,
HLS tools extend the language with vendor-specific `#pragma` annotations or [SystemC][] constructs.
HLS research and products have made huge strides in recent years---Harvard's [EdgeBERT][] and Google's [VCU][] are two high-profile examples of hardware accelerators that have relied on HLS for significant parts of their design.
Anecdotally, hardware designers appreciate HLS tools' ability to automate
tedious tasks in hardware design like scheduling the operators on a data path, constructing basic pipelines to match sequential semantics, and inserting registers.

However, traditional C-based HLS tools have succeeded *despite* their grounding in C---not because of it.
By reusing a legacy software language, they create a semantic gap that in turn yields correctness and performance pitfalls.
Recently,
researchers at Imperial College London [used fuzz testing to find a torrent of bugs in mature HLS tools][hls-fuzz] when compiling even simple C code,
and our lab at Cornell [identified performance predictability problems][dahlia-paper]
where small, seemingly benign changes in the input program can yield wild changes in the generated hardware's size and speed.
While reusing C promises compatibility and familiarity, it also comes at a cost in reliability and transparency.

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
While DSLs have also shown promise as an approach to making it easier to design accelerators in domains like [image processing][aetherling] or [networking][p4fpga],
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
[aetherling]: https://aetherling.org
[p4fpga]: https://dl.acm.org/doi/10.1145/3050220.3050234

### The Marginal Complexity of Accelerator Design

As with software languages, there will never be one ADL to rule them all---we need a diversity of options that embrace different language paradigms,
strike different trade-offs between performance and productivity,
or offer special features for specific application domains.

In any ADL design, the central challenge is expressing the fundamental concepts in accelerator design that humans need to be aware of---to convey the essential complexity of the task without adding too much accidental complexity.
In the same way that parallel programming models need to contend with essential concepts like synchronization that do not exist in sequential programming,
ADLs will need to design abstractions for the new concepts in hardware implementation that go beyond ordinary parallel programming.

<img src="{{site.base}}/media/adl/complexity3.png" class="img-responsive">

What are those concepts that form the *marginal complexity* of accelerator design, relative to writing parallel software?
Identifying and abstracting these concepts will be the hard work that ADL designers need to do.
In my experience, this extra complexity boils down to two main categories:

* *Physicality.* Perhaps the most fundamental thing about hardware is that computation uses finite, physical resources to do its work. When an accelerator performs a floating-point multiplication, for example, that has to happen *somewhere*---it needs to dedicate an FPU to that computation. And meanwhile, it needs to take care not to simultaneously try to use the same FPU to do something else at the same time. While CPUs of course also need to allocate computational resources to computations, they do it implicitly---whereas accelerator designs have to manage it as a first-class design concern.
* *Time.* While parallel software has to deal with a notion of *logical time*, such as a happens-before relation for ordering events between threads, hardware accelerators need to contend with *physical time* in the form of clock cycles. Cycle-level timing is an added dimension of complexity, but it also gives accelerators the unique ability to ensure determinism: that a given computation takes 100 cycles, every time, with no exceptions. This determinism is an important advantage over even high-performance processors: for many use cases such as datacenter networking, 100 deterministic cycles might be preferable to a CPU that takes 80 cycles most of the time but 500 cycles in rare exceptions.

The focus of the next generation of ADLs should be on establishing abstractions for physicality and time.
The design of these abstractions will inevitably need to balance *transparency* with *simplicity*.
On one hand, ADLs need to be simple and algorithmic that their semantics is clear to programmers.
On the other, abstractions need to transparently reflect the cost model of the underlying hardware-level concerns to give programmers enough control so they have a shot at optimizing their code.

These goals are clearly in tension.
Different languages will balance them differently: they can hide more details to make the semantics more algorithmic and software-like,
or they can expose more details to make performance optimization more tractable without relying on a mythical "sufficiently smart compiler" to someday arrive.
Just as we already have in the wide world of software languages, ADLs should proliferate the design space with different balances for different audiences and different use cases.
A single paradigm will not suffice to bring accelerator design into the mainstream, and we need a broad research effort to explore the full space of approaches that will.
