---
title: FPGAs Have the Wrong Abstraction
excerpt: Verilog is the *de facto* abstraction for programming today's FPGAs. RTL programming is fine if you want to use FPGAs for their traditional purpose as circuit emulators, but it's not the right thing for the new view of FPGAs as general-purpose computational accelerators.
---
<aside>
These are notes from a short talk I’ll do at an &ldquo;open mic&rdquo; that some Microsoft folks are hosting at FCRC this weekend.
</aside>

## The Computational FPGA

What is an FPGA?

I don’t think the architecture community has a consensus definition.
Let’s entertain three possible answers:

**Definition 1:** *An FPGA is a bunch of transistors that you can wire up to make any circuit you want.* It’s like a breadboard at nanometer scale. Having an FPGA is like taping out a chip, but you only need to buy one chip to build lots of different designs---and you take an efficiency penalty in exchange.

I don’t like this answer.
It’s neither literally true nor a solid metaphor for how people actually use FPGAs.

It’s not literally true because of course you don’t literally rewire an FPGA---it’s actually a 2D grid of lookup tables connected by a routing network, with some arithmetic units and memories thrown in for good measure.
FPGAs do a pretty good job of faking arbitrary circuits, but they really are faking it, in the same way that a software circuit emulator fakes it.

The answer doesn’t work metaphorically because it oversimplifies the way people actually use FPGAs.
The next two definitions will do a better job of describing what FPGAs are for.

**Definition 2:** *An FPGA is a cheaper alternative to making a custom chip, for prototyping and lower-volume production.* If you’re building a router, you can avoid the immense cost of taping out a new chip for it and instead ship an off-the-shelf FPGA programmed with the functionality you need. Or if you’re designing a CPU, you can use an FPGA as a prototype: you can build a real, bootable system around it for testing and snazzy demos before you ship the design off to a fab.

This is the classic, mainstream use case for FPGAs, and it’s the reason FPGAs exist in the first place.
The point of an FPGA is to take a hardware design, in the form of HDL code, and to get cheap hardware that behaves the same as the ASIC you would eventually produce.
Of course everybody knows you’re unlikely to take *exactly* the same Verilog code and make it work both on an FPGA and on real silicon, but it’s not wrong to think of an FPGA as a circuit emulator.

**Definition 3:** *An FPGA is a pseudo-general-purpose computational accelerator.* Like a GPGPU, an FPGA is good for offloading a certain kind of computation. It’s harder to program than a CPU, but for the right workload, it can be worth the effort: a good FPGA implementation can offer orders-of-magnitude performance and energy advantages over a CPU baseline on certain kernels.

This is a completely different use case from ASIC prototyping.
Unlike circuit emulation, computational acceleration is an *emerging* use case for FPGAs.
It’s behind the recent Microsoft successes accelerating [search][catapult] and [deep neural networks][brainwave].
And critically, the computational use case doesn’t depend on FPGAs’ relationship to real ASICs:
the Verilog code people write for FPGA-based acceleration need not bear any similarity to the kind of Verilog that would go into a proper tapeout.

[catapult]: https://www.microsoft.com/en-us/research/project/project-catapult/
[brainwave]: https://www.microsoft.com/en-us/research/project/project-brainwave/

These two use cases are different, especially in their implications for programming, compilers, and abstractions.
I want to focus on the latter, which I’ll call *computational FPGA* programming.
My thesis here is that the current approach to programming computational FPGAs, which borrows the traditional programming model from circuit emulation, is not the right thing.
Verilog and VHDL are exactly the right thing if you want to prototype an ASIC.
But we can and should rethink the entire stack for when the goal is computational efficiency.

## The GPU--FPGA Analogy

Let’s be ruthlessly literal.
An FPGA is a special kind of hardware for efficiently executing a special kind of software that resembles a circuit description.
An FPGA configuration is a funky kind of software, but it’s software, not hardware---it’s a program written for a strange ISA.

There’s a strong analogy here to GPUs.
Before deep learning and before dogecoin, there was a time when GPUs were for graphics.
[In the early 2000s][gpumm], people realized they could abuse a GPU as an accelerator for lots of computationally intensive kernels that had nothing to do with graphics: that GPU designers had built a more general kind of machine, for which graphics was just one application.

