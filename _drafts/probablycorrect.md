---
title: Probably Correct
mathjax: true
---
What does it mean to say that a program is good enough when it's allowed to be wrong some of the time?

If that sounds crazy, remember that machine-learning models compete on precision and recall, that distributed systems are allowed to fail, and that Siri is still useful despite its miss rate.
And it's the whole idea in [approximate computing][approx].

This post is about what it means for this kind of program to be *statistically* correct.
We don't even have names for the kinds of guarantees we might want for most-of-the-time correctness.
If we're going to write papers about probably-correct programs (and we are), we need to be clear about what our goals are.

I'll describe a dorkily simple way to conclude something rigorous about your probably-correct program that only requires Wikipedia-level statistics to apply.
Then I'll argue that it's deceptively difficult to do anything stronger than this basic technique---even when you try to catch bad behavior at run time.
If we want to make stronger guarantees about probably-correct programs, we'll need more creative ideas.

[approx]: {{site.base}}/research.html#approximate-computing


## Normal Correctness

With normal, hopefully-always-correct programs, the ultimate goal is **verification**:

\\[ \forall x \; f(x) \text{ is good} \\]

The word *good* is intentionally vague: it might say something about the output $f$ writes to a file, or about how fast $f$ runs, or whether $f$ violated some security policy.
In any case, verification says your program behaves well on every input.

Verification is hard, so we also have **testing**, which says a program behaves well on a few example inputs:

\\[ \forall\; x \in X \; f(x) \text{ is good} \\]

Testing tells us a set of inputs $X$ all lead to good behavior.
It doesn't imply $\forall x$ anything, but it's something.


## Deterministic, Probably-Correct Programs

For this post, let's assume $f$ is good on some inputs and bad on others, but it doesn't fail at random.
In other words, it's *deterministic:* for a given $x$, running $f(x)$ is either always good or always bad.
For example, $f$ might be an image classifier that gives the correct class for most of the photos in a test set but is still wrong on a few.
Or it might use a deterministic approximation technique like [loop perforation][] or an [NPU][].

Nondeterministically correct programs are also important, of course, but there the goal is to show something more complicated: something like $\forall x \; \text{Pr}\left[ f(x) \text{ is good} \right] \ge P$.
This post focuses on the easy stuff.


## Statistical Testing

There's an easy way to get a basic kind of statistical correctness.
It's roughly equivalent to traditional testing in terms of both difficulty and strength, so I'll call it **statistical testing**.
(But to be clear, this is not my invention.)

The idea is to pick, instead of a set $X$ of representative inputs, a [probability distribution][] $D$ of inputs that you think is representative of real-world behavior.
For example, if you're going to run on data from the natural world, you might choose a [normal distribution][].
Then you can show with high *confidence* that, when you randomly choose an $x$ from the input distribution $D$, it has a high probability of making $f(x)$ good.

In other words, your goal is to show:

\\[ \text{Pr}\left[ f(x) \text{ is good} \;\vert\; x \sim D \right] \ge P \\]

with confidence $\alpha$.
Your [confidence][] parameter helps you decide how much evidence to collect---instead of proving that statement absolutely, we'll say that we have observed enough evidence that there's only an $\alpha$ chance we observed a random fluke.

Let $p = \text{Pr}\left[ f(x) \text{ is good} \;\vert\; x \sim D \right]$ be the *correctness probability* for $f$.
Our goal is to check whether $p \ge P$, our threshold for *good enough*.
Here's the complete recipe:

1. Pick your input distribution $D$.
2. Randomly choose $n$ inputs $x$ according to $D$. (This is called [sampling][].)
3. Run $f$ on each sampled $x$ and check whether each $f(x)$ is good.
4. Let $g$ be the number of good runs. Now, $\hat{p} = \frac{g}{n}$ is your estimate for $p$.
5. Perform some light statistics magic.

There are a few ways to do the statistics. Here's a really simple way: use a [confidence interval formula][binomial interval] to get upper and lower bounds on $p$.
The [Clopper--Pearson][] formula, for example, gives you a $p_{\text{low}}$ and $p_{\text{high}}$ so that:

