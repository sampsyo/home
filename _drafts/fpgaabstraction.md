---
title: FPGAs Have the Wrong Abstraction
excerpt: TK
---
<aside>
These are notes from a short talk I’ll do at an "open mic" that [Doug Carmean][doug] is hosting at FCRC this weekend.
</aside>

[doug]: https://www.microsoft.com/en-us/research/people/dcarmean/

## The Computational FPGA

What is an FPGA?

I think the architecture community doesn’t have a consensus answer.
Let’s entertain three possible answers:

**Definition 1:** *An FPGA is a bunch of transistors that you can wire up to make any circuit you want.* It’s like a breadboard at nanometer scale. Having an FPGA is like taping out a chip, but you only need to buy one chip to build lots of different designs---but you take an efficiency penalty in exchange.

I don’t like this answer.
It’s neither literally true nor a solid metaphor for how people actually use FPGAs.

It’s not literally true because of course you don’t literally rewire an FPGA---it’s actually a 2D grid of lookup tables connected by a routing network, with some arithmetic units and memories thrown in for good measure.
FPGAs do a pretty good job of faking arbitrary circuits, but they really are faking it, just like any software circuit emulator.

The answer doesn’t work metaphorically either because it oversimplifies the way people actually use FPGAs.
The other two definitions will do a better job of describing the usefulness of FPGAs.

**Definition 2:** *An FPGA is a cheaper alternative to making a custom chip, for prototyping and lower-volume production.* If you’re building a router, you can avoid the immense cost of taping out a new chip for it and instead ship an off-the-shelf FPGA programmed with the functionality you need. Or if you’re designing a CPU, you can use an FPGA as a prototype: you can build a real, bootable system around it for testing and snazzy demos before you ship the design off to a fab.

This is the classic, mainstream use case for FPGAs, and it’s the reason FPGAs exist in the first place.
The point of an FPGA is to take a hardware design, in the form of HDL code, and to get cheap hardware that behaves the same as the ASIC you would eventually produce.
Of course everybody knows you’re unlikely to take *exactly* the same Verilog code and make it work both on an FPGA and on real silicon, but it’s not wrong to think of an FPGA as a circuit emulator.

**Definition 3:** *An FPGA is a pseudo-general-purpose computational accelerator.* Like a GPGPU, an FPGA is good for offloading a certain kind of computation. It’s harder to program than a CPU, for the right workload, it can be worth the effort: a good FPGA implementation can offer orders-of-magnitude performance and energy advantages over a CPU baseline on certain kernels.

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
In TK, people realized they could abuse a GPU as an accelerator for lots of computationally intensive kernels that had nothing to do with graphics: that GPU designers had built a more general kind of machine, for which graphics was just one application.

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

## RTL Is Not an ISA

TK section: RTL is not the thing
The problem is that it is neither a good programming abstraction nor a good compilation target.
It’s neither doing a good job as a low-level abstraction *or* a high-level abstraction.

Let’s do two thought experiments and consider whether Verilog does a good job of filling roles that we know of in a "normal" programming stack.

- Consider: Verilog is the high-level language that targets a low-level execution model (a netlist or a bitstream).
  - Preposterous! Verilog is *not* a good high-level abstraction for programming. It neither faithfully represents what’s going on in the hardware *nor* makes it easy to program.
  - This should be easy to swallow: writing RTL is not the way that we’re going to get FPGA acceleration to go mainstream.
  - I don’t want to sound like an HLS advocate. I’m not. But that’s a story for another talk.

- Consider: Verilog is like a CPU’s ISA. Something higher level needs to be built on it, but it’s a good common compilation target.
  - No! Verilog *cannot* be the ISA. It has so much compilation before you get to something executable. And the results are not predictable. That’s not a good ISA.
  - An ISA needs to be something that literally happens in the hardware.
  - Look no further than the compilation times to understand that the toolchain from Verilog to hardware is a big leap.

## TK wrap up: something forward looking

So what do we use instead?
I don’t know.
Part of the problem is that the FPGA vendors want Verilog to be the abstraction. Proprietary tools, etc. It’s hard to overstate how important open-source toolchain are in the software world to enabling innovation. There are fledgling OSS efforts for compiling to FPGAs, but they are far from being the "de facto" compilers as we have in the CPU world.
A couple of options:

1. Make do and work around the limitations, building higher and lower levels of abstraction that force the Verilog tools to do the right thing.
2. Revisit "GPU : GPGPU :: FPGA : ??", so new hardware that exploits the same fundamental advantages but with a new programming model.