Computational FPGAs are following the same trajectory.
The idea is to abuse this hardware not for circuit emulation but to exploit computational patterns that make them amenable to circuit-like execution.
In the form of an SAT analogy:

<p class="showcase">
GPU : graphics :: FPGA : circuit simulation
</p>

To let GPUs blossom into the data-parallel accelerators they are today, people had to reframe the concept of what a GPU takes as input.
We used to think of a GPU taking in an exotic, intensely domain specific description of a visual effect.
We unlocked their true potential by realizing that GPUs execute *programs*.
This realization let GPUs evolve from targeting a particular application domain to a broad *computational* domain.
I think we’re in the midst of a similar transition with computational FPGAs:

<p class="showcase">
GPU : massive, mostly regular data parallelism :: FPGA : irregular parallelism with static structure
</p>

The world hasn’t settled yet on a succinct description of the fundamental computational pattern that FPGAs are supposed to be good at.
But it has something to do with potentially-irregular parallelism, data reuse, and mostly-static data flow.
Like GPUs, FPGAs need a hardware abstraction that embodies this computational pattern:

<p class="showcase">
GPU : SIMT ISA :: FPGA : ____
</p>

What’s missing here is an ISA-like abstraction for the *software* that FPGAs run.

[gpumm]: https://graphics.stanford.edu/papers/gpumatrixmult/gpumatrixmult.pdf

## RTL Is Not an ISA

The problem with Verilog for computational FPGAs is that it neither does a good job as a low-level hardware abstraction nor as a high-level programming abstraction.
By way of contradiction, let’s imagine what it would look like if RTL were playing each of these roles well.

**Role 1:** *Verilog is an ergonomic high-level programming model that targets a lower-level abstraction.*
In this thought experiment, the ISA for computational FPGAs is something at a lower level of abstraction than an RTL: netlists or bitstreams, for example.
Verilog is the more productive, high-level programming model that we expose to humans.

Even RTL experts probably don’t believe that Verilog is a productive way to do mainstream FPGA development that will propel programmable logic into the mainstream.
RTL design may seem friendly and familiar to veteran hardware hackers, but the productivity gap with software languages is unfathomable.

**Role 2:** *Verilog is a low-level abstraction for FPGA hardware resources.* That is, Verilog is to an FPGA as an ISA is to a CPU. It may not be convenient to program in, but it’s a good target for compilers from higher-level languages because it directly describes what goes on in the hardware.
And it’s the programming language of last resort for when you need to eke out the last few percentage points of performance.

And indeed, Verilog is the *de facto* ISA for today’s computational FPGAs.
The major FPGA vendors’ toolchains take Verilog as input, and compilers from higher-level languages emit Verilog as their output.
[Vendors keep bitstream formats secret][secretbs], so Verilog is in practice as low in the abstraction hierarchy as you can go.

The problem with Verilog as an ISA is that it is too far removed from the hardware.
The abstraction gap between RTL and FPGA hardware is enormous: it traditionally contains at least synthesis, technology mapping, and place & route, technology mapping---each of which is a complex, slow process.
As a result, the compile/edit/run cycle for RTL programming on FPGAs takes hours or days and, worse still, it’s unpredictable:
the deep stack of toolchain stages can obscure the way that changes in RTL will affect the performance and energy.

A good ISA should directly expose unvarnished truth about the underlying hardware.
Like an assembly language, it need not be convenient to program in.
But also like assembly, it should be extremely fast to compile and yield predictable results.
If there’s going to be a hope of building higher-level abstractions and compilers, they’re going to need such a low-level target that’s free of surprises.
RTL is not that target.

[secretbs]: http://www.megacz.com/thoughts/bitstream.secrecy.html

## The Right Abstraction?

I don’t know what abstraction should replace RTL for computational FPGAs.
Practically, replacing Verilog may be impossible as long as the FPGA vendors keep their lower-level abstractions secret and their sub-RTL toolchains closed source.
The long-term resolution to this problem might only come when the hardware evolves, as GPUs once did:

<p class="showcase">
GPU : GPGPU :: FPGA : ____
</p>

If computational FPGAs are accelerators for a particular class of algorithmic patterns, there’s no reason to believe that today’s FPGAs are the ideal implementation of that goal.
A new category of hardware that beats FPGAs at their own game could bring with it a fresh abstraction hierarchy.
The new software stack should dispense with the legacy connection to circuit emulation and, with it, the RTL abstraction.
