---
title: Closed Problems in Approximate Computing
mathjax: true
excerpt: |
    I’m giving a talk at the [NOPE](http://nope.pub) workshop about impossible problems in approximate computing. Here are some research directions that are no longer worth pursuing—and a few that are.
---
<aside>
  These are notes for a <a href="{{site.base}}/media/closedproblems-nope2017-slides.pdf">talk</a> I will give at the <a href="http://nope.pub">NOPE</a> workshop at MICRO 2017, where the title is <i>Approximate Computing Is Dead; Long Live Approximate Computing</i>.
</aside>

[Approximate computing][approx] has reached an adolescent phase as a research area. We have picked bushels of low-hanging fruit. While there are many approximation papers left to write, it's a good time to enumerate the closed problems: research problems that are probably no longer worth pursuing.

[approx]: {{site.base}}/research.html#approximate-computing

## Closed Problems in Approximate Hardware

**No more approximate functional units.**
Especially for people who love VLSI work, a natural first step in approximate computing is to design approximate adders, multipliers, and other basic functional units. Cut a carry chain here, drop a block of intermediate results there, or use an automated search to find “unnecessary” gates---there are lots of ways to design an FU that’s mostly right most of the time. Despite dozens of papers in this vein, however, the gains seem to range from minimal to nonexistent. A lovely [DATE 2017 paper by Barrois et al.][barrois] recently studied some of these approximate FUs and found that:

> existing approximate adders and multipliers tend to be dominated by truncated or rounded fixed-point ones.

In other words, plain old fixed-point FUs with a narrower bit width are usually at least as good as fancy “approximate” FUs. The problem is that, if you’re approximating the values below a given bit position, it’s usually not worth it to compute those approximate bits at all. In fact, by dropping the approximate bits altogether, you can exploit the smaller data size for broader advantages in the whole application. Software using approximate adders and multipliers, on the other hand, ends up copying around and operating on worthless, incorrect trailing bits for no benefit in precision.

This paper has raised the bar for FU-level approximation research. (Thanks, by the way, to [Andreas Gerstlauer][andreas], who pointed me toward this paper.) We should no longer publish VLSI papers that measure approximate adders in isolation. Without a radically different approach, we should stop designing approximate functional units altogether.

[barrois]: https://hal.inria.fr/hal-01423147
[andreas]: http://users.ece.utexas.edu/~gerstl/

**No more voltage overscaling.**
For some, *approximate computing* is a synonym for *voltage overscaling*. Voltage overscaling is when you turn up the clock rate or turn down $V_{\text{DD}}$ beyond their safe ranges and allow occasional timing errors. I accept some of the blame for solidifying voltage overscaling’s outsized mindshare by co-authoring [a paper about “architecture support for approximate computing”][truffle] that exclusively used voltage as its error--energy knob.

[truffle]: {{site.base}}/media/papers/truffle-asplos2012.pdf

The problem with voltage overscaling is that it’s nearly impossible to evaluate. It’s easy to model its effects on energy and frequency, but the pattern of timing errors depends on a chip’s design, synthesis, layout, manufacturing process, and even environmental conditions such as temperature. Even a halfway-decent error analysis for voltage overscaling requires a full circuit simulator. To account for process variation, we’d need to tape out real silicon at scale. In a frustrating Catch-22 of research evaluation, it’s hard to muster the enthusiasm for a tapeout before we can prove that the results are likely to be good.

There is even a credible argument that the results are likely to be bad. In voltage overscaling, the circuit’s critical path fails first. And in many circuits, the longest paths in the design contribute the most to the output accuracy. In a functional unit, for example, the most significant output bits usually arise from the longest paths. So instead of a smooth degradation in accuracy as the voltage decreases, these circuits are likely to fall off a steep accuracy cliff when the critical path first fails to meet timing.

Research should stop using voltage overscaling as the “default” approximate computing technique. In fact, we should stop using it altogether until we have evidence *in silica* that the technique’s voltage--error trade-offs are favorable.

**In general, no more fine-grained approximate operations.**
Approximate functional units and voltage overscaling are both instances of *operation-level* approximation techniques. They reduce the cost of individual operations like multiplies or adds, but they do not change the computation’s higher-level structure. All of these [fine-grained techniques][taxonomy] have to contend with [the Horowitz imbalance][horowitz], to coin a phrase: the huge discrepancy between the cost of processor control with respect to “real work.” Even if an FU operation were free, the benefit would be irrelevant compared to the cost of fetching, decoding, and scheduling the instruction that invoked it. These fine-grained approximation strategies are no longer worth pursuing on their own.

[taxonomy]: http://ieeexplore.ieee.org/document/8054698/
[horowitz]: http://ieeexplore.ieee.org/document/6757323/

### Instead…

If we have any hope of making hardware approximation useful, we will need to start by addressing control overhead. Research that reduces non-computational processing costs works as a benefit multiplier for approximate computing. Approximate operations in [CGRA-like spatial architectures][chlorophyll] or [explicit dataflow processors][nowatzki-seed], for example, have a chance of succeeding where they would fail in a CPU or GPU context. We have work to do to integrate approximation into the [constraint-based][chlorophyll] [techniques][nowatzki-pldi] that these accelerators use for configuration.

[nowatzki-seed]: https://dl.acm.org/citation.cfm?id=2750380
[nowatzki-pldi]: https://dl.acm.org/citation.cfm?id=2462163
[chlorophyll]: https://dl.acm.org/citation.cfm?id=2594339

## Closed Problems in Approximate Programming Models

**No more automatic approximability analysis.**
Papers in programming languages sometimes try to automatically determine which variables and operations in an unannotated program require perfect precision and which are amenable to approximation. The idea is—sometimes explicitly—to alleviate [EnerJ][]'s annotation burden (which can be high, I admit).

[enerj]: {{site.base}}/media/papers/enerj-pldi2011.pdf

This is not a good goal. Imagine a world where your compiler is free to make its own decisions about which parts of your program are really important and which can be exposed to errors. No one wants this compiler.

“But wait,” the compiler might protest. “I can demonstrate that approximating those variables has only a tiny impact on your quality metric in this broad set of test inputs!”

That’s very useful to know, compiler, but it’s not strong enough evidence to justify breaking a program without the developer’s express consent. Without a guarantee that the test inputs perfectly represent real run-time conditions, silent failures in the field are a real possibility. And quality metrics are only a loose reflection of real-world utility, so basing automatic decisions on them is deeply concerning.

Work that makes EnerJ annotations implicit misunderstands EnerJ’s intent. We designed EnerJ *in response* to earlier work that applied approximation without developer involvement. The explicit annotation style acts as a check on the compiler’s freedom to break your code. The time has passed for research that places the power back into the compiler’s grubby hands.

**No more generic unsound compiler transformation.**
I love [loop perforation][loopperf] and the devil-may-care attitude that its paper represents. I hope its inventors won’t be angry if I say loop perforation is the world’s dumbest approximate programming technique: it works by finding a loop and changing its counter increment expression, `i++`, to `i += 2` or `i += 3`. The shocking thing about loop perforation is that it sometimes works: some loops can survive the removal of some of their iterations.

[loopperf]: https://people.csail.mit.edu/stelios/papers/fse11.pdf

Loop perforation is surprisingly hard to beat. Using it as an inspiration, you can imagine endless compiler-driven schemes for creatively transforming programs that, while totally unsound, will work some of the time. In my anecdotal experience, however, few techniques can dominate loop perforation on an efficiency–accuracy Pareto frontier. Some transformations do somewhat better some of the time, but I have never seen a dramatic, broad improvement.

It’s time to stop looking. While it can be fun to cook up novel unsound compiler transformations, we do not need any more papers in this vein.

### Instead…

More researchers in our community should favor tool design over language constructs and program analysis. For example, we need practical operating system support for balancing resource contention with approximate computing. [Especially in datacenters][kulkarni-wax], applications should be able to negotiate with the OS to reduce their output quality in exchange for bandwidth or latency. An approximation-aware resource scheduler does not depend on novel hardware or compiler techniques: many applications have built-in quality parameters that can compete with resource consumption. Research prototypes probably won’t cut it for this kind of work; real-world system implementations, on the other hand, might be ripe for adoption.

[kulkarni-wax]: http://approximate.computer/wax2017/papers/kulkarni.pdf

## Closed Problems in Quality Enforcement

**No more weak statistical guarantees.**
To control output quality degradation in approximate computing, one promising approach is to offer a *statistical guarantee*. When an approximation technique leads to good quality in most cases but poor quality in rare cases, traditional compile-time guarantees can be unhelpful. A statistical guarantee, on the other hand, can bound the *probability* of seeing a bad output. A statistical guarantee might certify, for example, that the probability of observing output error $E$ above a threshold $T$ is at most $P$.

Too many papers that strive to check statistical correctness end up offering [extremely weak guarantees][probablycorrect]. The problem is that even fancy-sounding statistical machinery rests on the dubious assumption that we can predict the probability distribution that programs will encounter at run time. We assume that an input follows a Gaussian distribution, or that it’s uniformly distributed in some range, or that it is drawn from a known body of example images. For an input randomly selected from this given input distribution, we can make a strong guarantee about the probability of observing a high-quality output.

[probablycorrect]: {{site.base}}/blog/probablycorrect.html

When real-world inputs inevitably follow some other distribution, however, all bets are off. Imagine a degenerate distribution that finds the worst possible input for your approximate program, in terms of output quality, and presents that value with probability 1.0. An *adversarial input distribution* can break any quality enforcement technique that relies on stress-testing a program pre-deployment. Even ignoring adversarial conditions, it’s extremely hard to defend the assumption that in-deployment inputs for a program will *exactly* match the distribution that the programmer modeled in development. Run-time input distributions are inherently unpredictable, and they render development-time statistical guarantees useless.

### Instead…

We need more research on run-time enforcement that directly addresses the problem of unpredictable input distributions. Consider SaaS applications based on machine learning, for example: [Wit.ai][] for natural language understanding or [Rekognition][] for computer vision, for example. All ML models have an error rate, meaning that some customers’ workloads will observe higher accuracy than others. Given this subjective variation in output accuracy, what strong statements can cloud providers make to their customers about precision? And if a service advertises a quality guarantee, how can customers keep the provider honest without recomputing everything themselves? These narrower questions may be tractable where the fully general problem of statistical guarantees is not.

[wit.ai]: https://wit.ai
[rekognition]: https://aws.amazon.com/rekognition/

## Closed Domains for Approximation

**No more sadness about the imperfection of quality metrics.**
All approximate computing research depends on application-specific output quality metrics, and these quality metrics are far from perfect. Researchers make a good-faith effort to capture meaningful properties in each program’s output, but we have no real assurances that any metric is reasonable. Even worse, we often need to fix an arbitrary threshold on quality to call an output “good enough.” These thresholds rarely have any bearing on any deployment scenario, real or imagined. A *de facto* standard threshold of 10% error has emerged, which is both a triumph in consistency and a tragedy in real-world relevance.

Arbitrary thresholds and researcher-invented quality metrics are worth griping about, but most of what needs to be said about this sorry state of affairs has already been said. The system is not perfect, but PARSEC is not a perfect representation of all parallel computation workloads; Gem5 is not a perfect model of real CPUs; and geometric mean speedup is not a perfect proxy for utility. No standard evaluation strategy is without flaws. We should constantly work to develop better quality metrics and to understand thresholds that actually matter to users, but it is no longer useful to complain about the basic system of quality metrics and thresholds.

**No more benchmark-oriented research?**
More worrisome than quality metrics themselves is the fact that we need to invent quality metrics at all. Our current evaluation standards are a symptom of a *benchmark-oriented* approach to approximate computing research. It follows the basic strategy forged by classic architecture and compiler research: develop a new gadget and measure its impact on figures of merit for a broad class of off-the-shelf benchmarks from as many domains as possible. The point is to claim generality: to show that an idea advances the capabilities of *computers in general*, and that it’s not just an optimization for one person’s code.

This commitment to generality is the root cause of approximate computing’s messy evaluation norms. When a research project needs to demonstrate benefits for seven different domains, its researchers don’t have time to deeply engage with any single domain. A benchmark-driven attitude leads directly to invented quality metrics, arbitrary thresholds, and minimal involvement from domain experts. To break free from the traditional trappings of approximate computing work, we need to break free from benchmark suites.

### Instead…

Instead of bringing approximation to every domain we can think of, let’s look for domains that already embrace approximation. In the PARSEC benchmarks, approximate computing is optional. There are real, important applications where [approximation is compulsory][compulsory] because perfection is unachievable. In these domains, we don’t have to invent quality metrics: researchers in the domain already have a consensus on what makes one system better than another.

[compulsory]: http://approximate.computer/wax2016/papers/sampson.pdf

Approximation is compulsory in AI domains like vision, natural language understanding, and speech recognition, for example, so these fields already have established methodologies for measuring accuracy. These established metrics, like word error rate for speech recognition or mean average precision for object detection, are certainly not perfect, but their flaws are intimately understood by ML and AI researchers. Real-time 3D rendering is another example: approximations abound in the effort to draw a subjectively beautiful scene at a high frame rate.

Approximate computing researchers should embed with these domains. Instead of trying to foist a new framework for approximate execution onto domain experts, we can learn something from how they currently manage their compulsory approximation. Following the approximation rules for an established domain will be hard work: any new approximation technique will need to beat the Pareto frontier established by conventional techniques. And it’s impossible to manipulate the quality metric to make your proposal look better. But no one said research was supposed to be easy.
