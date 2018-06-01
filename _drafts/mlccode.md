---
title: Please Help Me Solve an Old Approximate Computing Problem
mathjax: true
excerpt: |
    Here's a problem from our paper on [approximate storage][approxstorage] that has been bugging me for about five years now. I think it's a coding theory problem, but I don't know where to start. Send me your brilliant insights.

    [approxstorage]: https://dl.acm.org/citation.cfm?id=2644808
---
In a different era, I worked on a project about [approximate storage][approxstorage].
This post is about a problem we never solved during that project---a problem that haunts me to this day.

One of our ideas was to abuse [multi-level cells (MLCs)][mlc], which are where you pack more than one bit into a single physical memory element.
Because memory cells are analog devices, MLC designs amount to a choice of how to quantize the underlying signal to a digital value.
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
If $v$ is the value you originally wrote and $v_1$ and $v_2$ are other cell values where $|v - v_1| \ge |v - v_2|$, then the probability of reading $v_1$ is at most the probability of reading $v_2$.
Applications enjoy small errors more than they enjoy large errors, so MLC-style monotonic errors are a good fit.

The problem, however, is that real programs don't use many two-bit numbers.
It's not feasible to cram 65,536 levels into a single cell in most technologies, but we'd really like to be able to use 16-bit numbers in our programs.
It's easy to combine, say, two two-bit cells to represent a four-bit number under ordinary circumstances: just split up the bits or use a [Gray code][] to minimize the expected cost of small changes.
But these strategies ruin our nice error monotonicity property:
small changes in one cell might cause large changes in our four-bit number.

### Stating the Problem

Let's compare strategies for encoding $n$-bit numbers onto $c$ cell values of $b$ bits each.
A given code will consist of an encoding function $e$ and a decoding function $d$.
Encoding turns a single $n$-bit number into a $c$-tuple of $b$-bit numbers, so we'll write $e(x) = \overline{v} = \langle v_1, v_2, \ldots, v_c \rangle$ where each $v_i$ consists of $b$ bits.

We assume that, within a given cell, small errors are more likely than large errors.
We *hope* that small per-cell errors translate to small errors in the decoded value.
To make this precise, define an overloaded function $\Delta$ that gets the size of errors in either encoded or plain-text values.
For plain numbers, for example, $\Delta(1000, 0110) = 2$; this function is the absolute difference between the values.
For encoded cell-value tuples, $\Delta(\langle 01, 10 \rangle, \langle 10, 01 \rangle) = 2$; the function is the sum of the differences for each cell.
Here's a formal statement of an error-monotonicity property we'd like:

$$\Delta(\overline{v}, \overline{v}_1) \ge \Delta(\overline{v}, \overline{v}_2)
\Rightarrow
\Delta(d(\overline{v}), d(\overline{v}_1)) \ge \Delta(d(\overline{v}), d(\overline{v}_2))$$

In other words, if some cell-level error is smaller than another cell-level error, then it *also* translates to a smaller error in the space of decoded numbers.

### The Options

Let's consider a few options.
For simplicity, I'll give examples for $n=4$, $c=2$, and $b=2$, but each strategy should generalize to any problem size where $n = c \times b$.

* I'll call the naïve strategy a *chunking code* because it just breaks the number into $c$ equally-sized pieces.
  For example, $e(0110) = \langle 01, 10 \rangle$.
  But a small, one-level error in the first cell causes a large error in the represented value.
  For example, an error of size one can turn $\langle 01, 10 \rangle$
  into $\langle 00, 10 \rangle$.
  The decoded error size is $\Delta(0110, 0010) = 4$.
  So a distance-one error in the cells can lead to a distance-four error in the value. Such an error is just as likely as a distance-one value error (when the second cell is faulty instead of the first).

* A [Gray code][] tries to avoid situations where incrementing a number makes many cells change simultaneously.
  This property minimizes the cost of the most common writes, so it's a popular strategy for memory coding.
  But I contend that, in an abstract sense, it's the *opposite* of what we want for error robustness.
  A Gray code takes small changes in the value and turns them into small changes in the cells. We want this implication to go the other way around: small changes in the cells should lead to small changes in the corresponding values.
  A small change in a cell can still lead to an arbitrarily large change in the represented number.

* Grasping at straws, we could try a *striping code* where the bits are interleaved: the first cell holds all the bits at positions that are zero mod $b$; the next cell gets all the bits at 1 mod $b$, and so on.
  For example, $e(0011) = \langle 01, 01 \rangle$.
  But clearly, a small error in one cell can still lead to a large error in the value.
  For example, a single-level error can produce $\langle 10, 01 \rangle$.
  And
  $d(\langle 10, 01 \rangle) = 1001$, which is a value-space error of 6.

### A Question

None of these three options meets the goal I wrote above.
Worse, none of them seems meaningfully *closer* to satisfying error-monotonicity than any other.
For about five years now, I've wondered whether it's possible to do any better than the naïve chunking code.
I would be equally satisfied with a definitive *no* as with an existence proof.
But so far, I have no traction at all in either direction.
Let me know if you have any bright ideas---I'd be thrilled.

[approxstorage]: https://dl.acm.org/citation.cfm?id=2644808
[mlc]: https://en.wikipedia.org/wiki/Multi-level_cell
[gray code]: https://en.wikipedia.org/wiki/Gray_code