\\[ \text{Pr}\left[ p_{\text{low}} \le p \le p_{\text{high}} \right] \ge 1 - \alpha \\]

Remember that $\alpha$ is small, so you're saying that it's likely you have an interval around $p$.
If $p_{\text{low}} \ge P$, then you can say with confidence $\alpha$ that $f$ is good on the input distribution $D$.
If $p_{\text{high}} \le P$, then you can say it's wrong.
Otherwise, the test is inconclusive---you need to take more samples.
Collecting more samples (increasing $n$) tightens the interval; demanding higher confidence (decreasing $\alpha$) loosens the interval.

There are fancier ways, too: you could use [Wald's sequential sampling][wald] to automatically choose $n$ and rule out possibility of an inconclusive result.
But the simple Clopper--Pearson way is perfectly good, and it's easy to implement: here it is in [four lines of Python][cp gist].

[wald]: https://en.wikipedia.org/wiki/Sequential_probability_ratio_test
[binomial interval]: https://en.m.wikipedia.org/wiki/Binomial_proportion_confidence_interval
[uniform distribution]: http://mathworld.wolfram.com/UniformDistribution.html
[probability distribution]: https://en.wikipedia.org/wiki/Probability_distribution
[normal distribution]: https://en.wikipedia.org/wiki/Normal_distribution
[sampling]: https://en.wikipedia.org/wiki/Sampling_(statistics)
[clopper--pearson]: https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval#Clopper-Pearson_interval

Statistical testing should be the bar for publication in papers about statistical correctness.
It doesn't require any fancy computer science: all you need to do is run $f$ as a black box and check its output, just like in traditional testing.
Our [probabilistic assertions][passert] checker uses some fanciness to make statistical testing more efficient, but the statistics couldn't be easier to do at home.
So if you read an approximate computing paper that doesn't report its $\alpha$, be suspicious.

[passert]: http://dx.doi.org/10.1145/2594291.2594294
[npu]: http://dx.doi.org/10.1109/MICRO.2012.48
[loop perforation]: http://dx.doi.org/10.1145/2025113.2025133
[confidence]: https://en.wikipedia.org/wiki/Confidence_interval
[cp gist]: https://gist.github.com/sampsyo/c073c089bde311a6777313a4a7ac933e


## Going on Line: Statistical Checking

Statistical testing is about as strong as traditional testing is for normal programs:
it says that your program behaves itself under specific conditions that you anticipate in development.
It doesn't say anything about what will happen when your program meets the real world---there are no guarantees for any input distribution other than $D$.

Are stronger guarantees possible?
A stronger guarantee could help us cope with unanticipated distributions---even *adversarial* distributions.
For example, a user might find
a single $x_\text{bad}$ input that your program doesn't handle well and then issue a probability distribution $D_\text{bad}$ that just produces that $x_\text{bad}$ over and over again.
Statistical testing will never help with adversarial input distributions, but some form of on-line enforcement might.

Let's explore a simple on-line variant of statistical testing, which I'll call **statistical checking**, and consider how its guarantees stack up against adversarial input distributions.
The idea is that you have an oracle that can decide whether a given execution $f(x)$ is good or bad, but it's too expensive to run on *every* execution.
For example, you might have a precise version of your approximate program, $f\'$, where "goodness" is defined using the distance between $f(x)$ and $f\'(x)$, but running $f\'$ obviates all the efficiency benefits of the $f$ approximation.
Statistical checking, then, runs the oracle after a random sample of $f$ executions.

Say you run $f$ on a server for a full day and, at the end of the day, you want to know how many of the requests were good.
Let $r$ be the fraction of good executions in that day; we hope that $r$ will be high.
Here's the statistical checking recipe:

1. Choose a probability $p_\text{check}$ that you'll use to decide whether to check each execution.
2. After running $f(x)$ each time, flip a biased coin that comes up heads with probability $p_\text{check}$. If it's heads, pay the expense to check whether $f(x)$ is good; otherwise, do nothing.
3. At the end of the day, tally up the number of times you checked, $c$, and the number of times the check came out good, $g$. Now, $\hat{r} = \frac{g}{c}$ is your estimate for $r$.
4. Use a little more light statistical magic.

TK note that random sampling is key, as I argued in a [less detailed blog post from a couple of years ago][monitoring post].

TK what's the exact test

TK repeated testing problem

[monitoring post]: {{site.base}}/blog/naivemonitoring.html


## Even Stronger Statements

Statistical testing and statistical checking are pretty simple techniques.
TK Question about *even stronger* guarantees, like catching *outliers*.

What would a strong guarantee look like for probably-correct programs?
Ideally, we'd say that a program's correctness probability is high for any input distribution that users can throw at it.
Independent of the input distribution, we should be guaranteed that 99 of every 100 executions are good in expectation.

This kind of distribution-independent guarantee is deceptively difficult to certify.
Any such technique would need to cope with adversarial input distributions.
For example, a user could find

I can only see three ways that might work:

* Conservatively identify *all* (not just most) of the bad $x$s for $f$ and detect them at run time.
* Dynamically check *every* execution for correctness.
* Somehow use a memory of previous runs to check for adversarial distributions, like those that lean too heavily on a small number of bad inputs.

All these options are hard!
The first two options are as hard as recovering complete correctness---anything less than perfection risks missing a single $x_\text{bad}$ that an adversary could use to drive your correctness probability to zero.
And the third option is so vague that I'm not certain it's even possible.

Getting a guarantee that's stronger than statistical testing will take real creativity.


## Heuristics Can't Beat Statistical Testing

One approach that *can't* beat statistical testing is an on-line heuristic.
Here's the usual line of reasoning:

> Statistical testing is weak because it only knows about inputs we anticipated *in vitro*.
> To do better, let's try to detect bad inputs or bad outputs at run time!
> It's easy: just before running $f$ on $x$, or just after getting the output $f(x)$, apply some heuristic to predict whether the execution is good or bad.
> The heuristic will statistically avoid bad behavior, so we'll get a stronger guarantee.

There's no program analysis necessary: we get to keep treating $f$ as a black box.
Let's call this general approach **heuristic checking**.
Heuristic checking can be a useful way to adjust your program's correctness probability $p$; hence publications in [ASPLOS 2015][approxdebug] (where I'm an author), [ISCA 2015][rumba], [ASPLOS 2016][capri], [PLDI 2016][ira], and [ISCA 2016][mithra].
But adjusting $p$ is all a heuristic can do: it can't give you a stronger kind of guarantee.

