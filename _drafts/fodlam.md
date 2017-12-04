---
title: FODLAM, a Poorly Named Tool for Estimating the Power and Performance of Deep Learning Accelerators
---
My group is working on a project that intersects with research on hardware accelerators for deep neural networks. We're not building a new accelerator ourselves, but we need to know roughly how one behaves.

Despite this area's face-melting hotness, it has not generated many reusable research tools. MIT's [EEMS group][eems] has a web-based [energy estimation tool][eemstool], but it's closed source and supports a limited range of layer types. Nvidia recently released the Verilog source for [their accelerator, NVDLA][nvdla], but its simulator [isn't available yet][nvdla-cmod] and a complete HDL implementation is not the most reusable substrate for research. We emailed a handful of groups, but no one was interested in open-sourcing anything.

[nvdla-cmod]: https://github.com/nvdla/hw/blob/7c769aa9a62f209a0487bd383eb046bebdf676b6/cmod/README.md
[nvdla]: http://nvdla.org
[eemstool]: https://energyestimation.mit.edu
[eems]: http://www.rle.mit.edu/eems/

Imagine working on a new branch predictor and needing to implement or model an entire CPU to get performance results. That's where we are with neural network accelerators. I don't know whether deep learning ASICs will become as commonplace as CPUs or GPUs, but reasonable people claim that they will. If that's the case, we need reusable, standardized, open-source research tools to make any progress.

It's more important for tools to be open and reusable than it is for them to be perfect. So we're releasing our miniscule, simplistic power and performance model on GitHub. The [First-Order Deep Learning Accelerator Model (FODLAM)][fodlam] aggregates published numbers from two recent papers and extrapolates per-layer latency and energy consumption for CNN execution. You feed in a configuration file describing your neural network and FODLAM dumps out JSON containing joules and seconds.

FODLAM is nothing fancy, but we hope it will save other groups from reinventing the same estimation strategy. If you use it, please publish any extensions so others can benefit.

[fodlam]: https://github.com/cucapra/fodlam
