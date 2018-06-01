---
title: Please Help Me Solve an Open Problem on Error-Robust Coding for Approximate Multi-Level Memory Cells
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
If $v$ is the value you originally wrote and $v^\prime$ and $v^{\prime\prime}$ are possible values you might read back where $|v - v^\prime| \ge |v - v^{\prime\prime}|$, then the probability of reading $v'$ is at most the probability of reading $v^{\prime\prime}$.
Applications like small errors more than they like large errors, so MLC errors are a good fit.

The problem, however, is that real programs don't use many two-bit numbers.
It's not feasible to cram 65,536 levels into a single cell in most technologies, but we'd really like to be able to use 16-bit numbers.
It's easy to combine, say, two two-bit cells to represent a four-bit number under ordinary circumstances: just split up the bits or use a [Gray code][] to minimize the expected cost of small changes.
But these strategies ruin our nice error monotonicity property:
small changes in one cell might cause large changes in our four-bit number.

### Stating the Problem

Let's compare different strategies for encoding $n$-bit numbers onto $c$ cell values of $b$ bits each.
We'll consider codes by defining their encoding function $e$ and decoding function $d$.
Encoding turns a single $n$-bit number into a $c$-tuple of $b$-bit numbers, so we'll write $e(x) = \vec{v} = \langle v_1, v_2, \dots, v_c \rangle$ where each $v_i$ consists of $b$ bits.

We assume that, within a given cell, small errors are more likely than large errors.
We *hope* that small per-cell errors translate to small errors in the decoded value.
To make this precise, define an overloaded function $\Delta$ that gets the size of errors in either encoded or plain-text values.
For plain numbers, for example, $\Delta(1000, 0110) = 2$, or just the absolute difference between the values.
For encoded cell-value tuples, $\Delta(\langle 01, 10 \rangle, \langle 10, 01 \rangle) = 2$, which is the sum of the differences for each cell.
Here's a formal statement of the error-monotonicity property we'd like:

$$\Delta(\vec{v}, \vec{v}^\prime) \ge \Delta(\vec{v}, \vec{v}^{\prime\prime})
\Rightarrow
\Delta(d(\vec{v}), d(\vec{v}^\prime)) \ge \Delta(d(\vec{v}), d(\vec{v}^{\prime\prime}))$$

In other words, if an error is smaller in the space of encoded cell values than another error, then it *also* translates to a smaller error in the space of decoded numbers.

### The Options

Let's consider a few options.
For simplicity, I'll give examples for $n=4$, $c=2$, and $b=2$, but each strategy should generalize to any problem size where $n = c \times b$.

* I'll call the naïve strategy a *chunking code* because it just breaks the number into $c$ equally-sized pieces.
  For example, $e(0110) = \langle 01, 10 \rangle$.

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
