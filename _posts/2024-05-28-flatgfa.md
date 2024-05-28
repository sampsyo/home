---
title: "One Weird Trick for Efficient Pangenomic Variation Graphs (and File Formats for Free)"
excerpt: |
    [Last time][mygfa-post], I introduced [pangenomic variation graphs][pangenomes], the standard [text file format][gfa] that biologists use for them, and a [hopelessly naïve reference data model][mygfa] we implemented for them. This time, we use a single principle---flattening--to build an efficient representation that is not only way faster than the naïve library but also competitive with an [exisitng, optimized toolkit][odgi]. Flattening also yields a memory-mapped file format "for free" that, in a shamelessly cherry-picked scenario, is more than a thousand times faster than the serialization-based alternative.

    [gfa]: https://github.com/GFA-spec/GFA-spec
    [mygfa-post]: {{site.base}}/blog/mygfa.html
    [mygfa]: https://cucapra.github.io/pollen/mygfa/
    [odgi]: https://odgi.readthedocs.io/en/latest/
---
We built an efficient binary representation for [pangenomic variation graphs][mygfa-post] that is equivalent to the standard [GFA text format][gfa].
Our approach isn't at all novel, but it illustrates a fun way that you can start with a naïve representation and transform it into a fast in-memory representation while also getting an on-disk file format for free.
In a shamelessly cherry-picked scenario, our tool is 1,331&times; faster than [an existing, optimized pangenomics toolkit][odgi] that already uses an efficient binary representation.

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
there are two *giant* byte strings in the `Graph` struct that act as arenas;
every `Path` and `Segment` just has a `(u32, u32)` pair to refer to its name or sequence as a chunk within a given string.

The result is that, outside of the arenas, all the types involved are fixed-size, smallish, pointer-free structs.
It might be helpful to visualize the memory layout:

<img src="{{site.base}}/media/flatgfa/memory.svg"
    class="img-responsive bonw">

The `Path::steps` field refers to a slice of the `path_steps` array, and the `Handle::segment` field in there refers to a position in the `segments` array.
There are no actual, word-sized pointers to the virtual address space anywhere.
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
I measured the round-trip performance on three tiny graphs and three medium-sized ones from the [Human Pangenome Reference Consortium][hprc] and the [1000 Genomes Project][1000gont].[^sys]

[^norm]: FlatGFA is the only one of the three tools that actually preserves GFA files, byte for byte, when round-tripping them. Both odgi and mygfa (quite sensibly) normalize the ordering of elements in the graph. I made FlatGFA preserve the contents exactly to make it easier to test.
[^sys]: All wall-clock times collected on our lab server, which has two Xeon Gold 6230 processors (20 cores per socket @ 2.1 GHz) and 512 GB RAM. It runs Ubuntu 22.04. Error bars show standard deviations over at least 3 (and usually more like 10) runs, measured with [Hyperfine][].

<div class="figrow">
<figure style="width: 55%">
<img src="{{site.base}}/media/flatgfa/roundtrip-mini.svg" class="bonw"
    alt="A bar chart comparing three tools' time to round-trip GFA files through their in-memory representations. This comparison uses small graphs.">
<figcaption>Time to round-trip (parse and pretty-print) some tiny GFA files (288&nbsp;kB, 1.0&nbsp;MB, and 1.5&nbsp;MB, from left to right). Our pure-Python <a href="https://github.com/cucapra/pollen/tree/main/slow_odgi">slow-odgi</a> library is about 2&times; slower than odgi.</figcaption>
</figure>
<figure style="max-width: 42%">
<img src="{{site.base}}/media/flatgfa/roundtrip-med.svg" class="bonw"
    alt="A bar chart comparing two fast tools doing the same GFA round-trip task on much larger files.">
<figcaption>Round-tripping some bigger GFAs (7.2&nbsp;GB, 2.3&nbsp;GB, and 2.7&nbsp;GB). The pure-Python library is not a contender. FlatGFA is 11.3&times; faster than odgi on average (harmonic mean).</figcaption>
</figure>
</div>

FlatGFA can round-trip small GFA files about 14&times; faster than [slow-odgi][].
That speedup conflates the three fundamental advantages above with mundane implementation differences (FlatGFA is in Rust; slow-odgi is in Python).
I would love to do more measurement work here to disentangle these effects:
for example, we could check how much the pointer size matters by using `u64`s everywhere instead of `u32`s.

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
[hprc]: https://humanpangenome.org
[1000gont]: https://github.com/AndreaGuarracino/1000G-ONT-F100-PGGB

## A File Format for Free

Because it has no pointers in it, a ruthlessly flattened in-memory representation has one bonus feature:
it does double duty as a file format.
If we take all those densely packed arrays-of-structs that make up a FlatGFA, concatenate them together, and add a little header to contain the sizes, we have a blob of bytes that we might as well write to disk.

Turning FlatGFA into a file format took two steps:
applying the amazing [zerocopy][] crate,
and separating the data store from the interface to the data.

### Use zerocopy to get `AsBytes` and `FromBytes`

First, [zerocopy][] is an immensely rad crate that can certify that it's safe to cast between Rust types and raw bytes.
It contains a bunch of macros, but these macros don't actually generate code for you: they just check that your types obey a bunch of rules.
The zerocopy authors have done the hard work (i.e., thinking carefully and using [Miri][]) to be pretty confident that all types that obey their rules can be safely transmuted to and from `[u8]` chunks.
These rules include alignment restrictions and the necessity that every bit-pattern is a valid value.
The latter rule makes `enum`s tricky: every `enum` must have 2*ⁿ* variants where *n* is the number of bits in its representation.
But once you've cleared all those hurdles, your types gain the [`AsBytes`][asbytes] and [`FromBytes`][frombytes] traits.

