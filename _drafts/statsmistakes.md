---
title: Statistics Mistakes Computer Scientists Love to Make
mathjax: true
excerpt: |
    TK
---

Most computer scientists I know don't know too much about statistics. Maybe this is because, historically, the methods of "core CS" fields didn't require any statistical thinking: who needs probabilities, for example, to argue about the design of UNIX or LISP? Machine learning folks are an exception, of course, and so are HCI and other fields that conduct user studies. But the rest of us have something to learn from other sciences where statistical analysis is part of the job.

In a recent deluge of paper reviews, I noticed three data-analysis errors that several otherwise-good papers repeated.

TK transition

### No Statistics at All

The most common blunder is not using statistics at all when your paper clearly has statistical data. If your paper uses the phrase "we report the average time over 20 runs of the algorithm," for example, you probably need some statistics.

Here are two easy things that every paper should do when it deals with performance data or anything else that varies a little bit nondeterministically:

First, plot the error bars. In every figure that represents an average, compute the [standard error of the mean][] or just the plain old [standard deviation][] and add little whiskers to each bar. Explain what the error bars mean in the caption.

<img src="{{ site.base }}/media/errorbars.svg" alt="(a) Just noise. (b) Meaningful results. (c) Who knows???" class="img-responsive" style="width: 100%;">

Second, do a simple statistical test. If you ever say "our system's average running time is X seconds, which is less than the baseline running time of Y seconds," you need show that the difference is [statistically significant][]. Statistical significance tells the reader that the difference you found was more than just "in the noise."

For most CS papers I read, a really basic test will work: [Student's $t$-test][ttest] checks that two averages that look different actually are different. The process is easy. Collect some $N$ samples from the two conditions, compute the mean $\overline{X}$ and the standard deviation $s$ for each, and plug them into this formula:

\\[
t =
\frac{ \overline{X}_1 - \overline{X}_2 }
{ \sqrt{ \frac{s_1^2}{N_1} \; + \;
  \frac{s_2^2}{N_2} } }
\\]

then plug that $t$ into [the cumulative distribution function of the $t$-distribution][tdist] to get a $p$-value. If your $p$-value is below a threshold $\alpha$ you choose ahead of time, like 0.05 or 0.01, you have a statistically significant difference. Your favorite numerical package probably already has [an implementation][ttest-numpy] that does all the work for you.

[tdist]: https://en.m.wikipedia.org/wiki/Student%27s_t-distribution
[ttest]: http://vassarstats.net/textbook/ch11pt1.html
[ttest-numpy]: http://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.ttest_ind.html

If you've taken even an intro stats course, you definitely know all this already! But you might be surprised to know how many computer scientists don't. Program committees don't require that papers use solid statistics, so the literature is full of statistics-free but otherwise-good papers, so standards remain low, and Oroborous keeps drawing figures without error bars. Other fields are [moving *beyond* the $p$-value][], and CS isn't even there yet.

### Failure to Reject = Confirmation

When you do use a statistical test in a paper, it's really important to interpret its results correctly. When your test produces a $p$-value, here are the correct interpretations:

* $p \le \alpha$: The difference between our average running time and the baseline's average running time is statistically significant. Pedantically, we *reject the null hypothesis* that says that the averages might be the same.
* $p > \alpha$: We conclude nothing at all. Pedantically, we *fail to reject* that null hypothesis.

It's tempting to think, when $p > \alpha$, that you've found the opposite thing from the $p \le \alpha$ case: that you get to conclude that there is *no statistically significant difference* between the two averages. Don't do that!

TK check strictness

Simple statistical tests like the $t$-test only tell you when averages are different; they can't tell you when they're the same. When they fail to find a difference, there are two possible explanations: either there is no difference, or you haven't collected enough data yet. So when a test fails, it could be your fault: if you had run a slightly larger experiment with a slightly larger $N$, the test might have successfully found the difference. So it's wrong to conclude that the difference does not exist.

TK statistical power to show lack of a difference

### The Multiple Comparison Problem

In most ordinary evaluation sections, it's probably enough to use only a handful of statistical tests to draw one or two bottom-line conclusions. But you might find yourself automatically running an unbounded number of comparisons. Perhaps you have $n$ benchmarks, and you want to compare the running time *on each one* to a corresponding baseline with a separate statistical test. Or maybe your system works in a feedback loop: it tries one strategy, performs a statistical test to check whether the strategy worked, and starts over with a new strategy otherwise.

If you use a lot of statistical tests, you have extra work to do. The problem is that every statistical test has a probability of lying to you. The probability that any *single* test is wrong is small, but if you do lots of test, the probability amplifies quickly.

For example, say you choose $\alpha = 0.01$ and run a $t$-test. When the test succeeds---when it finds a significant difference--it's telling you that there's at most an $\alpha$ chance that the difference arose from random chance. In 99 out of 100 parallel universes, your paper found a difference that actually exists. I'd take that bet.

But say you run $n$ tests in the scope of one paper. Then every test has an $\alpha$ chance of going wrong. The chances that your paper has at least one error in is given by the binomial distribution:

TK

which grows (TK exponentially?) with the number of tests, $n$. If you do just 10 tests, for example, your chance of lying grows to TK. If you do 100, the probability is TK.

This pitfall is called the [multiple comparison problem][mcp]. There are several ways to address it by tightening your thresholds to compensate for the increased chance of error TK
