---
layout: post
title: Put It in Hardware
excerpt: |
    Why does baking something into the hardware make it faster? It may seem obvious, but I think there are four distinct reasons for implementing something in hardware. It's cruicial to remember that they are separate advantages: architectures can "win" in some categories without addressing them all.
---
What functionality should be baked into the hardware, and what is better off as software? This is the eternal question of modern computer architecture.

When someone asks to put some functionality "in the hardware," they usually have efficiency---performance, power, or cost---in mind. (There are other benefits, like security, reliability, or programmability, but let's ignore those for now.)

It's easy to imagine that moving something into hardware will magically make it go faster: that we'll reap the benefits of that sweet [500× efficiency gain][horowitz] promised by silicon specialization.

[horowitz]: http://dl.acm.org/citation.cfm?id=1815968

There is, of course, no free efficiency lunch. A hardware implementation fundamentally does the same task as a software alternative. The same numbers are being multiplied; the same bits are being shifted; the same hash tables are being probed. You could change the algorithm when baking something into hardware, but that's a separate change. If we're not allowed to cheat that way, what essential advantage does hardware bring?

There are four major factors. They overlap and intersect, but it's important to keep them straight when arguing about the hardware--software divide.

### Generality vs. Efficiency

The first advantage comes from specialization: implementing a circuit that can only do one thing. An ASIC can eliminate fundamental inefficiencies inherent in a general-purpose processor. 

Concretely, specialized hardware can: allocate exactly the right number of registers for the algorithm's datapath and avoid sharing or spilling; provide exactly the right variety of arithmetic units, positioned in exactly the right place to avoid wire delay; and tune critical paths to optimize timing for the specific workload. Cutting out generality has fundamental efficiency benefits.

This advantage is what we tend to think of first as the reason for hardware implementation. And it's why we have [video decoding accelerators][quicksync] and [crypto circuitry][aesni] in mainstream processors today. But it's not the only advantage and, in some cases, it may not even be the most important one. The other facets, in the rest of this post, can be just as significant---and they don't imply the onerous design overhead of ASIC implementation.

[quicksync]: http://www.intel.com/content/www/us/en/architecture-and-technology/quick-sync-video/quick-sync-video-general.html
[aesni]: https://software.intel.com/en-us/articles/intel-advanced-encryption-standard-instructions-aes-ni

### Control Overhead

Implementing something in hardware---like a [type-checked memory load instruction][chkl] for speeding up JavaScript, for example, or [integer overflow checks][regehr]---means that the CPU has to process fewer instructions to do the same work.

Especially in modern, aggressively out-of-order superscalar processors, just managing instructions consumes a huge amount of the chip's resources---especially power. So if a JavaScript JIT can replace a sequence of a few instructions for every variable access with a single instruction, it can unlock enormous savings.

The concrete control-overhead costs of instructions include: the power spent to fetch, decode, and schedule each instruction; pressure on the [re-order buffer][rob], space occupied in the processor's in-flight window, and activation of the bypass network; and general-purpose register pressure for intermediate results. All of these overheads are mitigated by making instructions imply larger units of work.

Crucially, these benefits are *not* tied to specialized, custom circuits. In the true [CISC][] spirit, we can reap these benefits even with naively designed hardware, [automatically generated][ccores] circuits, or even [microcode][]. We can benefit from moving computations "into the hardware" without paying the high cost of custom circuit design.

[ccores]: http://cseweb.ucsd.edu/~jsampson/ConservationCores.pdf
[chkl]: http://homes.cs.washington.edu/~luisceze/publications/anderson-hpca2011.pdf
[microcode]: http://en.wikipedia.org/wiki/Microcode

### Code Size

Eliminating instructions from a computation has a corollary benefit: there are fewer instructions.

Specifically, programs can be smaller if they need fewer words to say the same thing. In an age where [memory is cheap][mem] and [disk is basically free][disk], it may seem strange to worry about code size. But there's one memory that still isn't big enough: the [instruction cache][icache].

[mem]: http://www.newegg.com/Product/Product.aspx?Item=N82E16820233299
[disk]: http://www.newegg.com/Product/Product.aspx?Item=N82E16822148834

I-cache misses are [depressingly common in "cloud" workloads][cloudsuite]. Apple's latest, most aggressive mobile core has [a minuscule 32kB I-cache][cyclone]. Every byte saved in the size of programs means a better chance of fitting on chip, which in turn implies more efficient execution.

[cyclone]: http://anandtech.com/show/7335/the-iphone-5s-review/3
[cloudsuite]: http://parsa.epfl.ch/cloudsuite/clearing-clouds.pdf

Like it or not, code size is one of the reasons [the x86 ISA][x86] is still with us. Although Intel CPUs are [RISC inside][uops], the CISCy exterior means that binaries remain compact. The moral of this story is that specialized instructions can be valuable even when the core has *no special logic at all* for those instructions, even when the same control overhead is incurred to process the micro-ops. Code size is an orthogonal benefit of adding hardware features.

[uops]: http://en.wikipedia.org/wiki/Micro-operation
[x86]: http://en.wikipedia.org/wiki/X86

### Abstraction Cost

A final reason to add hardware support is when the hardware knows things that the software doesn't know and can't efficiently discover. If the software is found to be recomputing results that are already microarchitectural state, it may be time to add hardware support.

This source of efficiency is an argument for keeping hardware-managed caches over [scratchpad memories][scratchpad], for example, or for [cache coherence][heretostay] over explicit [message passing][tilera]. While an application might be able to make better cache decisions than [LRU][lru], the hardware has an unassailable advantage: it knows exactly which lines are in cache without needing to ask.

Microarchitectural state is also essential to out-of-order processors' [dynamism][specdyn] advantage. A processor knows when a memory access misses in the L1 cache, for example, and hardware scheduling algorithms can respond immediately to reorder subsequent work. A software scheduler would need undue overhead to constantly monitor for L1 misses.

## What Belongs in Hardware?

When considering whether it's worth the cost for an architecture to provide some functionality, it's important we remember that hardware implementation's benefits do not arise only from circuit design. In fact, many of the benefits have nothing to do with efficient designs: control overhead, code size, and abstraction penalty can all be reduced without tackling the ASIC design problem. Architectures that aim for these less-obvious benefits can win by improving the ISA while sidestepping what we usually think of as "specialization."

[regehr]: http://blog.regehr.org/archives/1154
[heretostay]: http://acg.cis.upenn.edu/papers/cacm12_why_coherence.pdf
[tilera]: http://www.tilera.com
[lru]: http://en.wikipedia.org/wiki/Cache_algorithms#LRU
[specdyn]: http://dl.acm.org/citation.cfm?id=2451143
[scratchpad]: http://en.wikipedia.org/wiki/Scratchpad_memory
[icache]: http://stackoverflow.com/questions/22394750/what-is-meant-by-data-cache-and-instruction-cache
[rob]: http://en.wikipedia.org/wiki/Re-order_buffer
[cisc]: http://research.cs.wisc.edu/vertical/papers/2013/hpca13-isa-power-struggles.pdf
