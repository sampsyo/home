---
title: "A Blog Post Actually About FlatGFA"
---
TK preview early on that we will simultaneously be doing an in-memory representation and an on-disk file format? that's sort of the big takeaway.

## Pangenome Recap

Let's return to that pangenome data structure [from last time][mygfa-post]. Here's a simplified part of the data model, in fake Rust:

<img src="{{site.base}}/media/flatgfa/pointery.svg"
    class="img-responsive bonw">

A `Graph` owns sequences of `Segment`s and `Path`s, and the latter contains a sequence of *steps*.
Each step is a `Handle` that encapsulates a traversal of a `Segment` in either the forward to the backward direction.
In the [GFA][] text format, here are three `Segment`s and one `Path`:

    S	1	CAAATAAG
    S	2	AAATTTTCTGGAGTTCTAT
    S	4	CCAACTCTCTG
    P	x	1+,2+,4-	*

The three `S` lines are segments, which contain short nucleotide sequences.
That `P` line is a path with three steps:
it traverses segment 1 and 2 in the forward (`+`) direction and then segment 4 in the backward (`-`) direction.
It looks like this:

<img src="{{site.base}}/media/flatgfa/xpath.svg"
    class="img-responsive bonw">

This data structure seems pretty pointery.
[Last time][mygfa-post], I showed off a straightforward [Python library][mygfa] we made that embraces that pointeriness.
It's slow but clear.

This post is about implementing an efficient representation.
Other efficient data representations exist---prominently, [odgi][], which is by some collaborators.
But they get performance by combining many different representation tricks.
I want to understand the basics here by using a single principle and see how far it gets us.

[gfa]: https://github.com/GFA-spec/GFA-spec
[mygfa-post]: {{site.base}}/blog/mygfa.html
[mygfa]: https://cucapra.github.io/pollen/mygfa/
[slow-odgi]: https://github.com/cucapra/pollen/tree/main/slow_odgi
[odgi]: https://odgi.readthedocs.io/en/latest/

## Flattening the Data Structures

The central principle we'll use is [flattening][], a.k.a. arena allocation, a.k.a. just cramming everything into arrays and using indices instead of pointers.
In the fake Rust declarations above, I used `Ref` and `List` to suggest ordinary pointer-based references to one and many elements.
In the flattened version, we'll replace all of those those with plain `u32`s:

<img src="{{site.base}}/media/flatgfa/indexy.svg"
    class="img-responsive bonw">

Now the central `Graph` class has three `Vec` arenas that own all the segments, paths, and the steps within the paths.
Instead of a direct reference to a `Segment`, the `Handle` struct has a `u32` index into the segment arena.
And each `Path` refers to a contiguous range in the step arena with start/end indices.
In [the real thing][flatgfa-rs], even `Path::name` and `Segment::sequence` get the same treatment:
there are two *giant* strings in the `Graph` struct that act as arenas;
every `Path` and `Segment` just has a `(u32, u32)` pair to refer to its name or sequence as a chunk within a given string.

The result is that, outside of the arenas, all the types involved are fixed-size, smallish, and "plain old data" without pointers to anyone else.
It might be helpful to visualize the memory layout:

<img src="{{site.base}}/media/flatgfa/memory.svg"
    class="img-responsive bonw">

TK anything to explain in that figure? I guess a takeaway is that there are no pointers anywhere.

[flattening]: {{site.base}}/blog/flattening.html
[flatgfa-rs]: https://github.com/cucapra/pollen/blob/main/flatgfa/src/flatgfa.rs

## It's Pretty Fast

TK explain why this makes things fast.
fast allocation, better locality, smaller indices (so lower memory traffic).

TK not really a fair comparison, but compare parsing time for slow-odgi and flatgfa?

## A File Format for Free

TK show off zerocopy.

## TK Something About Mmap Cutting Out Serialization

TK flamegraph for odgi. perf comparison for simple ops.

## TK Someday, Acceleration

In the long term, we want to build hardware to accelerate the analysis of [pangenomes][].
In the shorter term, I wanted to understand the fundamental performance bottlenecks in processing [GFA files][gfa], independent of hardware or software implementation.
For either, it seems clear that an efficient data representation is the table stakes for any kind of fast processing.
The exact requirements for fast software and fast hardware might be different, so it seems critical to understand the space of different techniques for efficiently representing GFAs.

[pangenomes]: https://en.wikipedia.org/wiki/Pan-genome
[gfa]: https://github.com/GFA-spec/GFA-spec
