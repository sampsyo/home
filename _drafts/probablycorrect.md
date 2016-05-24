---
title: Probably Correct
---
What does it mean to say that a program is good enough when it's allowed to be wrong some of the time?

If that sounds crazy, remember that machine-learning models compete on precision and recall, that distributed systems are allowed to fail, and that Siri is still useful despite its miss rate.
And it's the whole idea in [approximate computing][].

TK: Then: It's not as easy as with normal correctness, where the ultimate goal is **verification**:

$$f \text{ is correct}
  \Leftrightarrow
  \forall x \; f(x) \text{ is good}$$

which says the program behaves well on every input. That's hard, so we also have **testing,** which says a program behaves well on a few example inputs:

$$\forall x \in X \; f(x) \text{ is good}$$

It doesn't imply $\forall x \; f(x) \text{ is correct}$, but it's something.

The word *good* is intentionally vague: it might say something about the output $f$ writes to a file, or about how fast $f$ runs, or whether $f$ violated some security policy.

---

But what happens when your program is allowed to be wrong some of the time?

I'm going to ignore nondeterministic programs for this post. Those are programs where the probabilistic behavior arises from inside the program. In those, you want to show something like $\forall x \; \text{Pr}\left[ f(x) \text{ is good} \right] \ge P$. Instead, this post is just about deterministic programs---for any given input, you always get the same output---where some inputs are good and other inputs are bad. That includes most machine learning models and approximate computing techniques like NPUs and loop perforation.

The problem is that there are lots more ways to define correctness statistically than there are "deterministic" definitions. And we don't have names for them, so even explaining your goal can be tricky.

There's a straightforward analog for program verification:

$$\forall x \; \text{Pr}\left[ f(x) \text{ is good} \right] \ge P$$

Let's call this property **probabilistic verification**.
This implies that $f$ is nondeterministic: for a given input $x$, sometimes it behaves well and sometimes it doesn't.
But we know it has a high *chance* of giving a good answer on any given run.
I think probabilistic verification is strictly harder than traditional program verification: it has all the same challenges and more.

Then there's an equally straightforward analog for testing:

$$\forall x \in X \; 
  \text{Pr}\left[ f(x) \text{ is good} \right] \ge P$$

This one looks straightforward, but it's actually pretty hard: you need a conservative analysis for the nondeterminism in $f$.
To make things practical, *confidence* usually comes in at this point.
Checking a property up to a given confidence level means that the property is allowed to be wrong sometimes.
The nice thing is that this can be accomplished just by running the program a lot and using a *statistical hypothesis test*.

You can take basically any property and call it "$f$ is correctly 

Then, show the variation where $X$ is a distribution instead of a set, and the criterion is probability.
Here we're crossing into crazy town.

The spirit in this case is that you *know* what you will see at run time, in aggregate.
Call it **known-distribution** checking. This is strictly weaker than verification in the analogy, where the spirit is that you *don't know* what you will see at run time.

It's totally different from static verification where someone can't give you an *adversarial* input.
That you can unleash the program on the world and still know that things will be OK.

For *that*, for something analogous to static verification, we'd need to prove:

$\forall x \; \Pr{f(x) \text{ is correct}} \ge P$

Confidence is easier to do:

$\Pr{ \forall x \; \Pr{f(x) \text{ is correct} \ge P } \ge 1 - \alpha$

(Actually, you can put anything inside that outer probability.)
This is the current gold standard for approximate computing evaluations, I guess. And some papers don't even do that.

What we actually get from hypothesis testing (passert):

$\Pr{f(x) \text{ is correct} \;|\; x \sim D} \ge P$

Same with Roomba; new ISCA paper.

---

A surprisingly hard way to test:

$$\forall x \in X \; 
  \text{Pr}\left[ f(x) \text{ is good} \right] \ge P$$

Add confidence:

$$
\text{Pr}\left[
\forall x \in X \; 
  \text{Pr}\left[ f(x) \text{ is good} \right] \ge P
\right] \ge 1 - \alpha
$$

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