[asbytes]: https://docs.rs/zerocopy/latest/zerocopy/trait.AsBytes.html
[frombytes]: https://docs.rs/zerocopy/latest/zerocopy/trait.FromBytes.html

### Separate the Storage from the Interface

Now that all our structs are equipped with the zerocopy superpowers, we need a way to make *the entire data structure* map to bytes.
One nice way to do it is to separate our actual data storage location from a lightweight view of all the same data.
The idea is to start with that top-level struct that contains nothing but the `Vec`s of littler structs:

<img src="{{site.base}}/media/flatgfa/store1.svg"
    class="img-responsive bonw">

And to separate it into two structs.
We want one *store* object that keeps all those `Vec`s and one *view* object that has all the same fields but with slices instead of vectors:

<img src="{{site.base}}/media/flatgfa/store2.svg"
    class="img-responsive bonw">

Our `ThingStore` struct will never get the zerocopy superpower---`Vec`s are inherently pointerful and must live on the heap---but `ThingView` is perfectly suited.
We can construct one by calling `from_bytes` on different chunks within a big byte buffer:

<img src="{{site.base}}/media/flatgfa/store3.svg"
    class="img-responsive bonw">

We'll also need a small [table of contents][toc] at the top of the file to tell us where those chunks are.
But once we've managed that, `ThingView` serves as an abstraction layer over the two storage styles.
The `Vec`-based store provides heap-allocated, arbitrarily resizable allocation pools;
the `&[u8]` option constrains the sizes of the arenas but maps easily to a flat file.[^slicevec]

[^slicevec]: In [the real implementation][flatgfa], I also added a second storage style based on [`tinyvec::SliceVec`][slicevec] instead of plain old `Vec`. This approach splits the difference between slices and vectors: each arena has a fixed maximum capacity, but its length can be less than that. So the `SliceVec`s, even when they map to a fixed-size `&[u8]` of file contents, can still shrink and grow within limits.

[zerocopy]: https://docs.rs/zerocopy/
[slicevec]: https://docs.rs/tinyvec/latest/tinyvec/struct.SliceVec.html
[miri]: https://github.com/rust-lang/miri
[toc]: https://github.com/cucapra/pollen/blob/788aa3e48aff6a8c7b46f10c1c5fcaeee909518b/flatgfa/src/file.rs#L10-L26

## 0 Copy = ∞ Speedup

Using the same type for the in-memory and on-disk representations is not just convenient;
it also makes deserialization *infinity times faster*.[^capnproto]
To "open" a file, all we need to do is to [mmap(2)][mmap] it.
There is no deserialization step; we don't even have to read the whole file if we don't need it.

This latter aspect can lead to some pretty funny speedups for FlatGFA compared to odgi, which has its own efficient binary GFA-equivalent file format but which uses traditional serialization.
Here's a performance comparison between [the `odgi paths -L` command][odgi paths], which just prints out all the names of the paths in the graph, and the FlatGFA and slow-odgi equivalents:

<div class="figrow">
<figure style="width: 55%">
<img src="{{site.base}}/media/flatgfa/paths-mini.svg" class="bonw"
    alt="A bar chart comparing three tools' times to print out a list of path names from GFA files.">
<figcaption>Time to print the path names from the same graphs as above. The <a href="https://github.com/cucapra/pollen/tree/main/slow_odgi">slow-odgi</a> reference implementation is a hilarious 19&times; slower than odgi on average.</figcaption>
</figure>
<figure style="max-width: 40%">
<img src="{{site.base}}/media/flatgfa/paths-med.svg" class="bonw"
    alt="Another bar chart comparing the same path-name-printing task on three larger GFAs, and only comparing the two faster tools.">
<figcaption>Printing paths names from the same larger graphs. FlatGFA is 1,331&times; faster than odgi, which is not infinity, but it's pretty good.</figcaption>
</figure>
</div>

This comparison starts with the native binary formats for odgi and FlatGFA, so only slow-odgi actually has to parse any text.
Across the three big GFAs, FlatGFA is 1,331&times; faster than odgi on average.
On the largest (7.2&nbsp;GB) graph, FlatGFA takes 5.8&nbsp;ms to odgi's 12&nbsp;seconds.
If you look at [a profile of where odgi spends its time][profile], about 90% of it goes to deserialization and 9.9% goes to deallocating that data structure.
Less than 1% of the time is spent on the "real work," i.e., extracting and printing those path names.
So this is an extreme edge case where FlatGFA's deserialization- and allocation-free strategy makes for especially silly-looking bar charts.

[^capnproto]: This hyperbolic framing is stolen from [Cap'n Proto][capnproto], which honestly blew my mind the first time I understood what it was doing.

[capnproto]: https://capnproto.org
[mmap]: https://linux.die.net/man/2/mmap
[odgi paths]: https://odgi.readthedocs.io/en/latest/rst/commands/odgi_paths.html
[profile]: https://share.firefox.dev/3KiOKLW

## Someday, Acceleration

We originally fell into this rabbit hole because we want to build hardware accelerators for this stuff.
Surprising absolutely no one, data representation turns out to be the key to an efficient implementation, regardless of whether it's in hardware or software.
Outside of flattening and memory-mapping, FlatGFA is totally unoptimized---so we're now fully distracted by understanding the space of possible efficient representations and their implications for hardware design.
We'll get back to implementing that hardware someday.
I promise.

[pangenomes]: https://en.wikipedia.org/wiki/Pan-genome
[gfa]: https://github.com/GFA-spec/GFA-spec
