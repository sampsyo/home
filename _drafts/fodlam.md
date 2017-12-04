---
title: A Poorly Named Tool for Estimating the Performance and Power of Deep Learning Accelerators
---
My group is working on a project that collides with research on hardware accelerators for deep neural networks. We're not building a new accelerator ourselves, but we need to know roughly how one behaves.

Despite this area's face-melting hotness, it has not generated many reusable research tools. MIT's [EEMS group][eems] has a web-based [energy estimation tool][eemstool], but it's closed source and supports a limited range of layer types. Nvidia recently released the Verilog source for [an accelerator they call NVDLA][nvdla], but a complete HDL implementation is not the most reusable substrate for research. We emailed a handful of groups, but no one wants to share their tools.

[nvdla]: http://nvdla.org
[eemstool]: https://energyestimation.mit.edu
[eems]: http://www.rle.mit.edu/eems/

Imagine that an architect designing a new branch predictor needed to implement or model an entire CPU to get performance results. That's where we are with neural network accelerators. I don't know whether deep learning ASICs will become as commonplace as CPUs or GPUs, but some reasonable people certainly claim that they will. If that's the case, we need reusable, standardized, open-source research tools to make any progress.

It's certainly more important for tools to be open and reusable than it is for them to be perfect. So we're releasing our miniscule, simplistic power and performance model as open source. The [First-Order Deep Learning Accelerator Model (FODLAM)][fodlam] aggregates published numbers from two recent papers and extrapolates per-layer latency and energy consumption for CNN execution. You feed in a configuration file describing your neural network and it dumps out JSON containing joules and seconds. It's nothing fancy, but we hope it will save other groups from reinventing the same estimation strategy.

[fodlam]: https://github.com/cucapra/fodlam
