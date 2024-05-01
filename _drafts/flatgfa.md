---
title: "A Blog Post Actually About FlatGFA"
---
In the long term, we want to build hardware to accelerate the analysis of [pangenomes][].
In the shorter term, I wanted to understand the fundamental performance bottlenecks in processing [GFA files][], independent of hardware or software implementation.
For either, it seems clear that an efficient data representation is the table stakes for any kind of fast processing.
[Odgi][], for example, credits its performance to a collection of fancy data-representation tricks, including TKTKTKTK.
The exact requirements for fast software and fast hardware might be different, so it seems critical to understand the space of different techniques for efficiently representing GFAs.

To understand the basics here, I implemented my own efficient data representation for GFA files.
The idea was to start as simple as possible:
instead of trying every trick we can think of at once, let's start with *one* organizing principle for efficient data representation and see where that gets us as a baseline.
From there, we can try other tricks one at a time and measure their impact on efficiency.

TK something about about flattening.
