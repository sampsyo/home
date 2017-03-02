---
title: Statistical Mistakes and How to Avoid Them
mathjax: true
excerpt: |
    You can get CS papers published with shoddy statistics, but that doesn't mean you should. Here are three easy ways to bungle the data analysis in your evaluation section: don't even try to use statistics when you really ought to; misinterpret an inconclusive statistical test as concluding a negative; or run too many tests without considering that some of them might be lying to you. I've seen all three of these mistakes in multiple published papers---don't let this be you!
---

Computer scientists in systemsy fields, myself included, aren't great at using statistics. Maybe it's because there are so many other potential problems with empirical evaluations that solid statistical reasoning doesn't seem that important. Other subfields, like HCI and machine learning, have much higher standards for data analysis. Let's learn from their example.

Here are three kinds of avoidable statistics mistakes that I notice in published papers.

### No Statistics at All

The most common blunder is not using statistics at all when your paper clearly uses statistical data. If your paper uses the phrase "we report the average time over 20 runs of the algorithm," for example, you should probably use statistics.

Here are two easy things that every paper should do when it deals with performance data or anything else that can randomly vary:

First, plot the error bars. In every figure that represents an average, compute the [standard error of the mean][stderr] or just the plain old standard deviation and add little whiskers to each bar. Explain what the error bars mean in the caption.

<img src="{{ site.base }}/media/errorbars.svg" alt="(a) Just noise. (b) Meaningful results. (c) Who knows???" class="img-responsive" style="width: 100%;">

Second, do a simple statistical test. If you ever say "our system's average running time is X seconds, which is less than the baseline running time of Y seconds," you need show that the difference is [statistically significant][statsig]. Statistical significance tells the reader that the difference you found was more than just "in the noise."

[statsig]: https://en.wikipedia.org/wiki/Statistical_significance

