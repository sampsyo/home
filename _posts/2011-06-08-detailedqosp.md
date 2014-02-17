---
title: "A Detailed Quality-of-Service Profiler"
kind: article
layout: post
ignore: _x
excerpt: |
    For my [CSE
    503](http://www.cs.washington.edu/education/courses/cse503/11sp/) class
    project, I implemented a *detailed quality-of-service profiler*, a tool to
    help identify code that is inessential for output correctness. The tool is
    an extension to [work at MIT](http://portal.acm.org/citation.cfm?id=1806808)
    that originally proposed a quality-of-service profiler; this project is a
    slightly different take on the same basic idea.
---
In many applications, the notion of "correctness" is not binary---the quality of
a program's output is on a continuum from *useless* to *ideal*. Such
applications typically make trade-offs between computational resources, such as
performance or energy consumption, and quality of service. For example, an
audio encoder can typically produce low-quality sound quickly or, when more
resources are available, high-quality sound slowly. In this sense, the
application makes a *trade-off* between output quality and performance.

To explore this trade-off space, programmers need tools to help them understand
how code relates to quality of service. While intuition can sometimes help
distinguish crucial from inessential code, the importance of any given
code passage is not necessarily apparent statically; tools can help develop this
understanding.

In a paper titled *Quality of Service Profiling*, Misailovic et al.
([ICSE 2010][mit])
propose a tool for identifying parts of a program that have only a small
influence on output quality. The proposed tool is analogous to a performance
profiler: while a traditional profiler identifies code that is responsible for 
large portions of the program's runtime, a quality-of-service profiler (QoSP)
identifies code that has a small impact on output quality. Both
tools---especially when used together---identify possible targets for
optimization. By identifying portions of code that do not greatly influence the
output of a program, the programmer can remove unnecessary or redundant work
without compromising much quality.

[mit]: http://portal.acm.org/citation.cfm?id=1806808

The Misailovic paper describes the design of one QoSP based on [loop
perforation][perf]: the tool transforms programs by skipping iterations from the
program's hot loops. The tool then measures the resulting degradation in QoS and
reports loops to the programmer that, when perforated, lead to a small QoS
degradation.

[perf]: http://groups.csail.mit.edu/cag/codeperf/

In this project, I built a tool that emulates the basic workflow of the
Misailovic QoSP but applies different, more fine-grained program
transformations. Rather than degrading whole loops, I propose to modify the
program at the level of individual expressions (variable reads, variable writes,
and binary operations). The purpose of the project is twofold:

* First, it was instructive to perform a partial replication of the Misailovic
  QoSP paper. Implementing their idea helped me to understand the utility
  of the general QoSP technique.
* Additionally, the project represents an incremental expansion of the QoSP
  idea, applying the same overall technique with a very different basic
  mechanism. This allowed me to explore the *generality* of QoSP: how well does
  the framework scale to encompass variations on the theme?

Below, I'll discuss the design and implementation of a "detailed"
quality-of-service profiler, give a quantitative characterization of its
performance on three
benchmark programs from the EnerJ paper, and then discuss
my experience with the tool qualitatively.


## Design

Misailovic's QoSP is an instance of the following basic workflow:

1. Take as input a program and an associated automated quality-of-service
   metric.
2. Apply an unsound program transformation to generate a degraded version of the
   input program. Repeat to generate many such degraded programs, each of which
   is transformed at a different point in the code. (In the Misailovic QoSP, the
   particular transformation is loop perforation.)
3. Run each degraded program on test inputs and measure the resulting output
   quality.
4. Find the degraded programs that resulted in the best output quality.
   Report to the programmer the portions of code that were transformed in those
   degraded programs.

In this project, I instantiate this workflow with a very different program
transformation: I degrade programs by replacing (a) variable, field, and array
reads; (b) variable, field, and array writes; and (c) binary arithmetic
operations.

Aside from being instructive as a partial replication of the original
Misailovic QoSP project, I think this extension is worthwhile because it
explores a fundamentally different way of searching for unnecessary precision.
Whereas loop perforation is a *coarse* and *code-centric* transformation that
addresses the program logic, this "detailed" QoSP uses a *fine-grained* and
*data-centric* error injection strategy.

There are far more variable read/writes and arithmetic operations in a given
program than there are loops, so the search space for degradations is much
larger and more pervasive. This makes life somewhat more difficult for this
detailed QoSP, because much more work is required to fully explore the search
space, but it also makes it possible to find "over-precision" in many more parts
of the program.


## Implementation

The detailed QoSP is implemented mainly as a source-to-source transformation for
the Java programming language. Specifically, I reused a source-to-source
instrumentation framework I wrote for my recently-completed EnerJ project
([PLDI 2011][enerj]), which I'm currently polishing off as a research tool for
general instrumentation work.

The instrumentation runs as a compiler pass. It produces a Java program that,
for
every load/store and arithmetic operation, calls into a runtime library instead
of performing the operation directly. (Note that instrumenting *all* operations
in a *single* instrumentation pass avoids the overhead of repeatedly recompiling
the program, but it does incur greater runtime overhead per execution.)
Then, during
successive profiling runs, errors are injected into each expression in turn (one
static expression is made faulty per run).

The particular error that is injected depends on the type of the expression.

* Booleans are logically inverted.
* Integers and floats are multiplied by 10. (The idea here is to make the number
  "wrong" but not to choose any arbitrary, fixed value that could cause
  pathological behavior.)
* References are changed to `null`.

[enerj]: http://sampa.cs.washington.edu/sampa/EnerJ

The overall workflow outlined in the previous section is implemented in a simple
Python script. To evaluate a program, the user must implement three small
functions:

1. One function compiles the program with instrumentation.
2. Another function executes the program and collects its output (i.e., it reads
   from the program's standard output).
3. A final function encapsulates the application's *quality-of-service metric*.
   It takes the program output as input and produces a number between 0 and 1
   reflecting the amount of error (loosely defined) in that output. An error
   score of 0 indicates output identical to the original program; 1 indicates
   nonexistent or useless output.

The first two functions are generally straightforward scripts. The QoS metric is
somewhat more intensive and requires careful thought to obtain useful results.
Ad-hoc, application-specific QoS metrics are a fact of life in this setting;
the user's expectations for output quality cannot be inferred from the program's
code. Reducing the burden of writing QoS metrics for this kind of system is an
interesting avenue for future research.

The output of the profiler is a ranked list of code points (source file and
character position) corresponding to error-tolerant expressions.


## Evaluation

To gain experience with the detailed QoSP, I profiled three kernels. The
programs were also used in the [evaluation of EnerJ][enerj], a previous project
of mine; as a result, it's important to note that these programs were selected
for their potential to be tolerant to error---the sort of application where a
QoSP is likely to be useful. The [EnerJ paper][enerj] has more details on the
applications.

* *jME:* an extract from the [jMonkeyEngine][jme] game engine that performs
  3D trial intersection for collision detection. The workload consists of 100
  randomly generated intersection problems, the output of which is 1
  (intersection) or 0 (disjoint). The QoS metric is the proportion of correct
  answers.
* *Raytracer:* a [very simple raytracer][raytracer] that draws a simple, fixed
  scene. The output consists of a grid of RGB pixels; the QoS metric is the
  normalized root mean squared error (RMSE) of each pixel component.
* *LU:* a kernel from the [SciMark2 benchmark suite][scimark]; performs LU
  matrix factorization on a small randomly-generated dense matrix of floats.
  The QoS metric is the RMSE of the output matrix's entries.

[jme]: http://www.jmonkeyengine.com/
[raytracer]: http://www.planet-source-code.com/vb/scripts/ShowCode.asp?txtCodeId=5590&lngWId=2
[scimark]: http://math.nist.gov/scimark2/

In the rest of this section, I'll give some quantitative measurements regarding
the tool's behavior and then discuss several observations about the QoSP and its
output.

### Statistics

Here are some basic statistics that reflect the tool's execution on the three
benchmarks. Here, I'll use "points" to refer to instrumented code points
(possible fault injection sites): variable reads, variable writes, and binary
arithmetic operations.

<table>
    <tr>
        <th>Benchmark</th>
        <th>Total points</th>
        <th>Live points</th>
        <th>Ranked points</th>
        <th>Zero-error points</th>
    </tr>
    <tr>
        <td>jME</td>
        <td>752</td>
        <td>359</td>
        <td>60</td>
        <td>13</td>
    </tr>
    <tr>
        <td>Raytracer</td>
        <td>255</td>
        <td>209</td>
        <td>83</td>
        <td>76</td>
    </tr>
    <tr>
        <td>LU</td>
        <td>915</td>
        <td>531</td>
        <td>262</td>
        <td>112</td>
    </tr>
</table>

*Total points* indicates the number of code points that were instrumented. *Live
points* are those that are executed at least once in my tests (unexecuted
points are called *dead*). *Ranked points* are those whose associated error was
less than 100% (i.e., fault injection at that point did not cause a catastrophic
error). These points make up the set of points that are actually reported by the
QoSP. *Zero-error* points are those for which error injection led to output
that was identical to the uninstrumented execution. Note that each column in
the above table represents a subset of the previous column.

### Liveness

The detection of *live* points was added after I found that many, many runs
resulted in zero output error. It turned out that most of these points were not
being executed at all, so they didn't have a chance to influence the output. I
modified the tool to filter out *dead* points and relegate them to a separate
report. Dead points, even when optimized, will not help performance, so it's
important to (a) avoid wasting time profiling them and (b) avoid distracting the
programmer with them. A more sophisticated approach could, instead of filtering
out entirely-dead points, rank points based on a linear combination of their
"liveness" (number of times executed) and error-tolerance; the programmer could
thus be guided toward those points that could offer the best accuracy/runtime
trade-off. 

### Noisiness

The tool outputs a *lot* of code points, even for these small kernel
applications. This is partially because a surprisingly large fraction of the
live points in these programs
resulted in non-catastrophic error (17%, 40%, and 49%, respectively). Even when
we restrict our focus to points that resulted in zero error, we are still left
with a large number of code points to inspect (4%, 36%, or 21% of the live
points). The output of the tool is thus somewhat overwhelming; it's hard to know
where to begin interpreting it. A better ranking system, like the one
proposed above, could help with this, but other changes could also help.

Specifically, the tool's output contains a large amount of redundancy. For
example, in jME, an `EPSILON` constant has a negligible impact on the program's
output; six different reads from the variable are reported separately.
Similarly, there are many cases in which a large arithmetic expression is
unimportant; the tool reports every node in the expression's AST separately.
A future iteration of the tool should only report a top-level unimportant
expression once and elide all of its subexpressions.

The output could also be made less overwhelming if it were grouped by code
position. If two expressions on the same line are unimportant, then it would be
helpful to see them side-by-side. Such an organization could help reduce the
number of places in the code that the programmer must inspect.

### Termination

Some fault injections can make a program enter an infinite loop.
In these experiments, I only experienced nontermination in the LU benchmark
(where a loop exit condition was inverted, causing it to remain `false`), and I
dealt with the problem by manually killing the executions that entered infinite
loops. A more complete tool should deal with nontermination more gracefully; a
simple timeout would probably suffice (a very long-running execution that will
eventually terminate is not likely to correspond to a desirable fault
injection).

### Runtime

Perhaps the most obvious drawback to the "detailed" QoSP design is its
performance. There are *lots* of candidate code points for fault injection, even
when only live points are considered. Although the slowdown due to
instrumentation was small in these experiments, each program had to be executed
hundreds of times. The execution count will only get worse with larger (and
longer-running) programs. For this reason, a central concern to making a QoSP
legitimately useful will be to develop heuristics to select and prioritize
the points to test. These heuristics could come, for example, from static
analysis (using a
data flow graph to find operations unlikely to influence the output) or machine
learning (using an [Engler-esque][engler] model trained on source code known to
have unimportant operations).

[engler]: http://www.stanford.edu/~engler/deviant-sosp-01.pdf

Future iterations of a detailed QoSP should also explore the effects of
introducing multiple faults simultaneously. While the current tool could
suggest that
points A and B are independently unimportant---that is, that eliminating either
A or B is not catastrophic---it could be true that eliminating *both* A and B
*would* be catastrophic. Degrading one point at a time will not uncover this
relationship between A and B. I mention this here because this
multi-point space is even larger than the single-point space I evaluated;
pruning heuristics will become even more important when exploring that space.


## Lessons

A detailed quality-of-service profiler is essentially a dynamic analysis for
finding "zombie" code: code that is not quite *dead code* from the point of the
compiler but is unimportant from the perspective of overall application output
quality. It can be used by programmers to identify entirely unnecessary code,
which executes but could be safely removed with no substantial impact. It could
also inform optimizations that trade off perfect behavior for performance in
settings where quality is negotiable. Finally, a detailed QoSP could help the
programmer insert `@Approx` annotations for the [EnerJ][enerj]
approximation-aware programming language. A future evaluation should explore
programmers' ability to use a detailed QoSP for all of these tasks.

A number of challenges must be faced to make a detailed QoSP practically useful:

* Dead code creates noise for the analysis and must be filtered out. In my
  tests, programs had a surprising amount of code that was never executed and
  thus contributed no meaningful information to the analysis.
* A mechanism must be implemented to avoid nontermination in profiling runs.
* The tool must be careful about how it presents points to the programmer.
  According to my experiments, the
  QoSP typically finds a very large set of points with low QoS impact. By
  carefully eliminating redundancy, ranking points, and grouping expressions,
  the output can be made less overwhelming.
* Heuristics are required to identify points for profiling. While the current
  iteration of the tool tests each program mount indiscriminately, using
  heuristics to prune the search space will be essential for scaling the QoSP.
* Relatedly, a detailed QoSP must consider the possibility of interference
  between multiple code points.
* Quality-of-service metrics are not necessarily easy to write. Unlike
  performance, QoSP is an application-specific property; a QoSP tool should make
  it as easy as possible for an application developer to specify a QoS metric.

The QoSP framework proposed by [Misailovic et al.][mit] can generalize
beyond the
particular system presented in that paper. By replacing the fault-injection
mechanism, a new and different tool---here called a "detailed" QoSP---can be
created. However, a detailed QoSP comes with a significant set of challenges
that are absent in coarser approaches.
