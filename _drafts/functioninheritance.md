---
title: "Function Inheritance is Fun and Easy"
excerpt: |
    xxx
highlight: true
---
[Function inheritance][browncook] is a simple technique for adding extensibility to recursive functions. I'm in the midst of writing a compiler, which is just a giant pile of recursive tree traversals, so function inheritance is repeatedly saving my tender behind from jumbled abstractions.

This post demonstrates function inheritance with some [TypeScript][] examples. Here's [a Gist with the complete, executable code][gist] for everything.

[gist]: https://gist.github.com/sampsyo/7f1fa4f2ebc10088a7d6

## The Problem

Say you have a recursive function. It could be type checker or an interpreter, but let's say it's everybody's favorite recursive function: [`fib`][fibonacci]. Here's an exponential-time `fib` in TypeScript:

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

That's a nice `fib`! But what if you need to *extend* it---for example, to log calls to the function for debugging, or to [memoize answers for a linear-time version][might]? You could sneak some extra code into the top of `fib`. But mixing this extra behavior together with the "core" Fibonacci computation has the ordinary drawbacks of tight coupling:

* Your logging or memoization code isn't reusable; it's tied to `fib`.
* You can't easily get the original non-logged, non-memoized variant of `fib` if you need it too.
* In more complicated recursive functions than `fib`, where there are lots of cases, this can lead to a lot of boilerplate and obscure the important part of the original computation.

It would be better to write these additional behaviors *separately* from `fib` and some how smash them together.

[might]: http://matt.might.net/articles/implementation-of-recursive-fixed-point-y-combinator-in-javascript-for-memoization/

## Function Inheritance

I learned this technique from [a 2006 tech report][browncook] by Daniel Brown and [William Cook][] from UT Austin and from [Matt Might's related blog post][might]. Brown and Cook pitch the idea as bringing the notion of "inheritance" from Object-Oriented Land to Functional World.

The basic recipe has three steps: write your recursive functions as *generators*; write your additional behaviors as *combinators*, a.k.a. "mixins"; and tie everything together using a [fixed-point combinator][fpc].

[william cook]: http://www.cs.utexas.edu/~wcook/

### Generators

The first step is to change your algorithm to take a function parameter and use that for any recursive calls. You'll recognize this recursion elimination from any [discussion of the Y combinator][ycintro] and recursion in the lambda calculus:

```ts
// A "generator," which will only be useful after we get its fixed point later.
function gen_fib(fself: (_:number) => number): (_:number) => number {
  // From here on, this looks like an ordinary recursive Fibonacci, except
  // recursive calls go to the curried `fself` function parameter.
  return function (num: number): number {
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

We've changed the recursive calls to `fib` to instead go to the curried `fself` function argument. That name, `fself`, is meant to call to mind the "self" or pointer in OO languages. It plays a similar role in making this function extensible.

The new `gen_fib` function's type is no longer `number -> number`. Instead, it's a *generator* in Brown and Cook's parlance. In their Haskell, generator types are written `a -> a`. In TypeScript, we can write `gen_fib`'s type like this:

```ts
type Gen <T> = (_:T) => T;
let gen_fib : Gen< (_:number) => number >;
```

The TypeScript syntax for function types is a little weird, because parameter names are required but ignored, but you can read `(_:A) => B` as `a -> b` in Haskell or ML notation.

### Mixins

Step two is to write your additional "mixin" behavior as a combinator. Here's a `trace` combinator that prints a message on every invocation:

```ts
function trace <T extends Function> (fsuper: T): T {
  return <any> function (...args: any[]): any {
    console.log('called with arguments: ' + args);
    return fsuper(...args);
  }
}
```

TK what is fsuper?

That implementation is a little hacky because it supports an arbitrary number of function arguments via [ES6 "spread" syntax][spread]. For a less trivial example that also has stronger types, see the memoization combinator, `memo`, in [this post's associated  Gist][gist].

[spread]: http://wiki.ecmascript.org/doku.php?id=harmony:spread

### Tying It Together

The final code is to mash up the core code with the mixins. To do this in TypeScript, we'll need two handy functional tools: a fixed-point combinator and function composition.

Here's a simple fixed-point combinator that works with any number of function arguments:

```ts
function fix <T extends Function> (f : Gen<T>) : T {
  return <any> function (...args: any[]) {
    return (f(fix(f)))(...args);
  };
}
```

The function composition function is even simpler:

```ts
function compose <A, B, C> (g : (_:B) => C, f : (_:A) => B): (_:A) => C {
  return function (x : A): C {
    return g(f(x));
  }
}
```

With those two pieces, we can apply our combinators and make real, recursive functions that we can call:

```ts
// Here's an ordinary recursive Fibonacci without any mixins.
let fib = fix(gen_fib);

// And here's a traced version.
let fib_trace = fix(compose(trace, gen_fib));
```

If you're still not convinced this actually works, clone [this Gist][gist] and type `make`. Feel the power!

[fpc]: https://en.wikipedia.org/wiki/Fixed-point_combinator
[browncook]: http://www.cs.utexas.edu/~wcook/Drafts/2006/MemoMixins.pdf
[ycintro]: http://mvanier.livejournal.com/2897.html
[typescript]: http://www.typescriptlang.org/
[fibonacci]: https://en.wikipedia.org/wiki/Fibonacci_number

## For Compilers

Since embracing function inheritance last week, I've already used it twice in my prototype compiler:

* Type elaboration. Instead of [mucking up my type checker with AST-manipulation boilerplate][soq], I use something like a memoization combinator to save its results in a symbol table.
* Desugaring. I wrote a pure-boilerplate generator, `gen_translate`, that copies an AST without changing it. Then used a combinator to encapsulate the pattern matching I need to break down semantic sugar.

TK about TS in general

[soq]: http://stackoverflow.com/q/32641750/39182
