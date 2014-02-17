---
title: "What Is Macroscalar?"
kind: article
layout: post
excerpt: |
    A couple months ago, [a story][ars] made the nerd-press rounds about Apple's trademark application and several patents for something called a "macroscalar" processor architecture. I've taken a stab at decoding the publicly available information about macroscalar architectures to give a coherent picture of the idea.

    [ars]: http://arstechnica.com/apple/news/2012/02/apple-trademark-may-hint-at-processing-improvement-for-next-gen-a6-processor.ars
---
A couple months ago, [a story][ars] made the nerd-press rounds about Apple's [trademark application][macroscalar trademark] and several patents (from [2004](http://www.google.com/patents/US7395419), [2005](http://www.google.com/patents/US7617496), and [2009](http://www.google.com/patents/US8065502)) for something called a "macroscalar" processor architecture. Of course, like any tech company these days, Apple patents any old thing---most things Apple patents are never even intended to see the light of day. But the surprising thing in this case is that the patents are about microarchitecture: a game that Apple has never played before.

[macroscalar trademark]: http://tarr.uspto.gov/servlet/tarr?regser=serial&entry=85530375
[ars]: http://arstechnica.com/apple/news/2012/02/apple-trademark-may-hint-at-processing-improvement-for-next-gen-a6-processor.ars

Over its 36-year history, Apple has depended on other companies' CPU designs. The Apple I and II used variants of the [MOS Technology 6502][6502] microprocessor. The Mac's processors [came from Motorola][68k], and later from [IBM/Motorla/Freescale][powerpc]; now they're [supplied by Intel][macintel]. iOS devices today use Apple-designed systems-on-a-chip (SoCs) like the [A5X][], but even this custom silicon sports CPU core designs licensed from ARM (namely, the [Cortex A9][] used in nearly every current smartphone SoC on the market except Qualcomm's [Snapdragon][]). Could Apple's next step in its quest to control every aspect of its shiny products be to enter the formidable microarchitecture fray with Intel, AMD, ARM, Qualcomm, IBM, and Oracle? The company's 2008 and 2010 acquisitions of small chip design firms [P. A. Semi][] and [Intrinsity][] suggests, as unlikely as it may seem, that Apple might believe they can achieve significant power, performance, or functionality gains by going toe-to-toe with the microarchitectural establishment.

[A5X]: http://www.anandtech.com/show/5686/apples-a5x-floorplan
[Cortex A9]: http://www.arm.com/products/processors/cortex-a/cortex-a9.php
[Snapdragon]: http://www.qualcomm.com/snapdragon 
[powerpc]: http://en.wikipedia.org/wiki/PowerPC
[68k]: http://en.wikipedia.org/wiki/Motorola_68000_family 
[6502]: http://www.6502.org/homebuilt
[macintel]: http://en.wikipedia.org/wiki/Apple–Intel_architecture
[P. A. Semi]: http://arstechnica.com/apple/news/2008/04/apple-disses-intels-atom-buys-powerpc-designer-pa-semi.ars
[intrinsity]: http://arstechnica.com/apple/news/2010/04/apple-purchase-of-intrinsity-confirmed.ars

If Apple were to get into the CPU design business, this move would represent a major shift in consumer electronics: as far as I know, Apple would be the only company to sell "whole widgets" to consumers featuring their own in-house microarchitecture. And, if this move proves not to be mere [NIH][]ism and the iPads of the future are way more awesome because of their new Apple-designed processor cores, it could lead to a sea change in the computer architecture landscape and the way that consumer electronics companies compete.

[NIH]: http://en.wikipedia.org/wiki/Not_invented_here

## Decoding Macroscalar

Because of the potential significance of the change, it's worth looking closer what Apple's architects might be working on. We outsiders have no evidence either way about whether Apple intends to do anything at all with its "macroscalar architecture" patents and trademark, but even so, grokking the idea might help us understand what they might be up to.

But some cursory googling reveals that news outlets have only reported on the idea in broad strokes. [Robin Harris at ZDNet][zdnet] writes about the etymology of the "macroscalar" neologism (brand?) and gives some background on unrolling and vectorization; [Chris Foresman at Ars Technica][ars] outlines the broad idea somewhat more technically; but I haven't found any attempts at deeper understanding of the technique. I like to think of myself as a computer architect (I'm a third-year Ph.D. student in the area), so I've taken a stab at decoding the publicly available information about "macroscalar" architectures to give a coherent picture of the idea.

