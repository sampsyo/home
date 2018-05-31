---
title: Maybe an Open Problem on Error-Robust Coding for Approximate Multi-Level Memory Cells
mathjax: true
---
In a different era, I worked on a project about [approximate storage][approxstorage].
One of the ideas was to abuse [multi-level cells (MLCs)][mlc], which are where you pack more than one bit into a single physical memory element.
Because memory cells are inherently analog, MLC designs amount to a choice of how to quantize the underlying signal to a digital value.
Packing in the analog levels more tightly gives you more bits per cell in exchange for slower reads and writes---or more error.

<figure style="max-width: 400px;">
<img src="{{site.base}}/media/approxstorage/mlc-precise.svg"
  alt="guard bands in a precise multi-level cell">
<figcaption>A precise multi-level cell sizes its guard bands so the value distributions for each level overlap minimally.</figcaption>
<img src="{{site.base}}/media/approxstorage/mlc-approx.svg"
  alt="guard bands in a precise multi-level cell">
<figcaption>An approximate multi-level cell allows non-negligible error by letting the distributions overlap.</figcaption>
</figure>

Our idea was to pack more levels into a cell, beyond what would be allowed in a traditional, precise memory.
Without adjusting the timing to compensate, we exposed the resulting errors to the rest of the system.
Approximate computing!

The nice thing about these approximate memories is that analog storage errors are more often small than large.
In a four-level (two-bit) cell, for example, when you write a 0 into the cell, you are more likely to read a 1 back later than a 3.
Put differently, error probabilities are monotonic in the value distance.
If $w$ is the value you originally wrote and $r$ is a possibly-faulty error you read back, if $|w - r_1| \ge |w - r_2|$ then the probability of reading $r_1$ is at most the probability of reading $r_2$.
Applications like small errors more than large errors, so MLC errors are a good fit.

[approxstorage]: https://dl.acm.org/citation.cfm?id=2644808
[mlc]: https://en.wikipedia.org/wiki/Multi-level_cell
