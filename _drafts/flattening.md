---
title: 'Flattening ASTs (and Other Compiler Data Structures)'
excerpt: |
    TK
---
Arenas, a.k.a. regions, are everywhere in modern language implementations. A special case of the general [arena allocation][arena] idea is both incredibly simple and surprisingly effective for compilers and compiler-like things. Maybe because of its simplicity, I haven't seen the basic technique in many compiler courses---or anywhere else in a CS curriculum for that matter. This post is an introduction to the idea and its many virtues.

*Arenas* and *regions* mean many different things to different people, so I'm going to call the specific flavor I'm interested in here *data structure flattening*. Namely, think of an arena that only holds one type, so it's actually just an array of values of that type, and you can use array indices where you would otherwise need pointers. The type I'll focus on here is abstract syntax tree (AST) nodes, but the idea applies to any pointer-laden data structure.

To learn about flattening, we'll build a basic interpreter twice:
first the normal way and then the flat way.
Follow along with the code [this repository][repo], where you can [compare and contrast the two branches][compare].

[repo]: https://github.com/sampsyo/flatcalc
[compare]: https://github.com/sampsyo/flatcalc/compare/main...flat#diff-42cb6807ad74b3e201c5a7ca98b911c5fa08380e942be6e4ac5807f8377f87fc
[arena]: https://en.wikipedia.org/wiki/Region-based_memory_management

## A Normal AST

Let's start with the "textbook" way to represent an AST. Imagine the world's simplest language of arithmetic expressions, where all you can do is apply the four basic binary arithmetic operators to literal integers. Some "programs" you can write in this language include `42`, `0 + 14 * 3`, and `(100 - 16) / 2`.

Maybe the clearest way to write the AST for this language would be as an ML type declaration:

```ocaml
type binop = Add | Sub | Mul | Div
type expr = Binary of binop * expr * expr
          | Literal of int
```

But for this post, we'll use Rust instead. Here are [the equivalent types in Rust](https://github.com/sampsyo/flatcalc/blob/c5bbe7bd79f98a3b857f0432d4739a3f4f6241bd/src/main.rs#L10-L24):

```rust
enum BinOp { Add, Sub, Mul, Div }
enum Expr {
    Binary(BinOp, Box<Expr>, Box<Expr>),
    Literal(i64),
}
```

If you're not a committed Rustacean, `Box<Expr>` may look a little weird, but that's just Rust for "a plain ol' pointer to an `Expr`." In C, we'd write `Expr*` to mean morally the same thing; in Java or Python or OCaml, it would just be `Expr` because everything is a reference by default.[^inline]

