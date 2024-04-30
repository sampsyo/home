---
title: "A Blog Post Actually About FlatGFA"
---
In the long term, we want to build hardware to accelerate the analysis of [pangenomes][].
In the shorter term, I wanted to understand the fundamental performance bottlenecks in processing [GFA files][], independent of hardware or software implementation.
For either, it seems clear that an efficient data representation is the table stakes for any kind of fast processing.
[Odgi][], for example, credits its performance to a collection of fancy data-representation tricks, including TKTKTKTK.

To understand the basics here, I tried implementing my own efficient data representation for GFA files.
The idea was to stay as simple as possible: instead of trying *all* the many tricks from odgi at once, to start with *one* principled technique as a baseline.
From there,
