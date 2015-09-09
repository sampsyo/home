---
title: "The Apple ISA"
excerpt: |
    On the eve of yet another Apple hype event, I throw my hat into the prognostication ring: Apple is on track to diverge from ARM and x86 to its own proprietary instruction set.
---
# The Apple ISA

[Apple][]'s institutional personality is easy to describe. Ruthless secrecy, monolithic opacity, and taste come to mind. But perhaps more than anything else, Apple wants to own [the whole widget][whole widget].

<figure style="max-width: 250px;">
<img src="{{ site.base }}/media/applestack.svg" alt="Apple controls its language, compiler, delivery system, microarchitecture, SoC, and devices. Not to mention its IDE and OS. But not its ISA.">
</figure>

It's not surprising, then, that Apple controls almost every bit of the stack that executes its software. Apple makes its own [programming language][swift], it sets the rules for its [App Store][], and---since [2012][a6]---it's one of [only][intel] [a][amd] [handful][arm] [of][qualcomm] [players][nvidia] in the consumer CPU business. Apple has always embraced vertical integration over the rest of the industry's commodification, and recent years have only further consolidated its technology stack.

It *is* surprising that one last gap remains in the middle of this stack of system exclusivity: Apple [licenses][armlicense] the [instruction set architecture][isa] for its mobile devices from [ARM][].

Licensing an existing ISA might seem inevitable: when was the last time a brand-new ISA succeeded? ARM, [from 1985][armwiki], is a baby next to x86, which [dates to 1978][x86]. IBM still makes [new machines][systemz] compatible with [its 1964 model][s360]. One does not simply walk into ISA design.

But Apple's outsourcing of this one crucial piece at the heart of its system design looks increasingly impractical. TK reasons are disappearing.

In the Apple ecosystem, ARM is just a serialization format for [LLVM][] to convey information to the Apple microarchitecture. And it's not a great serialization format: a traditional ISA like ARM forces a [semantic gap][], where the architecture needs to spend time and energy rediscovering facts that the compiler already knew.

TK we have lots of ideas for better kinds of ISAs, but they stagnate because of compatibility. Architects tend to agree that (a) we need more [hardware--software co-design][snapl], and than (b) backwards compatibility is an impediment to progress.

A few months ago, Apple announced that [you can ship apps compiled to LLVM IR][bitcode] instead of as ARM machine code. (In fact, this is the only way to ship code for the [Apple Watch][watch]---its ISA is already completely hidden from third-party developers.) Apple pundits have inferred that the bitcode development indicates ARM Macs or, even less plausibly, x86 phones. But it's far more likely it means Apple hardware will move away from both.

Apple's [macroscalar][] effort indicates TK.
And [Nvidia][]'s [Denver][] core already does something similar using [dynamic binary translation][transmeta].
Maybe not [tomorrow][sep9], but an Apple ISA is coming.

[whole widget]: https://www.youtube.com/watch?v=V0OpB5THBOg
[armlicense]: http://www.arm.com/products/buying-guide/licensing/index.php
[a6]: https://en.wikipedia.org/wiki/Apple_A6
[armwiki]: https://en.wikipedia.org/wiki/ARM_architecture
[x86]: https://en.wikipedia.org/wiki/X86
[systemz]: https://en.wikipedia.org/wiki/IBM_System_z
[s360]: https://en.wikipedia.org/wiki/IBM_System/360_architecture
[denver]: https://en.wikipedia.org/wiki/Project_Denver
[transmeta]: https://en.wikipedia.org/wiki/Transmeta
[sep9]: http://www.apple.com/apple-events/september-2015/
[snapl]: {{site.base}}/media/papers/cliche-snapl2015.pdf
[bitcode]: https://developer.apple.com/library/prerelease/watchos/documentation/IDEs/Conceptual/AppDistributionGuide/AppThinning/AppThinning.html#//apple_ref/doc/uid/TP40012582-CH35-SW2
[watch]: http://www.apple.com/watch/
[intel]: http://www.intel.com/
[qualcomm]: https://www.qualcomm.com/
[arm]: http://www.arm.com/
[nvidia]: http://www.nvidia.com/
[apple]: http://www.apple.com/
[app store]: https://twitter.com/AppStore
[amd]: http://www.amd.com/
[macroscalar]: {{site.base}}/blog/macroscalar.html
[isa]: https://en.wikipedia.org/wiki/Instruction_set
[semantic gap]: https://en.wikipedia.org/wiki/Semantic_gap
[llvm]: http://llvm.org/
