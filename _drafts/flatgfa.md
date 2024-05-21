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

Now the central `Graph` struct has three `Vec` arenas that own all the segments, paths, and the steps within the paths.
Instead of a direct reference to a `Segment`, the `Handle` struct has a `u32` index into the segment arena.
And each `Path` refers to a contiguous range in the step arena with start/end indices.
In [the real thing][flatgfa-rs], even `Path::name` and `Segment::sequence` get the same treatment:
there are two *giant* strings in the `Graph` struct that act as arenas;
every `Path` and `Segment` just has a `(u32, u32)` pair to refer to its name or sequence as a chunk within a given string.

The result is that, outside of the arenas, all the types involved are fixed-size, smallish, pointer-free structs.
It might be helpful to visualize the memory layout:

<img src="{{site.base}}/media/flatgfa/memory.svg"
    class="img-responsive bonw">

The `Path::steps` field refers to a slice of the `path_steps` array, and the `Handle::segment` field in there refers to a position in the `segments` array.
There are no real, word-sized pointers anywhere.
Again, while I put the path names and the nucleotide sequences inline to make this picture simpler, [the actual implementation][flatgfa-rs] stores those in yet more arenas.
My current implementation uses 12 arenas to implement the complete GFA data model.

[flattening]: {{site.base}}/blog/flattening.html
[flatgfa-rs]: https://github.com/cucapra/pollen/blob/main/flatgfa/src/flatgfa.rs

## It's Pretty Fast, I Guess

What have we really gained by replacing all our pointers with integers?
Even though we haven't fundamentally changed the data structure, there are a few reasons why a flat representation for GFAs should be more efficient:

* Faster allocation. By sacrificing the ability to deallocate elements at a fine granularity, we can use simple bump allocation instead of a proper `malloc` when building the data structure.
* Locality. We're forcing logically contiguous elements, such as each path's steps, to be contiguous in memory. That's probably good for spatial locality.
* Smaller pointers. Replacing `&Segment` with `u32` comes with a 2&times; space savings on 64-bit machines. In a data structure with so many internal references, that probably counts for something.

Here's a brutally unfair way to measure the bottom-line performance impact of these effects.
We can compare our new, flattened implementation---called [FlatGFA][] and implemented in Rust---against our simple-as-possible [Python library][mygfa] [from last time][mygfa-post].
For more context, we can also compare against [odgi][], a C++ toolkit for GFA processing that *also* uses an efficient, index-based representation internally.

For this experiment, we'll just compare the time to *round-trip* a GFA file through the internal representation:
we'll make each tool parse and then immediately pretty-print the GFA to `/dev/null`.[^norm]
I measured the round-trip performance on three tiny graphs and three medium-sized ones from the [Human Pangenome Reference TK][hprc] and [TK][1000gont].[^sys]

[^norm]: FlatGFA is the only one of the three tools that actually preserves GFA files, byte for byte, when round-tripping them. Both odgi and mygfa (quite sensibly) normalize the ordering of elements in the graph. I made FlatGFA preserve the contents exactly to make it easier to test.
[^sys]: All wall-clock times collected on our lab server, which has two Xeon Gold 6230 processors (20 cores per socket @ 2.1 GHz) and 512 GB RAM. It runs Ubuntu 22.04. Error bars show standard deviations over at least 3 (and usually more like 10) runs, measured with [Hyperfine][].

<div class="figrow">
<figure style="width: 55%">
<img src="{{site.base}}/media/flatgfa/roundtrip-mini.svg" class="bonw"
    alt="TK">
<figcaption>Time to round-trip (parse and pretty-print) some tiny GFA files (288&nbsp;kB, 1.0&nbsp;MB, and 1.5&nbsp;MB, from left to right). Our pure-Python <a href="TK">slow_odgi</a> library is about 2&times; slower than odgi.</figcaption>
</figure>
<figure style="max-width: 40%">
<img src="{{site.base}}/media/flatgfa/roundtrip-med.svg" class="bonw"
    alt="TK">
<figcaption>Round-tripping some bigger GFAs (7.2&nbsp;GB, 2.3&nbsp;GB, and 2.7&nbsp;GB). The pure-Python library is not a contender. FlatGFA is 11.3&times; faster than odgi on average (harmonic mean).</figcaption>
</figure>
</div>

FlatGFA can round-trip small GFA files about 14&times; faster than [slow-odgi][].
That speedup conflates the three fundamental advantages above with mundane implementation differences (FlatGFA is in Rust; slow-odgi is in Python).
I would love to do more measurement work here to disentangle these effects:
for example, we could check how much the pointer size matters by seeing how much slower FlatGFA gets if we use `u64`s everywhere instead of `u32`s.

FlatGFA is also 11.3&times; faster than [odgi][] on average.[^fastest]
It can process the largest graph (7.2&nbsp;GB of uncompressed GFA text) in 67 seconds, versus 14 minutes for odgi.
I don't really know why, because odgi also (sensibly) uses a mostly flattened representation.
My best guess is that odgi's implementers focused their efforts on actually novel, actually smart data structure ideas with asymptotic benefits (e.g., they use a special index to quickly locate steps within a path) and not on boring data-representation engineering that only brings constant factors.
FlatGFA only does boring, but it goes all the way: it exterminates *all* the pointers.
And the constant-factor payoff from this basic flattening transformation can be surprisingly large.

[^fastest]: I think this means FlatGFA currently has the fastest GFA parser in the universe. This is not all that impressive; it's an extremely easy-to-parse grammar. Even so, I would love to be proven wrong.

Possible lessons here include:

* "Merely" flattening an otherwise naïve data structure can turn it into a competitive one.
* So it can be helpful to get that in place even before seeking asymptotic gains through indexing and the like.

[hyperfine]: https://github.com/sharkdp/hyperfine
[flatgfa]: https://github.com/cucapra/pollen/tree/main/flatgfa

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
