---
title: A Fake Shell for Pangenomics
excerpt: |
    TK
---
I have been working on [an efficient toolkit for pangenomics, called FlatGFA][flatgfa-post].
Relative to other pangenomics tools like [odgi][], FlatGFA has essentially one trick:
a zero-copy data format.
The in-memory data format is identical to the on-disk format, so FlatGFA can skip all serialization and deserialization costs;
opening a file consists of an [mmap(2)][mmap].
For [unfairly cherry-picked workloads][flatgfa-eval], FlatGFA can be thousands of times faster than odgi.

Now comes the hard part:
I want my genomicist colleagues to actually use FlatGFA.
I want to write an inventory of high-performance operations and let the _real_ scientists compose them into complete workflows.

To let them do that kind of composition, there were two simple options:
we could either
(1) make a command-line interface that exposes all the operators and let the scientists write shell scripts to compose them, or
(2) design a Rust API and have the scientists write Rust code.
Neither option is very compelling:

1. The CLI approach really limits the kind of composition you can do.
   All intermediates need to be either files or pipes,
   which can get awkward and surely comes with some overhead.
2. Our internal Rust API is, because of all the data-structure tricks we play, written an endearingly idiosyncratic style.
   Even though our biologist collaborators are great Rust hackers, I can't in good conscience say that we have a _good_ API that they'd be happy to use.

This post is about the very silly alternative that we recently built:
a _fake shell_ that pretends to offer option 1 but approximates the performance of option 2.

[flatgfa-post]: {{site.base}}/blog/flatgfa.html
[flatgfa-eval]: {{site.base}}/blog/flatgfa.html#speedup
[odgi]: https://odgi.readthedocs.io/en/latest/
[mmap]: https://linux.die.net/man/2/mmap


On Ousterhout Dichotomies
-------------------------

For a long time, I thought that the right way to "package" a performance-oriented library like FlatGFA might be with an [Ousterhout dichotomy][od].
The performance-sensitive, bulk routines stay in Rust, but we build bindings to a higher-level language for composing those routines into whole workflows.
The result would look a lot like [PyTorch][]: it doesn't matter to ML engineers that Python isn't very fast because more than 99% of the time is spent in optimized kernel routines written in C++ and CUDA.

Python is the natural choice for the "glue language" part of an Ousterhout dichotomy in the modern era.[^tcl]
So we started building Python bindings for FlatGFA using the excellent [PyO3][] project.
We got [the basics][flatgfa-py-docs] working reasonably well---for example, try this to see it in action:

```sh
$ curl -LO https://raw.githubusercontent.com/pangenome/odgi/refs/heads/master/test/LPA.gfa
$ uv run --with flatgfa python
>>> import flatgfa
>>> graph = flatgfa.parse("LPA.gfa")
>>> [path.name for path in graph.paths]
```

To my surprise, however, Python bindings had a few serious downsides:

* Even with PyO3, the bindings are hard to write efficiently. The problem is the fundamental complexity in the mismatch between Rust's static lifetimes and Python's dynamically managed heap. FlatGFA's performance advantages come from eliminating copies, allocations, and pointer-chasing---all things that want to creep back in at the Rust/Python boundary.
* We don't get a whole-program view of the workload. Straightforward Python bindings mean that our only opportunity to go fast is _within each call to the library_, and we can't do much across multiple calls. For example, the moment that the user writes a Python `for` loop that iterates over a FlatGFA data structure, we almost certainly lose the performance game. This is the same underlying reason that PyTorch has [a separate, optional compiled mode][torch.compile], for example.
* It turns out that our biologist collaborators aren't exactly enamored with Python anyway! The traditional, familiar way to compose pangenomic pipelines is via the Unix shell. Personally, I have become too accustomed to Python being the default choice for approachability. Naturally, preferences among domain experts are contextual and varied.

It made sense to reconsider the CLI-oriented approach that [odgi][] and friends all use.

[^tcl]: Sorry, [Tcl][].

