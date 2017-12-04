---
title: A Poorly Named Tool for Estimating the Performance and Power of Deep Learning Accelerators
---
My group is working on a project that collides with research on hardware accelerators for deep neural networks. We're not building a new accelerator ourselves, but we need to know roughly how one behaves.

Despite this area's face-melting hotness, it has not generated many reusable research tools. MIT's [EEMS group][emms] has a web-based [energy estimation tool][eemstool], but it's closed source and supports a limited range of layer types. Nvidia recently released the Verilog source for [an accelerator they call NVDLA][nvdla], but a complete HDL implementation is not the most reusable substrate for research. We emailed a handful of groups, but no one wants to share their tools.

[nvdla]: http://nvdla.org
[eemstool]: https://energyestimation.mit.edu
[emms]: http://www.rle.mit.edu/eems/

Imagine that an architect designing a new branch predictor needed to implement or model an entire CPU to get performance results. That's where we are with neural network accelerators. I don't know whether deep learning ASICs will become as commonplace as CPUs or GPUs, but some reasonable people certainly claim that they will. If that's the case, we need reusable, standardized, open-source research tools to make any progress.

TK if CNN accelerators are going to be as commonplace, we need common infrastructrure. a baseline of agreement.
TK importance of standardization, even on imperfect tools.
