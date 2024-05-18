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
instead of trying every data-representation trick in the book, let's start with *one* organizing principle for efficient data representation and see where that gets us as a baseline.
From there, we can try other tricks one at a time and measure their impact on efficiency.

TK preview earlier that we will simultaneously be doing an in-memory representation and an on-disk file format? that's sort of the big takeaway.

The central principle we'll explore is [flattening][], a.k.a. arena allocation, a.k.a. just cramming everything into arrays and using indices instead of pointers.
The easiest way to explain the flattened data structure is to start with a standard, pointer-based version and see how it transforms to become flat.

Here's part of the example GFA graph I used [in the last post][mygfa-post]:


Recall the `P` line (a *path*) represents a walk through the vertices declared in the `S` lines (the *segments*).
Each step in the path traverses a segment in a given direction (its *orientation*), denoted with `+` or `-`.
So our `x` path has three steps:

A straightforward pointer-based data structure for representing these paths---like the one in [mygfa][]---looks something like this, in glorious "fake UML":

TK something about about flattening.

---

TK starting over

---

Let's return to that pangenome data structure [from last time][mygfa-post]. Here's a simplified part of the data model, in fake Rust:

<img src="{{site.base}}/media/flatgfa/pointery.svg" class="img-responsive">

A `Graph` owns sequences of `Segment`s and `Path`s, and the latter contains a sequence of *steps*.
Each step is a `Handle` that encapsulates a traversal of a `Segment` in either the forward to the backward direction.
In the [GFA][] text format, here are three `Segment`s and one `Path`:

    S	1	CAAATAAG
    S	2	AAATTTTCTGGAGTTCTAT
    S	4	CCAACTCTCTG
    P	x	1+,2+,4-	*

That `P` line is a path with three steps:
it traverses segment 1 and 2 in the forward (`+`) direction and then segment 4 in the backward (`-`) direction.
It looks like this:

<img src="{{site.base}}/media/flatgfa/xpath.svg" class="img-responsive">

This data structure seems pretty pointery.
[Last time][], I showed off a straightforward [Python library][mygfa] we made that embraces that pointeriness.
It's slow but clear.
This post is about implementing an efficient representation.

## Flattening the Data Structures

Other efficient representations for GFA-like data exist.
