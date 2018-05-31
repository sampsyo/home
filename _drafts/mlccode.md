---
title: Maybe an Open Problem on Error-Robust Coding for Approximate Multi-Level Memory Cells
mathjax: true
---
In a different era, I worked on a project about [approximate storage][approxstorage].
This post is about a problem we never solved during that project---a problem that haunts me to this day.

One of our ideas was to abuse [multi-level cells (MLCs)][mlc], which are where you pack more than one bit into a single physical memory element.
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
Applications like small errors more than they like large errors, so MLC errors are a good fit.

The problem, however, is that real programs don't use many two-bit numbers.
It's not feasible to cram 65,536 levels into a single cell in most technologies, but we'd really like to be able to use 16-bit numbers.
It's easy to combine, say, two two-bit cells to represent a four-bit number under ordinary circumstances: just split up the bits or use a [Gray code][] to minimize the expected cost of small changes.
But these strategies ruin our nice error monotonicity property:
small changes in one cell might cause large changes in our four-bit number.

Let's consider a few options for how we might encode a four-bit number onto two two-bit cells.
We'll define an encoding function $e$ and a decoding function $d$ for each:

* In a *chunking code*, the high two bits go to the first cell and the lower bits go to the second cell.
  In binary, then, the number $0110$ is represented as the pair $\langle 01, 10 \rangle$.
  In other words, our encoding function has $e(0110) = \langle 01, 10 \rangle$.
  But a small, one-level error in the first cell causes a large error in the represented value.
  A one-level error makes us read $00$ from the first cell instead of the correct value, $01$.
  And $d(\langle 00, 10 \rangle) = 0010$.
  The value-space error is $|0110 - 0010|$, or a value of 4.
  In fact, an error of 4 (arising from the first cell) is just as likely as an error of 1 (arising from the second cell).

[approxstorage]: https://dl.acm.org/citation.cfm?id=2644808
[mlc]: https://en.wikipedia.org/wiki/Multi-level_cell
[gray code]: https://en.wikipedia.org/wiki/Gray_code
