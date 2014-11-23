---
title: An FPGA is an Impoverished Accelerator
kind: article
excerpt: |
    Architects tend to confuse FPGAs with ASIC acceleration. This is a mistake: when viewed as an acceleration substrate, FPGAs are a unfortunate accident of history with an exceptionally bad programming model. We should pay more attention to better alternatives.
---
Architects are prone to describing [field-programmable gate arrays][fpga], or FGPAs, as a "light" version of hardware acceleration. While researchers have exploited FPGAs to great computational effect, [especially][catapult] [recently][xxx], it is critical to remember that FPGAs are what we *have,* not what we *want.*

It is a misperception that FPGAs are a great way to bridge the gap between software flexibility and hardware efficiency. FPGAs are legacy baggage in the same way that [GPGPUs][gpgpu] are. Both have found [incredible][xxx gpu thing] [success][linqits] as alternative computation models, but neither is what we would have designed if we were starting from scratch.

FPGAs were designed for prototyping [ASIC][]s and they do that well. But prototyping an ASIC is not tantamount to harnessing an ASIC's acceleration benefits. A circuit design for an ASIC accelerator needs significant---sometimes fundamental---changes to become a good FPGA design. An FPGA design worth its salt needs to exploit FPGA-specific resources, like hard arithmetic logic, and respect a specific FPGA part's parameters.

It's no shock, then, that people who work on FPGAs for computation end up concocting ways to [extend them to make them better for the task][chung].

As accelerators, FPGAs are hampered by an unintelligible programming interface that is a consequence of vendor lock-in. This lock-in is due to the lack of abstraction that FPGAs present. To paper over the interface's complexity, the two [major][xilinx] [vendors][altera] sell proprietary software stacks that are infeasible to replace. No one seems happy with these tools, but the duopoly means we're stuck with them. Even more modern languages such as [Chisel][] and [Bluespec][] have to emit compatible [HDLs][hdl] on the backend and inherit the proprietary toolchains' warts.

If the goal is accelerating applications, and it should be, then FPGAs are just data-flow accelerators with a terrible programming model. (Architects with EE backgrounds may be forgiven for thinking an HDL is a reasonable abstraction, but it's not.) The community should work on ways to unlock the same fundamental efficiencies that FPGAs offer---spatial logic, fine-grained parallelism, explicit data movement, and bit-level flexibility---with an architecture designed from first principles. We should not be satisfied with abusing a legacy concept for acceleration; we should have the chutzpah to *design an accelerator.*
