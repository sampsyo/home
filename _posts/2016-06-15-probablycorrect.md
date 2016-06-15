---
title: Probably Correct
mathjax: true
excerpt: |
    Say you have a program that's right only some of the time. How can you tell whether it's correct enough? Using with some Wikipedia-level statistics, it's pretty easy to make probabilistic statements about quality. I'll explain a couple of easy techniques for measuring statistical correctness. Then I'll argue that it's deceptively difficult produce guarantees that are any stronger than the ones you get from the basic techniques.
---
How do you know whether a program is good enough if it's allowed to be wrong some of the time?

Say, for example, that you want to use [Quake III's famous inverse square root approximation][fisr].
The approximation is closer to $x^{-1/2}$ for some inputs $x$ and farther away for others.
You'll want to know the chances that the approximation is close enough for the $x$s you care about.

[fisr]: https://en.wikipedia.org/wiki/Fast_inverse_square_root

When your program can only be right some of the time, it's important to take a statistical view of correctness.
This is not just about squirrelly floating-point hacks: probably-correct programs are ubiquitous, from [Siri][] to [Tesla's autopilot][autopilot].
This post is about infusing statistics into the ways we define correctness and the everyday tools we use to enforce it, like unit testing.
We'll explore two simple but solid approaches to enforcing statistical correctness.
The first is an analogy to traditional testing, and the second moves checking to run time for a stronger guarantee.
Both require only Wikipedia-level statistics to understand and implement.

[Siri]: http://www.apple.com/ios/siri/
[autopilot]: https://www.teslamotors.com/presskit/autopilot

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
If you know your threshold for a good-enough inverse square root is an error of 0.01, you'll want to know your chances of violating that bound.

Nondeterministically correct programs are also important, of course, but there the goal is to show something more complicated: something like $\forall x \; \text{Pr}\left[ f(x) \text{ is good} \right] \ge T$.
This post focuses on deterministic programs.

[fisr.py]: https://gist.github.com/sampsyo/c1ed448618dadce682fdc5303ce432ec


## Statistical Testing

There's an easy way to get a basic kind of statistical correctness.
It's roughly equivalent to traditional testing in terms of both difficulty and strength, so I'll call it **statistical testing**.
(But to be clear, this is not my invention.)

The idea is to pick, instead of a set $X$ of representative inputs, a [probability distribution][] $D$ of inputs that you think is representative of real-world behavior.
For the fast inverse square root function, for example, we might pick a uniform distribution between 0.0 and 10.0, suggesting that any input in that range is equally likely.

Statistical testing can show, with high confidence, when you randomly choose an $x$ from the input distribution $D$, it has a high probability of making $f(x)$ good.
In other words, your goal is to show:

\\[ \text{Pr}_{x \sim D} \left[ f(x) \text{ is good} \right] \ge T \\]

with confidence $\alpha$.
Your [confidence][] parameter helps you decide how much evidence to collect---instead of proving that statement absolutely, we'll say that we have observed enough evidence that there's only an $\alpha$ chance we observed a random fluke.

Let $p = \text{Pr}_{x \sim D} \left[ f(x) \text{ is good} \right]$ be the *correctness probability* for $f$.
Our goal is to check whether $p \ge T$, our threshold for *good enough*.
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
If $p_{\text{low}} \ge T$, then you can say with confidence $\alpha$ that $f$ is good on the input distribution $D$.
If $p_{\text{high}} \le T$, then you can say it's wrong.
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

The statistical testing technique is so simple that it, or something at least as strong, should appear in every paper that proposes a new approximation strategy.
It doesn't require any fancy computer science: all you need to do is run $f$ as a black box and check its output, just like in traditional testing.
Our [probabilistic assertions][passert] checker uses some fanciness to make the approach more efficient, but these tricks aren't necessary to perform a statistically sound test.
So if you read an [approximate computing][approx] paper that doesn't report its $\alpha$, be suspicious.

[passert]: http://dx.doi.org/10.1145/2594291.2594294
[npu]: http://dx.doi.org/10.1109/MICRO.2012.48
[loop perforation]: http://dx.doi.org/10.1145/2025113.2025133
[confidence]: https://en.wikipedia.org/wiki/Confidence_interval
[cp gist]: https://gist.github.com/sampsyo/c073c089bde311a6777313a4a7ac933e


### Limitations

Statistical testing is limited by its need for an input distribution, $D$.
That requirement makes statistical testing's guarantee about as strong as traditional testing is for normal programs:
it says that your program behaves itself under specific conditions that you anticipate in development.
It doesn't say anything about what will happen when your program meets the real world---there are no guarantees for any input distribution other than $D$.

More subtly, statistical testing also requires that you have a $D$ that you can generate random samples from.
This makes it tricky to use, for example, if your $f$ is an image classifier that works on photographs that users upload to a Web service---it's hard to randomly generate photos from scratch!
You could sample from a pool of test photos, but that will only let you draw conclusions about those test photos---not the distribution of photos that users might upload.

Statistical testing is useful when you can anticipate the input distribution ahead of time.
Is it possible to make statements that don't depend on a known, sample-able distribution?


## Going On-Line: Statistical Checking

A stronger guarantee could help us cope with unanticipated distributions---even *adversarial* distributions.
For example, a user might find
a single $x_\text{bad}$ input that your program doesn't handle well and then issue a probability distribution $D_\text{bad}$ that hammers on that one $x_\text{bad}$ over and over.
Statistical testing will never help with adversarial input distributions, but some form of on-line enforcement might.

Let's explore a simple on-line variant of statistical testing, which I'll call **statistical checking**, and consider how its guarantees stack up against adversarial input distributions.
The idea is that you have an oracle that can decide whether a given execution $f(x)$ is good or bad, but it's too expensive to run on *every* execution.
For example, you can always check the [fast inverse square root][fisr] output by comparing with an exact $x^{-1/2}$ computation, but that would obviate all the efficiency benefits of using the approximation in the first place.
Statistical checking reduces the overhead by running the oracle after a random sample of executions.

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

One approach that *can't* beat the simple techniques is an on-line heuristic.
Here's the usual line of reasoning:

> Statistical testing is weak because it only knows about inputs we anticipated *in vitro*.
> And statistical checking is weak because it only looks at some of the inputs at run time.
> To do better, let's check *every* execution!
> Just before running $f$ on $x$, or just after getting the output $f(x)$, apply some heuristic to predict whether the execution is good or bad.
> The heuristic will statistically avoid bad behavior, so we'll get a stronger guarantee.

Let's call this general approach **heuristic checking**.
It's "easy" because there's no program analysis necessary: we still get to treat $f$ as a black box.
And the idea to check every run sounds like it might offer a stronger kind of guarantee.

It can't.
Heuristics are orthogonal to statistical guarantees---you need some other technique, like statistical testing or checking, to make any rigorous statements about them.

The problem is that every heuristic has false positives.
Regardless of whether you choose a decision tree, a support vector machine, a neural network, or a fuzzy lookup table, your favorite heuristic necessarily has blind spots.
For example, you might try to train an SVM on lots of inputs to predict when a given $x$ will cause lots of error in your fast inverse square root approximation, $f$.
If the SVM predicts for a given $x$ that $f(x)$ will be bad, then run the slower fallback $x^{-1/2}$ code instead.

<figure style="max-width: 200px;">
<img src="{{site.base}}/media/heuristiccheck.svg" alt="heuristic checks on inputs and outputs">
<figcaption>Adding checks to an approximate program $f$ yields a new approximate program $f'$.</figcaption>
</figure>

Like any trained model, the SVM will make an wrong prediction in some minority of the cases---in exactly the same way that the approximation itself is inaccurate some of the time.
That means that we can think of the entire SVM-augmented system as just another probably-correct program with all the same problems as the original $f$.
Let $f\'$ be the function that runs the SVM predictor and then chooses to run $f$ or the accurate $x^{-1/2}$.
This new $f\'$ you've created also has some $x_\text{bad}$ inputs and also needs some validation of its correctness, just as much as the original $f$.
You'll still need to apply statistical testing, statistical checking, or something of their ilk to understand the correctness of $f\'$.

In that sense, heuristic checking can never offer any statistical guarantees by itself---it's *orthogonal* to the technique you use to assess statistical correctness.
Even the best heuristic can only adjust the correctness probability; it can't change the *kind* of guarantee that's possible.

That's not to say that heuristic checking is useless.
It can definitely be a useful to empirically improve your program's correctness probability; hence publications in [ASPLOS 2015][approxdebug] (where I'm an author), [ISCA 2015][rumba], [ASPLOS 2016][capri], [PLDI 2016][ira], and [ISCA 2016][mithra].
But we need to be clear about exactly what this kind of work can do: it can adjust the correctness probability $p$, but it can't change the *kind* of guarantee you state about $p$.

Work along these lines needs to be careful to use the right baseline.
Enhancing an $f$ with heuristic checking is morally equivalent to using a more accurate $f$ in the first place.
You could, for example, change your fast inverse square root function to enable the second Newton iteration.
This would increase accuracy and increase cost---exactly the same effects as adding heuristic checking.
So if you design a new checking heuristic, remember to compare against other strategies for improving accuracy.

In my own [ASPLOS 2015 paper][approxdebug], for example, we used a fuzzy memoization table to detect approximate outputs that deviated too much from previously-observed behavior.
Our evaluation showed that the extra checking costs energy, but it also increases accuracy on average.
There were other, more obvious ways to change the energy--accuracy trade-off: we could have adjusted the hardware voltage parameters, for example, and ended up with the same strength of guarantee.
A good evaluation should treat the obvious strategy as a baseline: compare the total energy energy savings when the average accuracy is equal, or vice-versa.

[mithra]: http://www.cc.gatech.edu/~ayazdanb/publication/papers/mithra-isca16.pdf
[rumba]: http://cccp.eecs.umich.edu/papers/dskhudia-isca15.pdf
[ira]: http://dl.acm.org/citation.cfm?id=2908087
[capri]: http://dl.acm.org/citation.cfm?id=2872402
[approxdebug]: https://homes.cs.washington.edu/~luisceze/publications/approxdebug-asplos15.pdf

Statistical correctness is a critical but underappreciated problem. Fortunately, basic statistics are enough to make pretty good statements about statistical correctness. But we're far from done: there are juicy, unsolved, computer-sciencey problems remaining in meaningfully outperforming these basic tools.

---

*Thanks to Cyrus Rashtchian, Todd Mytkowicz, and Kathryn McKinley for unbelievably valuable feedback on earlier drafts of this post. Needless to say, they don't necessarily agree with everything here.*