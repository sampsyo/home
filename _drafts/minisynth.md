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

There are even logical quantifiers:

    z = z3.Int('z')
    n = z3.Int('n')
    print(solve(z3.ForAll([z], z * n == z)))

Truly, Z3 is amazing.
But we're not quite at program synthesis.


## Sketching

In the [Sketch][] spirit, we'll start by synthesizing *holes* to make programs equivalent.
Here's the scenario: you have a slow version of a program you're happy with; that's your specification.
You can *sort of* imagine how to write a faster version, but a few of the hard parts elude you.
The synthesis engine's job will be fill in those details so that the two programs are equivalent on every input.

Take [Aws's little example][primer]:
you have the "slow" expression `x * 2?`, and you know that there's a "faster" version to be had that can be written `x << ??` for some value of `??`.
[Let's ask Z3][ex1] what to write there:

    x = z3.BitVec('x', 8)
    slow_expr = x * 2
    h = z3.BitVec('h', 8)  # The hole, a.k.a. ??
    fast_expr = x << h
    goal = z3.ForAll([x], slow_expr == fast_expr)
    print(solve(goal))

Nice! We get the model `[h = 1]`, which tells us that the two programs produce the same result for every byte `x` when we left-shift by 1.
That's (a very simple case of) synthesis: we've generated a (subexpression of a) program that meets our specification.
Without a proper programming language, however, it doesn't feel much like generating programs---we'll fix that next.

[sketch]: https://people.csail.mit.edu/asolar/papers/thesis.pdf
[ex1]: https://github.com/sampsyo/minisynth/blob/master/ex1.py


## A Tiny Language

Let's [conjure a programming language][ex2].
We'll need a parser; I choose [Lark][].
Here's my Lark grammar for a little language of arithmetic expressions, which I ripped off from the [Lark examples][calc] and which I offer to you now for no charge:

    GRAMMAR = """
    ?start: sum

    ?sum: term
      | sum "+" term        -> add
      | sum "-" term        -> sub

    ?term: item
      | term "*"  item      -> mul
      | term "/"  item      -> div
      | term ">>" item      -> shr
      | term "<<" item      -> shl

    ?item: NUMBER           -> num
      | "-" item            -> neg
      | CNAME               -> var
      | "(" start ")"

    %import common.NUMBER
    %import common.WS
    %import common.CNAME
    %ignore WS
    """.strip()

You can write arithmetic and shift operations on literal numbers and variables. And there are parentheses!
Lark parsers are easy to use:

    import lark
    parser = lark.Lark(GRAMMAR)
    tree = parser.parse("(5 * (3 << x)) + y - 1")

As for any good language, you'll want an interpreter.
[Here's one][ex2] that processes Lark parse trees and takes a function in as an argument to look up variables by their names:

    def interp(tree, lookup):
        op = tree.data
        if op in ('add', 'sub', 'mul', 'div', 'shl', 'shr'):
            lhs = interp(tree.children[0], lookup)
            rhs = interp(tree.children[1], lookup)
            if op == 'add':
                return lhs + rhs
            elif op == 'sub':
                return lhs - rhs
            elif op == 'mul':
                return lhs * rhs
            elif op == 'div':
                return lhs / rhs
            elif op == 'shl':
                return lhs << rhs
            elif op == 'shr':
                return lhs >> rhs
        elif op == 'neg':
            sub = interp(tree.children[0], lookup)
            return -sub
        elif op == 'num':
            return int(tree.children[0])
        elif op == 'var':
            return lookup(tree.children[0])

As everybody already knows from their time in [CS 6110][], your interpreter is just an embodiment of your language's big-step operational semantics.
It works:

    env = {'x': 2, 'y': -17}
    answer = interp(tree, lambda v: env[v])

Nifty, but there's no magic here yet.
Let's add the magic.

[calc]: https://github.com/lark-parser/lark/blob/master/examples/calc.py
[ex2]: https://github.com/sampsyo/minisynth/blob/master/ex2.py
[lark]: https://github.com/lark-parser/lark
[cs 6110]: http://www.cs.cornell.edu/courses/cs6110/2018sp/


## From Interpreter to Constraint Generator

The key ingredient we'll need is a *translation* from our source programs into Z3 constraint systems.
Instead of computing actual numbers, we want to produce equivalent formulas.
For this, Z3's operator overloading is the raddest thing:

    formula = interp(tree, lambda v: z3.BitVec(v, 8))

Incredibly, we get to reuse our interpreter as a constraint generator by just swapping out the variable-lookup function.
Every `+` becomes a plus-constraint-generator; every variable becomes a Z3 bit vector; etc.
In general, we'd want to convince ourselves of the *adequacy* of our translation, but reusing our interpreter code makes this particularly easy to believe.
This similarity between interpreters and synthesizers is a big deal: it's an insight that [Emina Torlak][emina]'s [Rosette][] exploits with great aplomb.

[rosette]: https://emina.github.io/rosette/
[emina]: https://homes.cs.washington.edu/~emina/index.html


## Finishing Synthesis

With formulas in hand, we're almost there.
Remember that we want to synthesize values for holes to make two programs equivalent, so
we'll need two Z3 expressions that share variables.
I wrapped up an enhanced version of the constraint generator above in a function that also produces the variables involved:

    expr1, vars1 = z3_expr(tree1)
    expr2, vars2 = z3_expr(tree2, vars1)

And here's my hack for allowing holes without changing the grammar: any variable name that stars with an "H" is a hole.
So we can filter out the plain, non-hole variables:

    plain_vars = {k: v for k, v in vars1.items()
                  if not k.startswith('h')}

All we need now is a quantifier over equality:

    goal = z3.ForAll(
        list(plain_vars.values()),  # For every valuation of variables...
        expr1 == expr2,  # ...the two expressions produce equal results.
    )

Running `solve(goal)` gets a valuation for each hole.
In [my complete example][ex2], I've added some scaffolding to load programs from files and to pretty-print the expression with the holes substituted for their values.
It expects two programs, the spec and the hole-ridden sketch, on two lines:

    $ cat sketches/s2.txt
    x * 10
    x << h1 + x << h2

It absolutely works:

    $ python3 ex2.py < sketches/s2.txt
    x * 10
    (x << 3) + (x << 1)


## Keep Synthesizing

- Rosette is about doing this for you