[zdnet]: http://www.zdnet.com/blog/storage/apples-macroscalar-architecture-what-it-is-what-it-means/1435

First, a caveat: patents are terrible, monstrous documents full of "one or more"s and "according to another embodiment"s. They're obtusely written and probably elide important details intentionally. (I even believe that patents can often [hamper innovation more than they help][tal].) But for the benefit of you, dear reader, I have slogged through the legalese to extract what I believe to be the core of the "macroscalar" idea. But because patents are all I have to work with, it's possible I misunderstood the whole thing and have grossly mischaracterized it here. Please [get in touch](mailto:asampson@cs.washington.edu) if you find any errors.

[tal]: http://www.thisamericanlife.org/radio-archives/episode/441/when-patents-attack

I'll first summarize the design in a more general-interest way and then give a technical explanation, suitable for people familiar with computer architecture. Depending on who you are, you'll probably want to read one section and skip the other.

## Somewhat Less Technical Summary

Read this section if you're a technical person but aren't necessarily interested in hardcore architectural details. If you are familiar with the basics of computer architecture, you might find this section redundant and unsatisfying---skip to the next one.

[*Out-of-order* (OoO) processing][ooo] is a technique used by many CPU designs today to execute programs faster. OoO processors reorder instructions so that they run as soon as their inputs are available, taking advantage of the fact that two instructions that work on different pieces of data can run in any order without changing the meaning of the program. These processors can also take advantage of [many extra registers][physical registers] (on-chip storage units) without requiring the program to be recompiled to use them. However, classic out-of-order designs are quite complex---they have to dynamically look for communication ("dependencies") between instructions to decide which order to execute them in.

[physical registers]: http://en.wikipedia.org/wiki/Register_renaming
[ooo]: http://en.wikipedia.org/wiki/Out-of-order_execution

Macroscalar architecture takes some ideas from OoO design---reordering instructions and using extra registers without recompilation---to get some of the speedups of OoO execution without all the complexity. Complexity in processors is expensive: it consumes valuable design and testing time, it makes the processor more prone to bugs, it uses up valuable transistors, and it can make CPUs use more energy. So, even if macroscalar designs can't fully match the performance of their OoO counterparts, they might be worth it because of their advantages in power efficiency, time-to-market, and silicon area.

Specifically, macroscalar processors only accelerate tight loops that do a lot of similar computation over many different pieces of data. With some help from the compiler (but without requiring recompilation for every new chip design), the processor finds parts of a loop that are independent and interleaves them so that several iterations of the loop run in a single pass. (The process is similar to [loop unrolling][], an optimization traditionally performed by compilers rather than processors.) By relying on information from the compiler about instruction dependencies, the processor can perform this instruction reordering without checking for [communication problems][pipeline hazards] as OoO processors must.

[pipeline hazards]: http://en.wikipedia.org/wiki/Hazard_(computer_architecture)

Because the world doesn't have any macroscalar processors to experiment on (even simulated ones), it's not clear how close they can come to matching traditional OoO processors' performance or how much complexity they really save. But it's plausible that, because tight loops make up important parts of many programs, macroscalar execution could get many of the benefits of OoO execution for some applications while not using as much energy.

[loop unrolling]: http://cs.oberlin.edu/~jdonalds/317/lecture18.html

## Technical Description

Read this section if you're a big nerd and know a little bit about modern computer architecture. If you're an ordinary, curious nerd of the non-architect type, you may want to skip this one.

Macroscalar design is a technique for extracting instruction-level parallelism (or, possibly, loop-level parallelism). It's a high-level microarchitecture style: an *alternative*, rather than an extension, to today's pervasive out-of-order superscalar designs, VLIW architectures, or vector machines. So it's appropriate to think of the proposal as an improvement over a base *in-order* design rather than a modification of an OoO design. Some aspects of the macroscalar architecture look like structures found in familiar OoO or vector processors, but resist the temptation to dismiss these aspects as redundant—remember, we're exploring *alternatives* to these better-known designs.

