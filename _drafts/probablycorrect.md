---
title: Probably Correct
mathjax: true
---
How do you know whether a program is good enough if it's allowed to be wrong some of the time?

Say, for example, that you want to know whether [Quake III's famous inverse square root approximation][fisr] is accurate enough for you.
The approximation is closer to $x^{-1/2}$ for some inputs $x$ and farther away for others.
You'll want to know the chances that the approximation is close enough for any given $x$.
The same "good enough" requirements come up when you're classifying images with machine learning or applying your favorite [approximate computing][approx] technique.

[fisr]: https://en.wikipedia.org/wiki/Fast_inverse_square_root

When your program can only be right some of the time, it's important to take a statistical view of correctness.
This post is about infusing statistics into the ways we define correctness and the everyday tools we use to enforce it, like unit testing.
We'll explore two simple but solid approaches to enforcing statistical correctness.
The first is an analogy to traditional testing, and the second moves checking to run time for a stronger guarantee.
Both require only Wikipedia-level statistics to understand and implement.

At the end, I'll argue that these basic approaches are deceptively difficult to beat.
If we want to make stronger guarantees about probably-correct programs, we'll need more creative ideas.

[approx]: {{site.base}}/research.html#approximate-computing


## Correct vs. Probably Correct

First, let's recap traditional definitions of correctness.
With ordinary, hopefully-always-correct programs, the ultimate goal is **verification**:

\\[ \forall x \; f(x) \text{ is good} \\]

The word *good* is intentionally vague: it might mean something about the output $f$ writes to a file, or about how fast $f$ runs, or whether $f$ violated some security policy.
In any case, verification says your program behaves well on every input.

Verification is hard, so we also have **testing**, which says a program behaves well on a few example inputs:

\\[ \forall\; x \in X \; f(x) \text{ is good} \\]

Testing tells us a set of inputs $X$ all lead to good behavior.
It doesn't imply $\forall x$ anything, but it's something.

For this post, we'll assume $f$ is good on some inputs and bad on others, but it doesn't fail at random.
In other words, it's *deterministic:* for a given $x$, running $f(x)$ is either always good or always bad.
The [fast inverse square root][fisr] function is one example: the error is below $10^{-4}$ for most inputs, but it can be as high as $0.04$ for reasonably small values of $x$.
(See for yourself with this [Python implementation][fisr.py].)
If you know your threshold for a good-enough inverse square root is an error of 0.01, you'll want to know you chances of violating that bound.

Nondeterministically correct programs are also important, of course, but there the goal is to show something more complicated: something like $\forall x \; \text{Pr}\left[ f(x) \text{ is good} \right] \ge P$.
This post focuses on deterministic programs.

[fisr.py]: {{site.base}}/media/fisr.py


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
[loop perforation]: http://dx.doi.org/10.1145/2025113.2025133http://localhost:4000/
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
Let $p$ be the probability that an execution on that day is good: in expectation, $p$ is also the fraction of good executions.
Again, we hope $p$ will be high.
Here's the statistical checking recipe:

1. Choose a probability $p_\text{check}$ that you'll use to decide whether to check each execution.
2. After running $f(x)$ each time, flip a biased coin that comes up heads with probability $p_\text{check}$. If it's heads, pay the expense to check whether $f(x)$ is good; otherwise, do nothing.
3. At the end of the day, tally up the number of times you checked, $c$, and the number of times the check came out good, $g$. Now, $\hat{p} = \frac{g}{c}$ is your estimate for $p$.
4. Use the same statistical magic as last time to get a confidence interval on $p$.

The same binomial confidence interval techniques that we used for statistical testing, like Clopper--Pearson, work here too.
And if you want to do the statistics multiple times, like at the end of *every* day or even after each execution you randomly check, you can again use [Wald's sequential sampling][wald] to avoid the [multiple comparisons problem][mcp].

TK: Should we do anything with the total number of executions, $n$?

The guarantees are similar: you again get an $\alpha$-confidence interval on $p$ that lets you decide whether you have enough evidence to conclude that the day's executions were good enough or not.
The $p_\text{check}$ knob lets you pay more overhead for a better shot at a conclusive outcome in either direction.

Like random screening in the customs line, randomly choosing the executions to check is the key to defeating adversarial distributions.
This way, your program's adversary can *provably* have no idea which executions will be checked---it has nowhere to hide.
Any non-random strategy, such as [exponential backoff][], admits some adversary that behaves well only on checked executions.
(This [old post with pictures][monitoring post] gets at the same idea.)

[monitoring post]: {{site.base}}/blog/naivemonitoring.html
[exponential backoff]: https://en.wikipedia.org/wiki/Exponential_backoff
[mcp]: https://en.wikipedia.org/wiki/Multiple_comparisons_problem


## Even Stronger Statements

Statistical testing and statistical checking, as simple as they are, yield surprisingly good guarantees.
Is it possible to do even better?

In particular, neither sampling-based technique can say anything about worst-case errors.
We can know with high confidence that 99% of executions are good enough, for example, but we can't know *how* bad that remaining 1% might be.
We could check looser bounds, but sampling will never get us to 100% certainty about anything: there's always a chance we got unlucky and failed to see a particularly bad $x_\text{bad}$.

A worst-case guarantee is deceptively difficult to certify.
I can only see two ways that might work:

* Conservatively identify *all* (not just most) of the bad $x$s for $f$ and detect them at run time.
* Derive a cheap-enough oracle that can dynamically check *every* execution for correctness.

Both options are hard!
And they amount to recovering complete correctness---anything less than perfection risks missing a single outlier $x_\text{bad}$.
Getting a guarantee that's stronger than simple statistical checking will take real creativity.


## Heuristics Can't Beat Statistical Testing

One approach that *can't* beat statistical testing is an on-line heuristic.
Here's the usual line of reasoning:

> Statistical testing is weak because it only knows about inputs we anticipated *in vitro*.
> And statistical checking is weak because it only looks at a subset of the inputs at run time.
> To do better, let's check *every* execution!
> Just before running $f$ on $x$, or just after getting the output $f(x)$, apply some heuristic to predict whether the execution is good or bad.
> The heuristic will statistically avoid bad behavior, so we'll get a stronger guarantee.

Let's call this general approach **heuristic checking**.
There's no program analysis necessary: we get to keep treating $f$ as a black box.
And the idea to check every run sounds like it might offer a stronger kind of guarantee.

It can't.
Heuristics by themselves cannot by themselves offer *any* guarantees---you need to resort to principled techniques, like statistical testing or checking, to say anything about them.

I don't mean to imply that heuristics are useless.
Heuristic checking can be a useful way to adjust your program's correctness probability $p$; hence publications in [ASPLOS 2015][approxdebug] (where I'm an author), [ISCA 2015][rumba], [ASPLOS 2016][capri], [PLDI 2016][ira], and [ISCA 2016][mithra].
But adjusting $p$ is all a heuristic can do: it can't give you a stronger kind of guarantee.
The kind of guarantee you get comes from the validation you apply *after* introducing the heuristic.

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
