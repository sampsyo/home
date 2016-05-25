---
title: Probably Correct
---
What does it mean to say that a program is good enough when it's allowed to be wrong some of the time?

If that sounds crazy, remember that machine-learning models compete on precision and recall, that distributed systems are allowed to fail, and that Siri is still useful despite its miss rate.
And it's the whole idea in [approximate computing][].

This post is about defining what it means for this kind of program to be *statistically* correct.
The problem is that we don't even have names for the kinds of guarantees that different approaches to correctness can give us.
What are the statistical equivalents of static verification, testing, or dynamic safety checking?
If we're going to write papers about probably-correct programs (and we are), we need to be clear about what our goals are.

## Normal Correctness

With normal, hopefully-always-correct programs, the ultimate goal is **verification**:

$$\forall x \; f(x) \text{ is good}$$

The word *good* is intentionally vague: it might say something about the output $f$ writes to a file, or about how fast $f$ runs, or whether $f$ violated some security policy.
In any case, verification says your program behaves well on every input.

Verification is hard, so we also have **testing,** which says a program behaves well on a few example inputs:

$$\forall x \in X \; f(x) \text{ is good}$$

Testing tells us a set of inputs $X$ all lead to good behavior.
It doesn't imply $\forall x \; f(x) \text{ is correct}$, but it's something.

## Probably Correct Programs

I'm going to ignore nondeterministic programs for this post. Those are programs where the probabilistic behavior arises from inside the program. In those, you want to show something like $\forall x \; \text{Pr}\left[ f(x) \text{ is good} \right] \ge P$. Instead, this post is just about deterministic programs---for any given input, you always get the same output---where some inputs are good and other inputs are bad. That includes most machine learning models and approximate computing techniques like NPUs and loop perforation.


## Distribution Testing

$$
\text{Pr}\left[ f(x) \text{ is good} \;|\; x \sim D \right] \ge P
$$

This is the kind of property we verify with passert. It's also what evaluation for approximate computing should do (but often don't).
Here's what you need to do to get that kind of property via hypothesis testing:

1. Pick your distribution $D$.
2. Get $n$ examples $x$ of $D$.
3. Run $f$ on $x$ each time.
4. Check whether $f(x)$ is good on each run; let $g$ be the number of good runs.
5. Now, $g \over n$ is your estimate for $P$. Use some simple statistics to decide whether the true probability is likely bigger than $P$.

It's a little trickier than testing for normal programs, since you have to pick a whole distribution $D$ that can generate lots of examples instead of just a fixed set of inputs $X$.
But the idea is more or less the same: you don't need to know anything about the *inside* of the program; you just need to be able to run it and measure the "good" property you want, just like in normal testing.

To be clear, the hypothesis testing gives you a guarantee *up to a confidence level*.
That looks like a doubly-wrapped probability:

$$
\text{Pr}\left[
\text{Pr}\left[ f(x) \text{ is good} \;|\; x \sim D \right] \ge P
\right] \ge 1 - \alpha
$$

Here, $\alpha$ is the confidence level. It's the chance that the verification is lying to you.

That's the idea behind probabilistic assertions. (Our paper bakes this approach into a tool and makes it more efficient.)
It's also the *bare minimum* that a paper on approximate computing should do!
If a paper reports the fraction of runs that were accurate enough but *doesn't* do a hypothesis test, you should be sad.

## The Limits of Distribution Testing

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