[^inline]: In Rust, using `Expr` there would mean that we want to include other `Expr`s *inline* inside the `Expr` struct, without any pointers, which isn't what we want. The Rust compiler [doesn't even let us do that](https://play.rust-lang.org/?version=stable&mode=debug&edition=2021&gist=83ed9bab8faf7b12707a0f73722ac44c)—it would make `Expr`s infinitely large!

TK illustration?

TK point to the repo, say it's runnable

With the AST in hand, we can write all the textbook parts of a language implementation, like a [parser][main-parse], a [pretty-printer][main-pretty], and and [interpreter][main-interp].
All of them are thoroughly unremarkable.
The whole interpreter is just one method on `Expr`:

```rust
    fn interp(&self) -> i64 {
        match self {
            Expr::Binary(op, lhs, rhs) => {
                let lhs = lhs.interp();
                let rhs = rhs.interp();
                match op {
                    BinOp::Add => lhs.wrapping_add(rhs),
                    BinOp::Sub => lhs.wrapping_sub(rhs),
                    BinOp::Mul => lhs.wrapping_mul(rhs),
                    BinOp::Div => lhs.checked_div(rhs).unwrap_or(0),
                }
            }
            Expr::Literal(num) => *num,
        }
    }
```

My language has keep-on-truckin' semantics; every expression eventually evaluates to an `i64`, even if it's not the number you wanted.[^arith]

[^arith]: The totality-at-all-costs approach uses Rust's [wrapping integer arithmetic][wrap] functions and abuses [checked division][checked_div] to boldly assert that dividing by zero yields zero.

For extra credit, I also wrote a little [random program generator][main-rand]. It's also not all that interesting to look at; it just uses a recursively-increasing probability of generating a literal so it eventually terminates. Using fixed PRNG seeds, the random generator enables some easy [microbenchmarking][main-bench]. By generating and then immediately evaluating an expression, we can measure the performance of AST manipulation without the I/O costs of parsing and pretty-printing.

[main-parse]: https://github.com/sampsyo/flatcalc/blob/c5bbe7bd79f98a3b857f0432d4739a3f4f6241bd/src/main.rs#L28-L50
[main-pretty]: https://github.com/sampsyo/flatcalc/blob/c5bbe7bd79f98a3b857f0432d4739a3f4f6241bd/src/main.rs#L139-L155
[main-interp]: https://github.com/sampsyo/flatcalc/blob/c5bbe7bd79f98a3b857f0432d4739a3f4f6241bd/src/main.rs#L52-L67
[checked_div]: https://doc.rust-lang.org/std/primitive.i64.html#method.checked_div
[wrap]: https://doc.rust-lang.org/std/primitive.i64.html#method.wrapping_add
[main-bench]: https://github.com/sampsyo/flatcalc/blob/c5bbe7bd79f98a3b857f0432d4739a3f4f6241bd/Makefile#L4

You can check out [the relevant repo][repo] and try it out:

```sh
$ echo '(29 * 3) - 9 * 5' | cargo run
$ cargo run gen_interp  # Generate and immediately evaluate a random program.
```

## Flattening the AST

The *flattening* idea has two pieces:

* Instead of allocating `Expr` objects willy-nilly on the heap, we'll pack them into a single, contiguous array.
* Instead of referring to children via pointers, `Exprs` will refer to their children using their indices in that array.

TK illustration

If that plan sounds simple, it is—it's probably even simpler than you're thinking.
The main thing we need is an array of `Expr`s.
I'll use Rust's [newtype idiom][newtype] to declare our arena type, [`ExprPool`][flat-pool], as a shorthand for an `Expr` vector:

```rust
struct ExprPool(Vec<Expr>);
```

To keep things fancy, we'll also give a [name](https://github.com/sampsyo/flatcalc/blob/25f10b44252a2191ba6d0b5445f929096ad59361/src/main.rs#L32) to the plain old integers we'll use to index into an `ExprPool`:

```rust
struct ExprRef(u32);
```

The idea is that, everywhere we previously used a pointer to an `Expr` (i.e., `Box<Expr>` or sometimes `&Expr`), we'll use an `ExprRef` instead.
`ExprRef`s are just 32-bit unsigned integers, but by giving them this special name, we'll avoid confusing them with other `u32`s.
Most importantly, we need to change the definition of `Expr` itself:

```diff
 enum Expr {
-    Binary(BinOp, Box<Expr>, Box<Expr>),
+    Binary(BinOp, ExprRef, ExprRef),
     Literal(i64),
 }
```

Next, we need to add utilities to `ExprPool` to create `Expr`s (allocation) and look them up (dereferencing).
In my implementation, these little functions are called `add` and `get`, and [their implementations][flat-add-get] are extremely boring.
To use them, we need to look over our code and find every place where we create new `Expr`s or follow a pointer to an `Expr`.
For example, our `parse` function [used to be a method on `Expr`][main-parse], but we'll make it [a method on `ExprPool` instead][flat-parse]:

```diff
-fn parse(tree: Pair<Rule>) -> Self {
+fn parse(&mut self, tree: Pair<Rule>) -> ExprRef {
```

And where we used to return a newly allocated `Expr` directly, we'll now wrap that in `self.add()` to return an `ExprRef` instead.
Here's the `match` case for constructing a literal expression:

```diff
 Rule::number => {
     let num = tree.as_str().parse().unwrap();
-    Expr::Literal(num)
+    self.add(Expr::Literal(num))
 }
```

Our interpreter [gets the same treatment][flat-interp].
It also becomes an `ExprPool` method, and we have to add `self.get()` to go from an `ExprRef` to an `Expr` we can pattern-match on:

```diff
-fn interp(&self) -> i64 {
+fn interp(&self, expr: ExprRef) -> i64 {
-    match self {
+    match self.get(expr) {
```

That's about it.
I think it's pretty cool how few changes are required—see for yourself in [the complete diff][compare].
You replace `Box<Expr>` with `ExprRef`, insert `add` and `get` calls in the obvious places, and you've got a flattened version of your code.
Neat!

[newtype]: https://doc.rust-lang.org/rust-by-example/generics/new_types.html
[flat-pool]: https://github.com/sampsyo/flatcalc/blob/25f10b44252a2191ba6d0b5445f929096ad59361/src/main.rs#L37
[flat-add-get]: https://github.com/sampsyo/flatcalc/blob/25f10b44252a2191ba6d0b5445f929096ad59361/src/main.rs#L45-L55

## But Why?

TK the benefits are:
locality (perf)
cheaper allocation (perf)
smaller references (perf)
free together (perf, but this is lower priority)
easier lifetimes (ergonomics, kinda Rust-specific, but kinda not)
convenient for hash-consing/dedup (ergonomics)

## Performance Results

TK can we do something about reming the `drop` advantage?

## Bonus: Exploiting the Flat Representation

So far, flattening has happened entirely "under the hood":
the arena array serves as a drop-in replacement for allocating objects normally,
and the integer offsets are drop-in replacements for pointers.
Another fun thing you can do with
