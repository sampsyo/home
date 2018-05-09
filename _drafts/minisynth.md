---
title: "Program Synthesis is Possible"
mathjax: true
excerpt:
    TK
---

Program synthesis is not only a hip session title at programming languages conferences; it's also a broadly applicable technique that more people should know about.
But it can seem like magic: automatically generating programs from specifications sounds like the kind of thing that requires a PhD in formal methods.
[Aws Albarghouthi][aws] wrote a wonderful [primer on synthesis][primer] last year that helps demystify the basic techniques, complete with example code.
Here, we'll expand on Aws's primer and build a tiny but complete-ish synthesis engine from scratch.

You can follow along with [my Python code][minisynth] or start from an empty buffer if you like.

[minisynth]: https://github.com/sampsyo/minisynth
[primer]: http://barghouthi.github.io/2017/04/24/synthesis-primer/
[aws]: http://www.cs.wisc.edu/~aws


## Z3 is Amazing

We won't quite start from scratch---we'll start with [Z3][] and its Python bindings.
Z3 is a [satisfiability modulo theories (SMT) solver][smt], which is like a SAT solver with "theories" that let you express constraints involving integers, bit vectors, floating point numbers, and what have you.
We'll use Z3's Python bindings.
On a Mac, you can install the whole thing from [Homebrew][]:

    $ brew install z3 --with-python

Let's [try it out][ex0]:

    import z3

To use Z3, we'll write a logical formula over some variables and then solve them to get a *model*, which is a valuation of the variables that makes the formula true.
Here's a formula, for example:

    formula = (z3.Int('x') / 7 == 6)

The `z3.Int` call introduces a Z3 variable.
Running this line of Python doesn't actually do any division or equality checking; instead, the Z3 library overloads Python's `/` and `==` operators on its variables to produce a proposition.
So `formula` here is a logical proposition of one free integer variable, $x$, that says that $x \div 7 = 6$.

Let's solve `formula`.
We'll use a little function called `solve` to invoke Z3:

    def solve(phi):
        s = z3.Solver()
        s.add(phi)
        s.check()
        return s.model()

Z3's solver interface is much more powerful than what we're doing here, but this is all we'll need to solve a single formula:

    print(solve(formula))

On my machine, I get:

    [x = 43]

which is admittedly a little disappointing, but at least it's true: under integer division, $43 \div 7 = 6$.

[ex0]: https://github.com/sampsyo/minisynth/blob/master/ex0.py
[smt]: https://en.wikipedia.org/wiki/Satisfiability_modulo_theories
[homebrew]: https://brew.sh
[z3]: https://github.com/Z3Prover/z3

Z3 also has a theory of bit vectors, as opposed to unbounded integers, which supports shifting and whatnot:

    y = z3.BitVec('y', 8)
    print(solve(y << 3 == 40))

Truly, Z3 is amazing.
But we're not quite at program synthesis.


## Sketching


## A Tiny Language

[lark]: https://github.com/lark-parser/lark

- write an interpreter. that's the big step
- now write a translator into Z3. it's surprisingly similar---in fact, in Python, it's identical!
- convince yourself of adequacy of the translation


## Keep Synthesizing

- Rosette is about doing this for you