[od]: https://web.stanford.edu/~ouster/cgi-bin/papers/scripting.pdf
[pyo3]: https://pyo3.rs/
[flatgfa-py-docs]: https://cucapra.github.io/pollen/flatgfa/
[torch.compile]: https://docs.pytorch.org/docs/2.12/user_guide/torch_compiler/torch.compiler.html#torch-compiler-overview
[pytorch]: https://pytorch.org
[tcl]: https://www.tcl-lang.org


Reconsidering the Shell
-----------------------

It might seem odd to prefer shell scripting over a full-featured dynamic scripting language, but
shell scripts really do have some material advantages over Python:

* Streaming I/O via pipes can be great for large datasets, in the right situation.
* Simple pipeline parallelism is easy to express.
* It's straightforward to persist intermediate results in files.
* The shell is kinda the _ultimate_ glue language:
  you can compose components developed separately, written in different languages, with no special effort on bindings.
  (The only "bindings" are the Unix userland APIs.)

You can see evidence of this kind of composition in [the odgi documentation][odgi].
For example, [one tutorial][odgi-tut] suggests that we find repetitive sequences in human chromosome 8 by composing operators from odgi itself and [bedtools][]:

```sh
odgi depth -i chr8.pan.og -r chm13#chr8 | \
    bedtools makewindows -b /dev/stdin -w 5000 > chm13.chr8.w5kbps.bed

odgi depth -i chr8.pan.og -b chm13.chr8.w5kbps.bed --threads 2 | \
    bedtools sort > chr8.pan.depth.w5kbps.bed
```

This workflow uses four operators from two different packages, two Unix pipes, and one intermediate file.
I don't think it matters much in this example, but it's nice that the shell pipelines let the two pairs of commands run concurrently.

There is, however, one gigantic downside:
the only ways to exchange data between operations are files and pipes.
Files can entail writing stuff to the disk unnecessarily, even when all the bytes fit comfortably in memory.
Pipes can avoid disk I/O and can be a great fit for streaming operators,
but they generally entail serializing everything to text,
and not every producer--consumer relationship naturally supports streaming.
For example, if one command generates a new variation graph (a new GFA file), the next command probably needs to read the whole thing before it can start its work.

