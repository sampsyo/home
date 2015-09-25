---
title: "Function Inheritance is Fun and Easy"
excerpt: |
    xxx
highlight: true
---
[Function inheritance][browncook] is a simple technique for adding extensibility to recursive functions. I'm in the midst of writing a compiler, which is just a giant pile of recursive tree traversals, so function inheritance is repeatedly saving my tender behind from jumbled abstractions.

## The Problem

Say you have a recursive function. It could be type checker or an interpreter, but let's say it's everybody's favorite recursive function: [`fib`][fibonacci]. Here's an exponential-time `fib` in [TypeScript][]:

```ts
function fib (num: number): number {
  if (num === 0) {
    return 0;
  } else if (num === 1) {
    return 1;
  } else {
    return fib(num - 1) + fib(num - 2);
  }
}
```

That's a nice `fib`! But what if you need to *extend* it---for example, to log calls to the function, or to [memoize answers for a linear-time version][might]? You could sneak some extra code into the top of `fib`. But mixing this extra behavior together with the "core" Fibonacci computation has drawbacks:

* Your logging or memoization code isn't reusable; it's tied to `fib`.
* You can't easily get the original non-logged, non-memoized variant of `fib` if you need it too.
* In more complicated recursive functions than `fib`, where there are lots of cases, this can lead to a lot of boilerplate and obscure the important part of the original computation.

It would be better to write these additional behaviors *separately* from `fib` and some how smash them together.

[might]: http://matt.might.net/articles/implementation-of-recursive-fixed-point-y-combinator-in-javascript-for-memoization/

## Function Inheritance

I learned this technique from [a 2006 tech report][browncook] by [Daniel Brown][] and [William Cook][] from UT Austin and from [Matt Might's related blog post][might]. Brown and Cook pitch the idea as bringing the notion of "inheritance" from Object-Oriented Land to Functional World.

The basic recipe has three parts: write your recursive functions as *generators*, write your additional behaviors as *combinators* (a.k.a. "mixins"), and tie everything together using a [fixed-point combinator][fpc].

### Generators

The first step is to change your recursive algorithm to take a function argument and use it for recursive calls. You'll recognize this "recursion elimination" from any [discussion of the Y combinator][ycintro] and recursion in the lambda calculus. Doing this rewrite once makes the code extensible:

```ts
// We write the Fibonacci function as a generator. This is a curried function
// where the first parameter will be used to take a fixed point.
function gen_fib(fself: (_:number) => number): (_:number) => number {
  // From here on, this looks like an ordinary recursive Fibonacci, except
  // recursive calls go to the curried `fself` function.
  return function (num : number): number {
    if (num === 0) {
      return 0;
    } else if (num === 1) {
      return 1;
    } else {
      return fself(num - 1) + fself(num - 2);
    }
  }
}
```

We've changed the recursive calls to `fib` to instead go to the curried `fself` function argument. That name, `fself`, is meant to call to mind the `self` or `this` pointer in OO languages.

The new `gen_fib` function's type is no longer `number -> number`. Instead, it's a *generator* in Brown and Cook's parlance: something of type `a -> a` in their Haskell. In TypeScript, we can write its type like this:

```ts
type Gen <T> = (_:T) => T;
let gen_fib : Gen<(_:number) => number>;
```

The TypeScript syntax for function types is a little weird, because parameter names are required but ignored, but you can read `(_:A) => B` as `a -> b` in Haskell or ML notation.

### Mixins

Step two is to write your additional "mixin" behavior as a combinator, separately from the 

### Tying It Together


[fpc]: https://en.wikipedia.org/wiki/Fixed-point_combinator
[browncook]: http://www.cs.utexas.edu/~wcook/Drafts/2006/MemoMixins.pdf
[ycintro]: http://mvanier.livejournal.com/2897.html

## For Compilers

Since embracing function inheritance last week, I've already used it twice in my prototype compiler:

* xxx
* yyy

It was startlingly useful for me recently when writing parts of a compiler in [TypeScript][]