The problem is that every heuristic has false positives.
Regardless of whether you choose a decision tree, a support vector machine, a neural network, or just a fuzzy lookup table, the result is the same---there's some $x_\text{bad}$ out there that will fool your heuristic.
The existence of even a single $x_\text{bad}$ ruins your shot at a strong guarantee.

So while heuristic checking can help increase a program's correctness probability $p$, it doesn't change the *kind* of guarantee that's possible.
In fact, to show that your heuristic is working, you need to resort to statistical testing and all its pitfalls.
In that way, using a dynamic heuristic is morally equivalent to just using a more accurate $f$ in the first place---and then checking *that* with statistical testing.

I can't believe I'm about to make a car analogy, but it's like a Prius.
Hybrid cars use electric motors internally, but they're still 100% powered by gas.
So a Prius is just a more efficient way to make a traditional gas car, and we shouldn't be confused into thinking they're electric vehicles.
In the same way, bolting a heuristic onto an approximate program doesn't give it a stronger kind of guarantee than an "unchecked" approximate program.

[mithra]: http://www.cc.gatech.edu/~ayazdanb/publication/papers/mithra-isca16.pdf
[rumba]: http://cccp.eecs.umich.edu/papers/dskhudia-isca15.pdf
[ira]: http://dl.acm.org/citation.cfm?id=2908087
[capri]: http://dl.acm.org/citation.cfm?id=2872402
[approxdebug]: https://homes.cs.washington.edu/~luisceze/publications/approxdebug-asplos15.pdf