For most CS papers I read, a really basic test will work: [Student's $t$-test][ttest] checks that two averages that look different actually are different. The process is easy. Collect some $N$ samples from the two conditions, compute the mean $\overline{X}$ and the standard deviation $s$ for each, and plug them into this formula:

\\[
t =
\frac{ \overline{X}_1 - \overline{X}_2 }
{ \sqrt{ \frac{s_1^2}{N_1} +
  \frac{s_2^2}{N_2} } }
\\]

then plug that $t$ into [the cumulative distribution function of the $t$-distribution][tdist] to get a $p$-value. If your $p$-value is below a threshold $\alpha$ that you chose ahead of time (0.05 or 0.01, say), then you have a statistically significant difference. Your favorite numerical library probably already has [an implementation][ttest-numpy] that does all the work for you.

[tdist]: https://en.m.wikipedia.org/wiki/Student%27s_t-distribution
[ttest]: http://vassarstats.net/textbook/ch11pt1.html
[ttest-numpy]: http://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.ttest_ind.html

If you've taken even an intro stats course, you know all this already! But you might be surprised to learn how many computer scientists don't. Program committees don't require that papers use solid statistics, so the literature is full of statistics-free but otherwise-good papers, so standards remain low, and Prof. Ouroboros keeps drawing figures without error bars. Other fields are [moving *beyond* the $p$-value][pvalueban], and CS isn't even there yet.

[pvalueban]: http://www.nature.com/news/psychology-journal-bans-p-values-1.17001

### Failure to Reject = Confirmation

When you do use a statistical test in a paper, you need to interpret its results correctly. When your test produces a $p$-value, here are the correct interpretations:

* If $p < \alpha$: The difference between our average running time and the baseline's average running time is statistically significant. Pedantically, we *reject the null hypothesis* that says that the averages might be the same.
* Otherwise, if $p \ge \alpha$: We conclude nothing at all. Pedantically, we *fail to reject* that null hypothesis.

It's tempting to think, when $p \ge \alpha$, that you've found the opposite thing from the $p < \alpha$ case: that you get to conclude that there is *no statistically significant difference* between the two averages. Don't do that!

Simple statistical tests like the $t$-test only tell you when averages are different; they can't tell you when they're the same. When they fail to find a difference, there are two possible explanations: either there is no difference or you haven't collected enough data yet. So when a test fails, it could be your fault: if you had run a slightly larger experiment with a slightly larger $N$, the test might have successfully found the difference. It's always wrong to conclude that the difference does not exist.

If you want to claim that two means are *equal*, you'll need to use a different test where the null hypothesis says that they differ by at least a certain amount. For example, an appropriate [one-tailed $t$-test][ttest] will do.

[ttest]: http://stattrek.com/hypothesis-test/difference-in-means.aspx?Tutorial=AP
[stderr]: https://www.r-bloggers.com/standard-deviation-vs-standard-error/

### The Multiple Comparisons Problem

In most ordinary evaluation sections, it's probably enough to use only a handful of statistical tests to draw one or two bottom-line conclusions. But you might find yourself automatically running an unbounded number of comparisons. Perhaps you have $n$ benchmarks, and you want to compare the running time *on each one* to a corresponding baseline with a separate statistical test. Or maybe your system works in a feedback loop: it tries one strategy, performs a statistical test to check whether the strategy worked, and starts over with a new strategy otherwise.

Repeated statistical tests can get you into trouble. The problem is that every statistical test has a probability of lying to you. The probability that any *single* test is wrong is small, but if you do lots of test, the probability amplifies quickly.

For example, say you choose $\alpha = 0.05$ and run one $t$-test. When the test succeeds---when it finds a significant difference---it's telling you that if the test groups were actually equivalent you'd still see this difference 5% of the time by dumb luck. If this difference actually doesn't exist despite you measuring it, you're in 5 out of 100 parallel universes where you just got unlucky.

Existing in these unlucky universes isn't likely on any given test.  But do enough tests, and chances are good that for a handful of them you'll be unlucky.  Here's an intuitive example: suppose you built a machine that counted neutrinos from the sun and compared them to yesterday's measurements.  Every day it tested whether the neutrino-level dropped (and thus the sun had exploded) at the $\alpha = 0.05$ level.  After a few dozen days of testing you wake up and it alerts you the sun has exploded, do you panic? [xkcd]

Now, say you run a series of $n$ tests in the scope of one paper. Even if there's no real difference between groups, there's an $\alpha$ chance of getting unlucky and seeing one. The chances that your paper has more than $k$ errors in it is given by the binomial distribution:

\\[
1 - \sum_{i=0}^{k} {n \choose i} \alpha^i (1-\alpha)^{n-i}
\\]

which grows exponentially with the number of tests, $n$. If you use just 10 tests with $\alpha = 0.05$, for example, your chance of having one test go wrong grows to 40%. If you do 100, the probability is above 99%. At that point, it's a near certainty that your paper is misreporting some result.

(To compute these probabilities yourself, set $k = 0$ so you get the chance of at least one error. Then the CDF above simplifies down to $1 - (1 - \alpha) ^ n$.)

This pitfall is called the [multiple comparisons problem][mcp]. If you really need to run lots of tests, all is not lost: there are standard ways to compensate for the increased chance of error. The simplest are the [Bonferroni][bonferroni] and [Šidák][sidak] corrections, where you reduce your per-test $\alpha$ to $\frac{\alpha}{n}$ to preserve an overall $\alpha$ chance of going wrong.  A less stringent method involves controling for the False Discovery Rate [fdr].

[bonferroni]: http://mathworld.wolfram.com/BonferroniCorrection.html
[mcp]: https://en.wikipedia.org/wiki/Multiple_comparisons_problem
[sidak]: https://en.m.wikipedia.org/wiki/Šidák_correction
[xkcd]: https://xkcd.com/1132/
[fdr]: https://en.wikipedia.org/wiki/False_discovery_rate
