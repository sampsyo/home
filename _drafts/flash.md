title: A Fake Shell for Pangenomics
excerpt: |
    TK
---
For a while now, I have been working on [a fast toolkit for pangenomics, called FlatGFA][flatgfa-post].
Relative to other pangenomics tools like [odgi][], FlatGFA has one trick:
a zero-copy data format.
The in-memory data format is identical to the on-disk format, so FlatGFA can skip all serialization and deserialization costs;
opening a file consists of an [mmap(2)][mmap].
For unfairly cherry-picked workloads, FlatGFA can be thousands of times faster than odgi.

Now comes the hard part:
I want my genomicist colleagues to actually use FlatGFA.
I want to write an inventory of high-performance operations and let the _real_ scientists compose them into complete workflows.

To let them do that kind of composition, there were two clear options:
we could either
(1) make a command-line interface that exposes all the operators and let the scientists write shell scripts to compose them, or
(2) design a Rust API and have the scientists write Rust code.
Neither option is all that compelling:

1. The CLI approach really limits the kind of composition you can do.
   All intermediates need to be either files or pipes,
   which can get awkward and surely comes with some overhead.
2. Our internal Rust API is, because of all the data-structure tricks we play, written an endearingly idiosyncratic style.
   Even though our biologist collaborators are already Rust hackers, I can't in good conscience say that we have a _good_ API that they'd be happy to use.

This post is about the very silly alternative that we recently built:
a "fake shell" that _pretends_ to be like option 1 but approximates the performance of option 2.

[flatgfa-post]: {{site.base}}/blog/flatgfa.html
[odgi]: https://odgi.readthedocs.io/en/latest/
[mmap]: https://linux.die.net/man/2/mmap


On Ousterhout Dichotomies
-------------------------

For a long time, I thought that the right way to "package" a performance-oriented library like FlatGFA might be with an [Ousterhout dichotomy][od].
The performance-sensitive, bulk routines stay in Rust, but we build bindings to a higher-level language for composing those routines into whole workflows.
The result would look a lot like [PyTorch][]: it doesn't matter to ML engineers that Python isn't very fast because more than 99% of the time is spent in optimized kernel routines written in C++ and CUDA.

Python is the natural choice for the "glue language" part of an Ousterhout dichotomy in the modern era.
(Sorry, [Tcl][].)
So we started building Python bindings for FlatGFA using the excellent [PyO3][] project, which eliminates a lot of binding boilerplate.
We got [the basics][flatgfa-py-docs] working reasonably well---for example, try this to see it in action:

```sh
$ curl -LO https://raw.githubusercontent.com/pangenome/odgi/refs/heads/master/test/LPA.gfa
$ uv run --with flatgfa python
>>> import flatgfa
>>> graph = flatgfa.parse("LPA.gfa")
>>> [path.name for path in graph.paths]
```

To my surprise, however, Python bindings had a few serious downsides:

* Even with PyO3, the bindings are hard to write efficiently. The problem is the fundamental complexity of the mismatch between Rust's static lifetimes and Python's dynamically managed heap. FlatGFA's performance advantages come from eliminating copies, allocations, and pointer-chasing---all things that want to creep back in at the Rust/Python boundary.
* We don't get a whole-program view of the workload. Straightforward Python bindings mean that our only opportunity to go fast is _within each call to the library_, and we can't do much across multiple calls. For example, the moment that the user writes a Python `for` loop, we almost certainly lose the performance game. This is the same underlying reason that PyTorch has [a separate, optional "compile" mode][torch.compile], for example.
* It turns out that our biologist collaborators aren't exactly enamored with Python anyway! The traditional, familiar way to compose pangenomic pipelines is via the Unix shell. It sometimes seems like the word "Python" is a synonym for "a programming language that the people actually want to use absent other constraints," but of course it's more contextual than that.

It eventually made sense to reconsider the CLI-oriented approach that [odgi][] and friends all use.

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

This workflow uses four operators from the two packages, two Unix pipes, and one intermediate file.
I don't think it matters much in this example, but it's nice that the shell pipelines let the two pairs of commands run in parallel.

There is, however, one gigantic downside:
the only ways to exchange data between operations are files and pipes.
Using files to communicate might mean writing stuff to the disk unnecessarily, even when all the bytes fit comfortably in memory.
Pipes can avoid disk I/O and can be a great fit for streaming operators,
but they generally entail serializing everything to text,
and not every producer--consumer relationship naturally supports streaming.
For example, if one command generates a new variation graph, the next command probably needs to read the whole thing before it can start its work.

In our weekly meeting for a [grant about pangenomics][panorama], the group got into a slightly heated discussion about these fundamental limits of shell-based composition.
Maybe the OS's disk cache can mostly mitigate the file I/O cost?
Could you force it by putting the files in a RAM disk?
(What even happens when you `mmap` a file that's on a RAM disk?)
Maybe none of that is practical anyway when datasets grow large enough to overflow main memory?

In that discussion, I realized that there was a ridiculous, impractical, but very fun alternative that could sidestep all those potential downsides.

[odgi-tut]: https://odgi.readthedocs.io/en/latest/rst/tutorials/detect_complex_regions.html#obtain-the-depth-over-the-pangenome
[bedtools]: https://bedtools.readthedocs.io/en/latest/
[panorama]: https://news.cornell.edu/stories/2021/11/5m-grant-will-tackle-pangenomics-computing-challenge


On Vectorized Interpreters
--------------------------

In 2023, Graydon Hoare gave [a talk at UCSC about "vectorized interpreters"][vecint] that made a big impression on me.[^graydon]
He makes the point native-code compilers (especially JITs) are an extremely complicated way to extract performance from code.
The idea that stuck with me was that, with suitable cooperation from the programming model, interpreters that operate *in bulk* can be a simple and fast alternative.
If every instruction in your bytecode represents a big computation on a lot of data (instead of, say, a single scalar integer addition),
then straightforwardly interpreting that bytecode is plenty efficient.
There's no need to worry about the cost of bytecode instruction dispatch, for example, when 99.99% of the time goes to running the implementation of those chunky instructions.

TK so the idea: a fake shell!

[^graydon]: If you're reading this, Graydon, sorry that I'm probably about to oversimplify your point here.

[vecint]: https://venge.net/graydon/talks/VectorizedInterpretersTalk-2023-05-12.pdf


Design
------

reuse a [shell syntax parser][brush-parser] from [a "rewrite it in rust" shell project][brush] (thanks!)

"pass-through" for running real commands

IR, interpreter. sets up pipes, opens files.

[brush]: https://crates.io/crates/brush
[brush-parser]: https://crates.io/crates/brush-parser


Optimizations
-------------

the point is to get to do optimizations on the IR. things that would be real weird otherwise.