In our weekly meeting for a [grant about pangenomics][panorama], the group got into a slightly heated discussion about these fundamental limits of shell-based composition.
Maybe the OS's disk cache can mostly mitigate the file I/O cost?
Could you force it by putting the files in a RAM disk?
(What even happens when you `mmap` a file that's on a RAM disk?)
Maybe none of that is practical anyway when datasets grow large enough to overflow main memory?

In that discussion, I realized that there was a ridiculous, impractical, but very fun alternative that could sidestep all those potential downsides.

[odgi-tut]: https://odgi.readthedocs.io/en/latest/rst/tutorials/detect_complex_regions.html#obtain-the-depth-over-the-pangenome
[bedtools]: https://bedtools.readthedocs.io/en/latest/
[panorama]: https://news.cornell.edu/stories/2021/11/5m-grant-will-tackle-pangenomics-computing-challenge


Digression: Vectorized Interpreters
-----------------------------------

In 2023, Graydon Hoare gave [a talk at UCSC about "vectorized interpreters"][vecint] that made a big impression on me.[^graydon]
He makes the point that native-code compilers (especially JITs) are an extremely complicated way to extract performance from code.
The idea that stuck with me was that, with suitable cooperation from the programming model, interpreters that operate *in bulk* can be a simple and fast alternative.
If every instruction in your bytecode represents a big computation on a lot of data (instead of, say, a single scalar integer addition),
then straightforwardly interpreting that bytecode is plenty efficient.
There's no need to worry about the cost of bytecode instruction dispatch, for example, when 99.99% of the time goes to running the implementation of those chunky instructions.

In Graydon's presentation, PyTorch and NumPy are both examples of vectorized interpreters.
But as I touched on above, they reuse Python's program representation and interpreter---so their addressable "instruction window" is limited.

I had been thinking that there must be a way to do better with a bespoke vectorized interpreter for pangenomics operations.
And the problems with shell-script workflows provided an excuse to try doing something about it.

[^graydon]: If you're reading this, Graydon, sorry that I'm probably about to oversimplify your point here.

[vecint]: https://venge.net/graydon/talks/VectorizedInterpretersTalk-2023-05-12.pdf


A Fake Shell
------------

The idea is to build a _fake shell:_
something that supports a tiny fraction of POSIX shell syntax
and "cheats" when running pangenomic operators.
The goal is to run unmodified shell scripts that use traditional CLI tools, like [odgi][] and [bedtools][], and communicate through pipes and files.
We'll make the same shell scripts go faster by opportunistically switching to faster implementations and avoiding I/O.

The shell is called Flash (the FlatGFA shell), and if you want to play along, you can find it [in our pangenomics monorepo][flash].
Use `cargo run` to get an interactive prompt.

### Shell Basics

The first thing Flash can do is run ordinary commands, just like a real shell would.
This works, for example:

```sh
echo llenroc | rev > message.txt ; cat message.txt
```

To make this work, I borrowed an existing [shell syntax parser][brush-parser] from [a "rewrite it in Rust" shell project][brush].
But instead of interpreting the shell AST directly, Flash first translates it into an instruction-based intermediate representation.
That little script above translates into three instructions, one for each command it runs.
Flash can pretty-print the IR if you give it a `--pretend` (`-p`) flag:

```
$ flash -p -c 'echo llenroc | rev > message.txt ; cat message.txt'
shell("echo", ["llenroc"], input=stdin) -> pipe-0
shell("rev", [], input=pipe-0) -> "message.txt"
shell("cat", ["message.txt"], input=stdin) -> stdout
```

So far, we're only using the `shell` instruction, which actually forks a subprocess (like a real shell would).
Flash's IR is built around *resources:* the things that can be inputs and outputs to instructions.
This program uses the `stdin` and `stdout` resources, a Unix pipe, and a file.
Flash's [IR evaluator][eval] takes care of setting up pipes and opening files on behalf of each instruction.

### Faking It

The thing that makes Flash a *fake* shell is that it special-cases a baked-in set of known pangenomic CLI tools.
Let's borrow one part of the script we saw above, for example:

```
$ flash -p -c 'odgi depth -i chr8.pan.gfa -r chm13#chr8'
parse-gfa("chr8.pan.gfa") -> gfa-store-0
path-depth(gfa-store-0, path="chm13#chr8") -> stdout
```

Flash has recognized our `odgi depth` invocation and, in place of a `shell` instruction, has generated some specialized instructions it can run _internally_.
The `path-depth` instruction works by directly calling a Rust function in the FlatGFA library, and it never forks a subprocess.

The `shell` instructions saw above used input and output _resources_.
These get names like `pipe-0` and `"message.txt"` in the IR listings above.
For `shell`, the only kinds of resources allowed are byte streams (i.e., pipes and files).
The `parse-gfa` instruction, however, produces a new type of resource:
a *GFA store*, which is an efficient representation of a pangenomic variation graph.
This is a plain Rust value stored in the Flash interpreter's environment.
When it eventually evaluates the `path-depth` instruction, the Flash interpreter retrieves the value and feeds it into the relevant library function.

TK summarize the approach

### A Complete Example

Let's see the IR representation of a more complete workflow.
I'll put this script in a file called `wdepth.sh`:

```sh
#!/bin/sh
odgi depth -i chr8.pan.gfa -r chm13#chr8 \
    | bedtools makewindows -b /dev/stdin -w 5000 > chm13.chr8.w5kbps.bed
odgi depth -i chr8.pan.gfa -b chm13.chr8.w5kbps.bed
rm -f chm13.chr8.w5kbps.bed
```

Here's the IR listing:

```
$ flash -p wdepth.sh
parse-gfa("chr8.pan.gfa") -> gfa-store-0
path-depth(gfa-store-0, path="chm13#chr8") -> pipe-0
parse-bed(pipe-0) -> bed-store-0
make-windows(bed-store-0, size=5000) -> "chm13.chr8.w5kbps.bed"
parse-gfa("chr8.pan.gfa") -> gfa-store-1
parse-bed("chm13.chr8.w5kbps.bed") -> bed-store-1
interval-depth(gfa-store-1, bed-store-1) -> stdout
shell("rm", ["-f", "chm13.chr8.w5kbps.bed"], input=stdin) -> stdout
```

The thing I like about Flash's design is that it naturally supports mixing and matching different resource types.
Some instructions interact with the external world through the filesystem or Unix pipes;
others interact with Flash's internal data structures.
Both kinds of instructions can coexist and exchange data.

This example script can run both under plain ol' `sh` and with Flash.
Let's compare the performance.
To make the comparison meaningful, we'll try two settings:
one where both routes read a plain 3.9 GB text GFA file[^chr8]
and one where both odgi and Flash get to start from their respective efficient binary file formats.

Here are some results:[^setup]

TK and in fact, this can run unmodified in a real shell. measure performance against odgi. compare:
- odgi from og
- odgi from gfa
- flash from flatgfa
- flash from gfa

[brush]: https://crates.io/crates/brush
[brush-parser]: https://crates.io/crates/brush-parser
[flash]: https://github.com/cucapra/pollen/tree/main/flatgfa-sh
[eval]: https://github.com/cucapra/pollen/blob/main/flatgfa-sh/src/eval/mod.rs
[pggb]: https://github.com/pangenome/pggb
[hyperfine]: https://github.com/sharkdp/hyperfine

[^chr8]: We're using the chromosome 8 [PGGB][] graph from [this repository of pangenomes](https://human-pangenomics.s3.amazonaws.com/index.html?prefix=pangenomes/scratch/2021_05_06_pggb/gfas/).
[^setup]: I ran these experiments on a server with dual Xeon Gold 6230 processors (2.10 GHz), 512 GB of RAM, and Ubuntu 22.04. I used [Hyperfine][] to compare end-to-end execution time, configured with 3 runs and 1 warmup per configuration (`hyperfine -w1 -r3 -N`). The warmup means that the input files are cached, so I don't think we're measuring much actual disk I/O. Odgi reports its version as `v0.6.3-9-ge1940cd`, and I used Flash from [commit 2421a7f](https://github.com/cucapra/pollen/commit/2421a7f34955ccf71ad0743785b125b4e1e6219b).

### Optimizations

This all makes for a fun [language-implementation pastime][toot], but the real reason for all this setup is to do optimizations.
Flash's instruction-based IR makes optimizations feasible (I can't imagine how I'd implement them directly on the shell AST).
Here are the optimizations I've implemented so far:

* When the program produces a BED file and then loads it again with a `parse-bed` instruction, avoid the round trip through bytes. Just produce an in-memory BED resource and use that directly.
* Recognize uses of `path-depth` that actually only need the number of base pairs, and replace them with the cheaper `path-length` instruction. (This one's cheesy: it just so happens that `odgi depth -r` is a convenient way to get path length, even though it also needlessly computes depth.)
* Find identical `map-file` instructions that load the same file twice and deduplicate them. (If I were a better man, this would be a general [CSE][].)
* The cheesiest one of all: when the program uses `parse-gfa("foo.gfa")` and a file named `foo.flatgfa` happens to exist, replace it with `map-file("foo.flatgfa")`. In other words, assuming that we've already converted the text GFA format to our efficient binary format, use that. (This ridiculous optimization mainly just helps with writing shell scripts that remain 100% compatible with a real POSIX shell.)

Here's the result of optimizing our little script above:

```
$ flash -O -p wdepth.sh
map-file("chr8.pan.flatgfa") -> mmap-0
path-length(mmap-0, path="chm13#chr8") -> bed-store-0
make-windows(bed-store-0, size=5000) -> bed-store-1
interval-depth(mmap-0, bed-store-1) -> stdout
shell("rm", ["-f", "chm13.chr8.w5kbps.bed"], input=stdin) -> stdout
```

We've cleaned up the code substantially: we use an efficient FlatGFA file directly (and we only open it once), and we skip all the pipes and intermediate files.

TK perf measurement again
- odgi from og
- flash from flatgfa
- flash-O from flatgfa

[toot]: https://discuss.systems/@adrian/116518791774005898
[opt.rs]: https://github.com/cucapra/pollen/blob/2421a7f34955ccf71ad0743785b125b4e1e6219b/flatgfa-sh/src/opt.rs
[cse]: https://en.wikipedia.org/wiki/Common_subexpression_elimination
