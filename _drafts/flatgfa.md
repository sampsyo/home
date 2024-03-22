---
title: "A Post About FlatGFA"
---
Lately, we've been collaborating with some hip biologists who do something called [pangenomics][], which is like regular genomics but cooler. In regular genomics, you sequence each organism's genome by aligning it to a *reference genome* that somebody previously assembled [at great cost][denovo]. In a sense, the traditional view models all of us as variations of [an ideal *Homo sapiens*][human-reference]. Pangenomicists instead try to directly model the variation among an entire population of different organisms. This all-to-all comparison, they tell us, is the key to understanding a population's diversity and revealing subtleties that are undetectable with the traditional approach.

Anyway, the pangenome folks have a file format:
[Graphical Fragment Assembly (GFA)][gfa].
GFA is a text format, and it looks like this:

```
S	1	CAAATAAG
S	2	AAATTTTCTGGAGTTCTAT
S	3	TTG
S	4	CCAACTCTCTG
P	x	1+,2+,4-	*
P	y	1+,2+,3+,4-	*
L	1	+	2	+	0M
L	2	+	4	-	0M
L	2	+	3	+	0M
L	3	+	4	-	0M
```

A [pangenome variation graph][vg] encompasses the genomes of multiple individuals, and it models what they all have in common and how they differ.
The graph's vertices are little snippets of DNA sequences, and each individual is a walk through these vertices:
if you concatenate all the little DNA sequences along a given walk, you get the full genome sequence for the individual.

Each line in the GFA file above declares some part of this variation graph.
The `S` lines are *segments* (vertices);
`P` is for *path* (which are those per-individual walks);
`L` is for *link* (an edge: just a pair of segments where paths are allowed to traverse).
Our graph as 4 segments and 2 paths through those segments, named `x` and `y`.
Here's a picture, drawn by [the vg tool][vg] made by some of our collaborators:

<img src="{{site.base}}/media/flatgfa/tiny.png" class="img-responsive">

Hilariously, vg picked the 🎷 and 🕌 emojis to represent the two paths, `x` and `y`.
(And [GraphViz][] has made something of a mess of things, which isn't unusual.)
You can see the 🎷 path going through segments 1, 2, and 4;
the 🕌 path also takes a detour through segment 3, which is the nucleotide sequence TTG.

[denovo]: https://en.wikipedia.org/wiki/De_novo_sequence_assemblers
[pangenomics]: https://en.wikipedia.org/wiki/Pan-genome
[human-reference]: https://en.wikipedia.org/wiki/Reference_genome#Human_reference_genome
[vg]: https://github.com/vgteam/vg
[graphviz]: https://graphviz.org
[gfa]: https://github.com/GFA-spec/GFA-spec
