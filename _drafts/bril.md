---
title: "Bril: An Intermediate Language for Teaching Compilers"
---
I created a new "advanced compilers" course for PhD students, called [CS 6120][cs6120], a few years ago.
The organizing principle is a focus on the "middle end," defined broadly:
analysis and optimization, but also runtime services, verification, synthesis, JITs, and so on;
but not lexing, parsing, semantic analysis, register allocation, or instruction selection.
That latter stuff is all cool, but you have to sacrifice something for a coherent focus.

This post is about [Bril][], the Big Red Intermediate Language.
Bril is a new compiler intermediate representation I made to support this kind of compilers course.
Bril is the only compiler IL I know of that is specifically designed for education.
Focusing on teaching means that Bril prioritizes these goals:

* It is fast to get started working with the IL.
* It is easy to mix and match components that work with the IL, including things that fellow students write.
* The language has simple semantics without too many distractions.
* The design is ruthlessly regular, i.e., everything in the language falls into a pretty small number of *kinds of things*.

Bril is different from other ILs because it ranks those goals above other, more typical goals for an IL:
code size, compiler speed, and performance of the generated code.

Aside from that invasion of priorities, Bril looks sorta like any other modern compiler IL.
It's a self-contained, assembly-like, typed, instruction-based language.
There's a quote from [why the lucky stiff][why] where he introduces [Camping][], the original web microframework, as "a little white blood cell in the vein of Rails."
If LLVM is an entire circulatory system, Bril is a single blood cell.

[camping]: https://camping.github.io/camping.io/
[why]: https://en.wikipedia.org/wiki/Why_the_lucky_stiff
[bril]: https://capra.cs.cornell.edu/bril/
[cs6120]: https://www.cs.cornell.edu/courses/cs6120/2023fa/

## Bril is JSON

Bril programs are JSON documents.
Here's how students can work with Bril code using Python:

```py
import json
import sys
prog = json.load(sys.stdin)
```

I'm obviously being a little silly here.
But seriously, the JSON-as-syntax idea is in service of the *fast to get started* and *easy to mix and match components* goals above.
At the next level of detail, I wanted Bril to do these things:

* **Let students use any programming language they want.**
  I wanted my compilers course to be accessible to lots of PhD students, including people with only tangential interest in compilers.
  Letting them use the languages they're comfortable with is a great way to avoid any ramp-up phase with some "realistic" compiler implementation language, whatever you think that is.
* **No framework is required to get started.**
  This is partially a practical matter; for the first offering of CS 6120, no libraries existed, and I needed to run the course somehow.
  But I also think this constraint is pedagogically valuable as a complexity limiter:
  students can get started with simple stuff without learning any APIs.
  These days, Bril does come with libraries that are great for avoiding the JSON boilerplate when you scale up:
  for [Rust][bril-rs], [OCaml][bril-ocaml], [Swift][bril-swift], and [TypeScript][bril-ts].
  But the fact that they're not really *required* keeps the onramps gentle.
* **Compose small pieces with Unix pipelines.**
  You can wire up Bril workflows with shell pipelines, like `cat code.json | my_opt | my_friends_opt | brilck`.
  I want students in CS 6120 to freely share code with each other and to borrow bits of functionality I wrote.
  For a PhD-level class, this trust-based "open-source" course setup makes way more sense to me than a typical undergrad-style approach to academic integrity.
  Piping JSON from one tool to the next is a great vehicle for sharing.

So, JSON is the canonical form for Bril code.
Here's a complete Bril program:

```json
{
  "functions": [{
    "name": "main",
    "args": [],
    "instrs": [
      { "op": "const", "type": "int", "dest": "v0", "value": 1 },
      { "op": "const", "type": "int", "dest": "v1", "value": 2 },
      { "op": "add", "type": "int", "dest": "v2", "args": ["v0", "v1"] },
      { "op": "print", "args": ["v2"] }
    ]
  }]
}
```

This program has one function, `main`, with no arguments and 4 instructions:
two `const` instructions, an `add`, and a `print`.

Even though Bril is JSON, it also has a text form.
I will, however, die on the following hill:
**the text form is a second-class convenience**, with no warranty of any kind, express or implied.
The text syntax exists solely to cater to our foibles as humans for whom reading JSON directly is just kinda annoying.
Bril itself is the JSON format you see above.
But amid Bril's multifaceted toolset are a parser and pretty-printer that will show you the text equivalent:

```bril
@main {
  v0: int = const 1;
  v1: int = const 2;
  v2: int = add v0 v1;
  print v2;
}
```

TK show a pipeline with the parser and pretty-printer

TK real performance cost, because you have to serialize/deserialize between every step.

[bril-ocaml]: https://github.com/sampsyo/bril/tree/main/bril-ocaml
[bril-ts]: https://github.com/sampsyo/bril/tree/main/bril-ts
[bril-swift]: https://github.com/sampsyo/bril/tree/main/bril-swift
[bril-rs]: https://github.com/sampsyo/bril/tree/main/bril-rs

## TK language design

TK example of prioritizing regularity: constants are separate instructions. pretty annoying to write as a consequence, but it's one less case to deal with...

## TK the available tools

draw a graph of all the stuff?
definitely link to the cool web playground

highlight things that people have built. distinguish the extremely tiny set of tools we started with, and where we are at now (in the monorepo and beyond).

## downsides/future work?

* not SSA, but with an SSA variant. this is important so (1) students can feel the pain of working with non-SSA programs, and (2) so that they an implement the to-SSA/from-SSA passes as an assignment, and (3) makes it easy to emit from frontends that have mutation *without needing memory in the IL*
    * there is an SSA form, but... it is not great (we should do something about that). this goal turns out to have been the hardest to meet
    * maybe switch to BB arguments, for a more radical departure in the SSA form? I think a lot of the complexity/bugs come from trying to treat SSA as just a small tweak on the non-SSA base language