Another important takeaway: the technique depends on limited co-design with a compiler. Unlike superscalar processors, which transparently accelerate binaries compiled to target in-order cores, macroscalar architectures require lightweight compiler annotations on loop bodies.

The macroscalar technique focuses on breaking false cross-iteration dependencies in loops to partially parallelize them and to take advantage of additional physical registers. This process is called *dynamic loop aggregation*, but as a first approximation, let's begin by thinking of it as dynamic [loop unrolling][].

### Loop Unrolling

Unrolling, of course, is typically used by compilers to (among other things) keep pipelined functional units busy. Consider a loop that squares the elements of an array in place (here I'm borrowing an example used in the patent). Here's some pseudo-assembly for such a loop:

    i = 0
    L1:
    val = arr[i]
    val *= val
    arr[i] = val
    i++
    cmp i max
    jne L1

(Here, all the "variables" I'm using are stored in registers; `arr` and `max` are inputs. Also, assume for the moment that the array loads and stores always hit in the first-level cache.) If the multiplier has a latency of, say, four cycles, then there are three wasted cycles between the multiply and the store. One iteration thus takes 7 cycles (not counting the jump). An optimizing compiler might unroll this loop and issue four multiplies in sequence. Here's an unrolled loop body (I'm omitting the head and tail of the loop):

    i1 = 0
    i2 = 1
    i3 = 2
    i4 = 3
    L1:
    val1 = arr[i1]
    val2 = arr[i2]
    val3 = arr[i3]
    val4 = arr[i4]
    val1 *= val1
    val2 *= val2
    val3 *= val3
    val4 *= val4
    arr[i1] = val1
    arr[i2] = val2
    arr[i3] = val3
    arr[i4] = val4
    i1 += 4
    i2 += 4
    i3 += 4
    i4 += 4

Now, assuming the non-multiply instructions execute in a single cycle, the loop performs four iterations in 16 cycles because each multiply result (`val#`) is ready when it's consumed by the corresponding array store. Unrolling bought us a speedup of three cycles per iteration.

Of course, unrolling requires more available registers and a knowledge of operation latencies. If a compiler wants to get the most out of loop unrolling, it needs to know how many registers are available and statically allocate registers to different iterations of a loop. With loop aggregation, the *processor* essentially performs loop unrolling instead of the compiler, relaxing the need for microarchitecture-specific optimization and freeing the design to transparently take advantage of large register files that are hidden from the ISA.

### Dynamic Loop Aggregation

When targeting a macroscalar architecture, a compiler provides some metadata for each program loop that allows the architecture to perform loop unrolling on its own terms. Specifically, the processor gets to decide *how much* to unroll the loop. In the jargon of the patents, the processor determines the *loop aggregation factor* or *F*. (In our example above, *F* = 4.)

To unroll a loop requires a bunch of extra registers. To this end, macroscalar architectures reuse a fundamental idea from OoO design: distinction between a small set of architected registers and a larger set of physical registers that are not exposed in the ISA. In macroscalar, the hidden registers are called *extended registers* or XRs. Each architected register is also backed by a single physical register—the architected registers are not merely abstract constructs. The XR file is used only for loop aggregation.

To enable aggregation, the compiler analyzes the loop body and identifies the (architected) registers that are used in an iteration-local way, called the *dynamic registers* or DRs. Pedantically, DRs are those that are written before they are first read in the loop body; in our example, `val` is a dynamic register. The register used for iteration, `i`, is also considered a dynamic register. The remaining registers, which are read-only in the loop body, are called *static registers* or SRs—`arr` above, for example. (Note that neither category can express a cross-iteration dependency, which would exhibit a read followed by a write in the body. Cross-iteration dependencies will be dealt with later.) To unroll with factor *F*, the processor needs enough XRs (physical registers) to store *F* copies of each DR, so it calculates *F* = *D* ÷ *X* where *D* is the number of DRs and *X* is the number of available XRs.

So the compiler provides two annotations for every aggregate-able loop:

* Which (architected) registers are DRs and which are SRs. (For example, the compiler could use low-numbered registers as DRs and write down the index of the last DR.)
* Which register is used as the loop index, so it can be initialized. Specifically, the compiler replaces the zero-initialization (something like `mov $0 rN`) with a special instruction `index rN`. When the loop is aggregated, the many XRs corresponding to the index DR will be initialized to the first few natural numbers (0, 1, 2, ..., *F*-1).

The processor uses this information to determine the aggregation factor *F*, translate DR references to XR references, and replicate instructions in the loop body.

### Implementation

To implement aggregation, the architecture uses elements called *iteration units* coupled with each *execution unit* (which you can think of as a functional unit for now). Iteration units are responsible for receiving *primary instructions* (program instructions) and transforming each into a sequence of *secondary instructions*, which are the unrolled copies of the original instructions adapted to use XRs. This approach mostly separates the loop aggregation logic from the ordinary instruction fetch and decode units, which only need to deal with primary instructions.

In each iteration of the aggregated loop, *F* (the number of program iterations to be executed during the current aggregated iteration) is calculated. Then, the issue logic sends *F* along with each primary instruction to the iteration units. The iteration units immediately begin creating the *F* corresponding secondary instructions and sending them to the functional unit. Because the primary instructions are issued in program order, the secondary instructions execute in the same order, ensuring that dependencies are satisfied without explicit coordination between the iteration units.

The relative independence of the iteration units may comprise a complexity advantage over OoO design: no explicit dependence management or scheduling is necessary to expose ILP.

### Parallelization

So far, loop aggregation has bought us essentially the same performance benefits as loop unrolling but in a microarchitecture-independent way. The performance benefits come from dynamically choosing to interleave instructions in a way that avoids stalls due to register dependencies, which is reminiscent of the benefits offered by single-issue OoO design. However, the macroscalar design can go beyond instruction ordering and execute multiple instructions simultaneously---a feature typically associated with superscalar designs and vector (SIMD) instructions.

To do this, the patent proposes pairing every iteration unit with *multiple* FUs. This way, the iteration unit can kick off several secondary instructions in each cycle. In this sense, loop aggregation can look like vectorization: if a macroscalar chip has four multipliers, then the corresponding iteration unit can multiply four adjacent numbers in an array "all at once" based on a single program (primary) instruction.

Parallelizing the execution of secondary instructions necessarily complicates the instruction scheduling problem. The patent proposes a simplistic solution here: only use *N*-way parallelism when *all* the units involved in some loop body can issue at least *N* secondary instructions at once (i.e., the degree of parallelism falls to that of the least-parallel execution unit).

### Loop-Carried Dependencies

Until this point, we've only considered loops without data dependencies between iterations (sometimes "DoAll" loops). In practice, many loops read variables that are updated in previous iterations. Loop aggregation clearly breaks in these cases: transposing instructions to use independent XRs instead of shared architected registers effectively isolates loop iterations from one another.

To deal with loop-carried dependencies, a compiler for a macroscalar architecture delineates loop bodies into sections with and without such dependencies. The dependent parts of a loop are called *sequence blocks* and the independent parts are called *vector blocks*. The compiler uses a third kind of annotation to distinguish the instruction ranges that make up these blocks; at runtime, the processor only iterates the instructions in vector blocks. Sequence blocks are executed in order and skip the iteration units entirely---the instruction issue logic sends primary instructions from sequence blocks directly to the execution units.

It's unclear to me how effective this analysis can be on real programs. As a wild, unsubstantiated guess, I would venture that most loop-carried dependencies affect large portions of a loop---that is, if a given loop has a single cross-iteration dependence, then the entire loop body is likely to be dependent. I can't think of a real-world example where only a small, isolated portion of a loop carries a dependence but the rest is independent and thus vectorizable.

### Other Topics

For the purposes of this (already-too-long) article, I'm omitting some less-interesting details from the patents that nonetheless are critical to making macroscalar designs viable:

* Handling nested loops. Compiler instrumentation and hardware structures are used to efficiently support aggregating nested loops that draw from the same pool of XRs.
* Loop control flow. Special flags are used to implement C's `continue`, `break`, and `return`. In the latter two cases, limited rollback is necessary to conceal the effects of partially-executed iterations after the loop is terminated.
* Context switching and OS support.
* Exception handling.
* Predication. Because aggregated vector blocks are not allowed to contain control flow, predicated instructions and predicated blocks are used to avoid branching when the program loop contains conditionals.
* Prefetch. The patents propose using an aggressive stride-based stream prefetcher to help ensure that regular memory accesses in vector blocks rarely miss.

For the curious, the patents do give a complete architectural picture (with the notable exception, of course, of empirical evaluation). Few details are omitted if you're willing to wade through the legalese.

## My Opinion

Dynamic loop aggregation is a legitimately interesting idea and macroscalar could have a shot at being a viable high-level core design strategy. For several reasons, however---its competitiveness with OoO, the unimportance of ISA opacity, and the fading relevance of instruction-level parallelism (ILP)---I don't believe that Apple will ever sell a macroscalar iPad.

Macroscalar architecture is an enhancement to in-order designs. It is mutually exclusive with (or, at best, orthogonal to) out-of-order superscalar, VLIW, and vector machines---traditional approaches to extracting ILP. So the relevant question is: What advantages might a macroscalar processor have over a traditional superscalar one or a statically scheduled ILP technique like SIMD or VLIW? The patents don't address this comparison directly, but I'll try to give a reasonable perspective here.

Over OoO techniques, I believe the potential advantages are twofold:

* Complexity (and, consequently, power and area): Macroscalar designs can be seen as a simpler, lower-power way to get ILP in constrained situations. It remains to be seen *how much* simpler it is than OoO and how much ILP it can expose in real applications.
* Fetch and decode: By iterating "secondary" instructions post-decode, loop aggregation may have a positive effect on code size (and thus I-cache pressure) as well as the power overhead of instruction decode logic.

The magnitude of both effects will never be clear without an empirical evaluation, but it's hard to believe that a large advantage can be eked out over optimized OoO designs. The ever-popular [Cortex A9][] is itself out-of-order and dual-issue, providing an existence proof of energy-efficient superscalar processing.

Over VLIW and vector machines, macroscalar processors offer abstraction from microarchitectural parameters. Here macroscalar's case is even weaker than it is against OoO: I believe ISAs of the future will trend toward *more* compiler--architecture co-design, not less. This goes doubly for Apple: they already have [their own compiler infrastructure][llvm] and [a tightly controlled software deployment system][app store]. If Apple eventually also builds its own CPUs, it will be perfectly positioned to generate hardware-specific binaries even for third-party apps (using either offline or JIT compilation). If Apple controls the whole widget, including the compiler, it has little incentive to  carefully tailor an ISA for backward- and forward-compatibility. In this setting, explicit SIMD instructions (or GPGPUs) are likely to offer all the benefits of macroscalar at even lower complexity.

[app store]: http://www.apple.com/mac/app-store/
[llvm]: http://llvm.org/

Broadly, I am bearish on macroscalar because now is not the time to be making drastic architectural changes for the sake of a little ILP. There are many more critical problems to be addressed, such as [manycores][] and [their programmability][multicore programmability], [heterogeneous SoCs][heterogeneous multicore], and [dark silicon][] constraints. Tweaks to single-threaded ILP exploitation solve none of them. If compiler--architecture co-design is on the table, much more radical opportunities are available.

[manycores]: http://www.tilera.com/
[dark silicon]: http://www.cs.utexas.edu/~hadi/doc/paper/2011-isca-dark_silicon.pdf
[heterogeneous multicore]: http://www.arm.com/products/processors/technologies/bigLITTLEprocessing.php
[multicore programmability]: http://sampa.cs.washington.edu/sampa/Deterministic_MultiProcessing_(DMP)

While macroscalar may not be Apple's future in-house microarchitecture, it seems clear that they will eventually have one. There are too many Apple job postings for [RTL designers][rtl job], [circuit engineers][circuit job], and [compiler designers with "experience with developing compilers for novel micro-architectures and instruction sets"][llvm job] for the macroscalar patents to be a one-time affair. I'm excited to see what Apple's microarchitecture offers---beyond progress in the company's ongoing quest to control every last detail of its products.

[llvm job]: http://jobs.apple.com/index.ajs?method=mExternal.showJob&RID=100006
[rtl job]: http://jobs.apple.com/index.ajs?method=mExternal.showJob&RID=105000
[circuit job]: http://jobs.apple.com/index.ajs?method=mExternal.showJob&RID=111908

