---
title: "Bril: An Intermediate Language for Teaching Compilers"
---
When I started a new [PhD-level compilers course][cs6120] a few years ago,
I thought it was important to use a "hands-on" structure.
There is a big difference between understanding an algorithm on a whiteboard and implementing it, running into bugs in real programs, and fixing them.

I created [Bril][], the Big Red Intermediate Language, to support the class's implementation projects.
Bril isn't very interesting from a compiler engineering perspective, but
I think it's pretty good for the specific use case of teaching compilers classes.
Here's a factorial program:

```bril
@main(input: int) {
  res: int = call @fact input;
  print res;
}

@fact(n: int): int {
  one: int = const 1;
  cond: bool = le n one;
  br cond .then .else;
.then:
  ret one;
.else:
  decr: int = sub n one;
  rec: int = call @fact decr;
  prod: int = mul n rec;
  ret prod;
}
```

Bril is the only compiler IL I know of that is specifically designed for education.
Focusing on teaching means that Bril prioritizes these goals:

* It is fast to get started working with the IL.
* It is easy to mix and match components that work with the IL, including things that fellow students write.
* The language has simple semantics without too many distractions.
* The syntax is ruthlessly regular.

Bril is different from other ILs because it ranks those goals above other, more typical goals for an IL:
code size, compiler speed, and performance of the generated code.

Aside from that invasion of priorities, Bril looks a lot like any other modern compiler IL.
It's a assembly-like, typed, instruction-based [ANF][] language.
There's a quote from [why the lucky stiff][why] where he introduces [Camping][], the original web microframework, as "a little white blood cell in the vein of Rails."
If LLVM is an entire circulatory system, Bril is a single blood cell.

[camping]: https://camping.github.io/camping.io/
[why]: https://en.wikipedia.org/wiki/Why_the_lucky_stiff
[bril]: https://capra.cs.cornell.edu/bril/
[cs6120]: https://www.cs.cornell.edu/courses/cs6120/2023fa/
[anf]: https://en.wikipedia.org/wiki/A-normal_form

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
I wanted Bril to do these things:

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
But two of Bril's many tools are a [parser and pretty-printer][bril-txt].
Here's the text form of the program above:

```bril
@main {
  v0: int = const 1;
  v1: int = const 2;
  v2: int = add v0 v1;
  print v2;
}
```

As a consequence, working with Bril means typing commands like this a lot:

```
$ bril2json < program.bril | do_something | bril2txt
```

It can get annoying to constantly need to convert to and from JSON,
and it's wasteful to constantly serialize and deserialize programs at each stage in a long pipeline.
But the trade-off is that the Bril ecosystem comprises a large number of small pieces, loosely joined and infinitely remixable on the command line.

[bril-ocaml]: https://github.com/sampsyo/bril/tree/main/bril-ocaml
[bril-ts]: https://github.com/sampsyo/bril/tree/main/bril-ts
[bril-swift]: https://github.com/sampsyo/bril/tree/main/bril-swift
[bril-rs]: https://github.com/sampsyo/bril/tree/main/bril-rs
[bril-txt]: https://github.com/sampsyo/bril/blob/main/bril-txt/briltxt.py

## Language Design: Good, Bad, and Ugly

There are a few design decisions in the language itself that reflect Bril's education-over-practicality priorities.
For instance, `print` is a [core opcode][core] in Bril; I don't think this would be a good idea in most compilers, but it makes it really easy to write small examples.
Another exotic quirk is that Bril is *extremely* [A-normal form][anf], to the point that constants always have to go in their own instructions and get their own names.
To increment an integer, for example, you can't do this:

```bril
incr: int = add n 1;
```

Instead, Bril code is full of these one-off constant variables, like this:

```bril
one: int = const 1;
incr: int = add n one;
```

This more-ANF-than-ANF approach to constants is verbose to the point of silliness.
But it simplifies the way you write some basic IL traversals because you don't have to worry about whether operands come from variables or constants.
For many use cases, you get to handle constants the same way you do any other instruction.
For teaching, I think the regularity is worth the silliness.

TK: extensible. link to the extensions.
this is currently super ad hoc and ramshackle. I would like a way to be explicit about which language extensions are in scope... and maybe a "machine-readable" way to specify extensions, at least syntactically (not semantically).

TK: not SSA.
not SSA, but with an SSA variant. this is important so (1) students can feel the pain of working with non-SSA programs, and (2) so that they an implement the to-SSA/from-SSA passes as an assignment, and (3) makes it easy to emit from frontends that have mutation *without needing memory in the IL*
* there is an SSA form, but... it is not great (we should do something about that). this goal turns out to have been the hardest to meet
* maybe switch to BB arguments, for a more radical departure in the SSA form? I think a lot of the complexity/bugs come from trying to treat SSA as just a small tweak on the non-SSA base language

[core]: https://capra.cs.cornell.edu/bril/lang/core.html

## TK the available tools

<img src="{{site.base}}/media/bril/ecosystem.svg"
    class="img-responsive bonw" style="max-width: 450px;">

draw a graph of all the stuff?
definitely link to the cool web playground

highlight things that people have built. distinguish the extremely tiny set of tools we started with, and where we are at now (in the monorepo and beyond).

TK in the first semester, Bril didn't even have memory or function calls.
the language for these was invented by students.
