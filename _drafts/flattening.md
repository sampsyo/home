---
title: 'Flattening ASTs (and Other Compiler Data Structures)'
excerpt: |
    TK
---
<figure style="max-width: 180px;">
<img src="{{ site.base }}/media/flattening/normal.png" alt="a normal AST">
<img src="{{ site.base }}/media/flattening/flat.png" alt="a flat AST">
<figcaption>Normal and flattened ASTs for the expression <code>a * b + c</code>.</figcaption>
</figure>

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

With the AST in hand, we can write all the textbook parts of a language implementation, like a [parser][main-parse], a [pretty-printer][main-pretty], and an [interpreter][main-interp].
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
[main-rand]: https://github.com/sampsyo/flatcalc/blob/c5bbe7bd79f98a3b857f0432d4739a3f4f6241bd/src/main.rs#L118-L136

You can check out [the relevant repo][repo] and try it out:

```sh
$ echo '(29 * 3) - 9 * 5' | cargo run
$ cargo run gen_interp  # Generate and immediately evaluate a random program.
```

## Flattening the AST

The *flattening* idea has two pieces:

* Instead of allocating `Expr` objects willy-nilly on the heap, we'll pack them into a single, contiguous array.
* Instead of referring to children via pointers, `Exprs` will refer to their children using their indices in that array.

<figure style="max-width: 150px;">
<img src="{{ site.base }}/media/flattening/flat.png" alt="the same flat AST from earlier">
</figure>

Let's look back at the doodle from the top of the post.
We want to use a single `Expr` array to hold all our AST nodes.
These nodes still need to point to each other; they'll now do that by referring to "earlier" slots in that array.
Plain old integers will take the place of pointers.

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
[flat-parse]: https://github.com/sampsyo/flatcalc/blob/25f10b44252a2191ba6d0b5445f929096ad59361/src/main.rs#L57-L81
[flat-interp]: https://github.com/sampsyo/flatcalc/blob/25f10b44252a2191ba6d0b5445f929096ad59361/src/main.rs#L83-L98

## But Why?

Flattened ASTs come with a bunch of benefits.
The classic ones most people cite are all about performance:

1. **Locality.**
   Allocating normal pointer-based `Expr`s runs the risk of [fragmentation][].
   Flattened `Expr`s are packed together in a contiguous region of memory, which is good for [spatial locality][sploc].
   Your data caches will work better because `Expr`s are more likely to share a cache line,
   and even simple [prefetchers][prefetch] will do a better job of predicting which `Expr`s to load before you need them.
   A sufficiently smart memory allocator *might* achieve the same thing, especially if you allocate the whole AST up front and never add to it, but using a dense array removes all uncertainty.
2. **Smaller references.**
   Normal data structures use pointers for references; on modern architectures, those are always 64 bits.
   After flattening, you can use smaller integers---if you're pretty sure you'll never need more than 4,294,967,295 AST nodes,
   you can get by with 32-bit references, like we did in our example.
   That's a 50% space savings for all your references, which could amount to a substantial overall memory reduction in pointer-heavy data structures like ASTs.
   Smaller memory footprints mean less bandwidth pressure and even better spatial locality.
   And you might save even more if you can get away with 16- or even 8-bit references for especially small data structures.
3. **Cheap allocation.**
   In flatland, there is no need for a call to `malloc` every time you create a new AST node.
   Instead, provided you pre-allocate enough memory to hold everything, allocation can entail just [bumping the tail pointer][bump] to make room for one more `Expr`.
   Again, a really fast `malloc` might be hard to compete with---but you basically can't beat bump allocation on sheer simplicity.
4. **Cheap deallocation.**
   Our flattening setup assumes you never need to free individual `Expr`s.
   That's probably true for many, although not all, language implementations:
   you might build up new subtrees all the time, but you don't need to reclaim space from many old ones.
   ASTs tend to "die together," i.e., it suffices to deallocate the entire AST all at once.
   While freeing a normal AST entails traversing all the pointers to free each `Expr` individually, you can deallocate a flattened AST in one fell swoop by just freeing the whole `ExprPool`.

I think it's interesting that many introductions to arena allocation tend to focus on cheap deallocation (#4) as the main reason to do it.
[The Wikipedia page][region], for example, doesn't (yet!) mention locality (#1 or #2) at all.
You can make an argument that #4 might be the *least* important for a compiler setting---since ASTs tend to persist all the way to the end of compilation, you might not need to free them at all.

Beyond performance, there are also ergonomic advantages:

1. **Easier lifetimes.**
   In the same way that it's easier for your computer to free a flattened AST all at once, it's also easier for *humans* to think about memory management at the granularity of an entire AST.
   An AST with *n* nodes has just one lifetime instead of *n* for the programmer to think about.
   This simplification is quadruply true in Rust, where lifetimes are not just in the programmer's head but in the code itself.
   Passing around a `u32` is way less fiddly than carefully managing lifetimes for all your `&Expr`s: your code can rely instead on the much simpler lifetime of the `ExprPool`.
   I suspect this is why the technique is so popular in Rust projects.
   As a Rust partisan, however, I'll argue that the same simplicity advantage applies in C++ or any other language without GC---it's just latent instead of explicit.
2. **Convenient deduplication.**
   A flat array of `Expr`s can make it fun and easy to implement [hash consing][] or even simpler techniques to avoid duplicating identical expressions.
   For example, if we notice that we are duplicating the first 128 integer `Literal` expressions a lot, we could reserve the first 128 slots in our `ExprPool` just for those.
   Then, when someone needs the integer literal expression `42`, our `ExprPool` don't need to construct a new `Expr` at all---we can just produce `ExprRef(42)` instead.
   This kind of game is possible with a normal pointer-based representation too, but it probably requires some kind of auxiliary data structure.

[sploc]: https://en.wikipedia.org/wiki/Locality_of_reference#Types_of_locality
[prefetch]: https://en.wikipedia.org/wiki/Prefetching
[bump]: https://docs.rs/bumpalo/latest/bumpalo/
[fragmentation]: https://en.wikipedia.org/wiki/Fragmentation_(computing)
[hash consing]: https://en.wikipedia.org/wiki/Hash_consing

## Performance Results

TK can we do something about reming the `drop` advantage?

## Bonus: Exploiting the Flat Representation

So far, flattening has happened entirely "under the hood":
the arena array serves as a drop-in replacement for allocating objects normally,
and the integer offsets are drop-in replacements for pointers.
Another fun thing you can do with
