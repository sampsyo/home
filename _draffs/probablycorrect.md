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


## A Stronger Guarantee

Statistical testing tells you something for probably-correct programs that's about as strong as normal testing for normal programs: that your program works well *in vitro*, under lab conditions.
It doesn't say anything about what will happens when your program is exposed to the nastiness of the real world.
Just like testing, then, it's not really a *guarantee*, except for the conditions you were able to anticipate during development.

What would a real guarantee look like, then, for probably-correct programs?

TK

Call it **known-distribution** checking. This is strictly weaker than verification in the analogy, where the spirit is that you *don't know* what you will see at run time.

It's totally different from static verification where someone can't give you an *adversarial* input.
That you can unleash the program on the world and still know that things will be OK.

---

The fundamental problem with the *easy way* is that it depends on a distribution.
It has roughly the same power as testing for traditional programs: you test your program under some known conditions you *think* are representative of real-world behavior, and you hope your findings generalize to how things go in production.
You don't get any guarantee when the real world fails to conform to your expectations.

The more challenging but useful property to verify is a *distribution-independent* one.
We need tools that can tell you whether your program is going to succeed with high probability even when it runs on the weird distributions that real-world users come up with.

To be clear, this has nothing to do with confidence: even a hypothesis-testing approach can do better than the easy way, up to confidence.

## How Not to Improve Statistical Guarantees

There's a worrying trend in approximate-computing research that appears to improve on "the easy way" without fundamentally changing anything.
These papers add statistical controls to programs that make them better on average while purporting to offer better guarantees.
But increasing $P$ is not a stronger kind of guarantee---you can accomplish the same thing by just using a more accurate approximate strategy, such as a larger NPU.

Ideas like this include:

- Put a filter on the input and predict whether it will be a "good" or "bad" input. For bad inputs, run the approximate version.
- Check the output $f(x)$ and try to guess cheaply whether it's a good or bad output.

There's nothing inherently wrong with these approaches, but they're easy and they lead to the same kind of distribution-sensitive guarantee.

These are *dynamic* approaches, but they don't change the approach you need to use to check their effectiveness.
Just because a mechanism runs in deployment, it doesn't necessarily offer any stronger guarantees!

You might tell yourself the story, "Well, instead of just running the program a bunch in testing and hoping for the best after that, this paper actually looks at every execution and decides whether it's good or not!" But *soundly* deciding this at run time is hard (probably impossible in general).
The current papers that do this kind of thing are just heuristics, so they absolutely cannot offer any stronger form of guarantee.
Instead, all they can do is adjust $P$.
In essence, they're ways to build a better approximation---not ways to bring better guarantees.

I can't believe I'm about to make a car analogy, but it's like a Prius.
Hybrid cars use electric motors internally, but that shouldn't fool you into thinking they're electric cars.
A hybrid is fundamentally a gas-powered conveyance---it's just a more efficient way to build a gas-powered car.
So when you think about a Prius's efficiency, think of it as on the same spectrum as traditional cars---not in another category entirely.

In the same way, bolting some run-time heuristics onto an approximate program doesn't give it statistical guarantees.
It just makes it, on average, more accurate.
Shifting to a wholly new kind of statistical dependability will require very different-looking techniques.
