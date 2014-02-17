---
title: "Naive Monitoring for Approximate Computing"
kind: article
layout: post
excerpt: |
    Some papers on approximate computing systems propose simple systems for checking computations' error rates. These systems can be naive and ineffective at solving the problems they were meant to address.
---

<aside class="warning">
<p>
<strong>Warning:</strong>
<em>Approximate computing</em> is a trend in computer systems research that seeks to trade off accuracy for efficiency. This post assumes some familiarity with, or at least a passing interest in, recent work on approximation. It could get boring otherwise. For context, you may be interested in reading a <a href="http://spectrum.ieee.org/computing/software/enerj-the-language-of-goodenough-computing">magazine article</a> or older <a href="https://homes.cs.washington.edu/~asampson/blog/">posts on this blog</a>.
</p>
</aside>

As a cottage research industry, approximate computing is still young. But it has already developed characteristic research patterns worthy of criticism. One trend I've noticed recently is a repeated reinvention of a technique I'll call *naive monitoring* attached to otherwise excellent papers (which I won't call out individually). I believe that naive monitoring is ineffective at its stated goals and should be excised as an appendage to future research. Papers that include it would be just fine---better, even---without it.

## Why Naive Monitoring?

Pretend you're a grad student for a moment. Say you've invented a great way to trade off reliability for efficiency in your favorite computer system---the [mouse][], for instance. With your idea, you can make mice vastly cheaper and more ergonomic if they're allowed to occasionally emit wrong click coordinates! Most UIs have pretty big buttons, so a few pixels here and there should rarely make a user miss their click target. It's a perfect approximate computing trade-off.

[mouse]: http://en.wikipedia.org/wiki/Mouse_(computing)

You want to publish a paper on approximate pointer input, but your advisor points out that people might be uncomfortable with accepting a mouse design that can produce arbitrarily bad click positions at any time. This is a good point; it would be great to have some assurance that things can't go too badly too much of the time.

Your first idea is to run a bunch of tests on a benchmark suite to measure the number of wrong button clicks that a user experiences while accomplishing a series of tasks. If the average error rate is low enough, the program can be deemed amenable to approximate mousing. Maybe you repeat this process for each user before they get started with the software to avoid specializing too much on the mousing habits of your test subjects. Let's call this approach *error profiling*. It's simple and convenient and it should make your advisor happy.

But, your advisor points out, what about discrepancies between test-time and run-time behavior? What if the user does something with the mouse that you didn't anticipate in the test battery? (Your advisor is really smart.)

Your next proposal is to measure click error periodically during normal operation. Every 100 clicks, you'll ask the user to click twice in the same place: once with approximation enabled and once with it disabled. This duplication lets you compare the results from each click and check whether approximate mousing resulted in a missed button click.

This approach---periodically comparing to error-free operation at run time---is what I'll call *naive monitoring*. It seems to solve many of the problems with profiling, but I believe its advantages are limited.

## Why Not Naive Monitoring?

To see what's wrong with the naive monitoring approach, let's reexamine the problems it was meant to solve. Why was your putative advisor unhappy with simple, all-at-once error profiling? What problem was naive monitoring supposed to solve?

Your advisor probably pictured your error profiling proposal and drew a brain-picture along these lines:

<div class="plot">
    <img src="http://homes.cs.washington.edu/~asampson/media/naive-monitoring/flat.svg"
        width="600" height="100"
        alt="profiling when the error rate is approximately constant">
</div>

You were assuming that the quality would be roughly constant across all executions, so you can get a good measurement just by looking at the first few runs. But then she pictured a more adversarial program, like this:

<div class="plot">
    <img src="http://homes.cs.washington.edu/~asampson/media/naive-monitoring/spiky.svg"
        width="600" height="100"
        alt="profiling misses spikes in the error rate">
</div>

Some programs could have noisier, spikier error behavior: some runs could be much worse than others, and your approach would completely miss these! Clearly, a different approach is necessary. Your naive monitoring proposal spreads the tested executions over all time, hoping to catch these outlier errors:

<div class="plot">
    <img src="http://homes.cs.washington.edu/~asampson/media/naive-monitoring/spiky-naive.svg"
        width="600" height="100"
        alt="imagining that naive monitoring would catch error spikes">
</div>

Your implicit hope was that the executions you choose check throughout deployment will be more likely to contain the errors you want to catch.

But to make a fair apples-to-apples comparison, we need to put error profiling and naive monitoring on even footing: each one gets to observed *N* executions; the difference is just *when* those observed executions occur. But who's to say that *N* evenly distributed executions are more likely to contain deviations than the first *N*? Looked at this way, naive monitoring buys you nothing over profiling. **Naive monitoring is no more likely to catch outliers than profiling.**

You might argue to your advisor, however, that your approach at least provides *statistical* guarantees that profiling can't provide. In particular, it can protect against pathological situations where a program starts behaving badly immediately after testing:

<div class="plot">
    <img src="http://homes.cs.washington.edu/~asampson/media/naive-monitoring/pathological.svg"
        width="600" height="100"
        alt="a pathological error pattern">
</div>

At least naive monitoring catches this case, right? If you monitor *N* out of a total *M* executions, you can [use statistics][binomial interval] to bound the probability that the unmonitored *M -- N* runs cause the overall error rate to be significantly higher than the monitored subset, yes?

Your putative advisor shakes her head, no. Since you're periodically measuring every 100 clicks, your sample is deterministic. It gives you no more statistical power than profiling, which you can think of as a different, equally deterministic sample. **Naive monitoring does not provide better statistical guarantees than profiling; only random sampling can do that.** As with [statistical performance profiling][statprof], good randomness is essential to getting good statistical guarantees.

[binomial interval]: http://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval
[statprof]: http://en.wikipedia.org/wiki/Profiling_(computer_programming)#Statistical_profilers

Naive monitoring does have one saving grace: it can help in situations when you expect inputs to *drift* over time. In our contrived example, you might expect your approximate mouse to gradually start seeing different kinds of clicks that you couldn't anticipate during profiling. In this situation, your error graph might have a gentle positive slope:

<div class="plot">
    <img src="http://homes.cs.washington.edu/~asampson/media/naive-monitoring/drift.svg"
        width="600" height="100"
        alt="input drift leads to increasing error">
</div>

Periodic checking can help address this "drifting input" scenario. But for me, it's hard to imagine many situations where drift seems like the dominant kind of input variation. Perhaps web search, where query terms slowly change with cultural trends? And there's an epistemological challenge if you plan to evaluate a naive monitoring strategy experimentally: you want to measure your algorithm's ability to adapt to unpredictable shifts in behavior, but to do an evaluation, you need to predict behavior. **A convincing evaluation of naive monitoring would need to use historical data to reflect drifting inputs.** Generating convincingly "unpredictable" data synthetically seems difficult.

## We Can Do Better

Monitoring the output error of approximate programs is an important research challenge. The community should develop strategies and systems that address the shortcomings of profiling. But naive monitoring is not a satisfying solution.

If I were to write a paper about a new approximation technique, I would avoid including any mechanism at all for error monitoring. Including yet another reinvention of naive monitoring is worse, in my view, than no monitoring at all, and an exciting new approach deserves its own paper. Instead, I would cite cite other papers that struggle with the same issue---we're all in this together.
