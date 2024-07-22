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
* The semantics are simple, without too many distractions.
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

Bril is extensible, in a loosey-goosey way.
The string-heavy JSON syntax means it's trivial to add new opcodes and data types.
Beyond the [core language][core], there are "official" extensions for [manually managed memory][memory], [floating-point numbers][float], a funky form of [speculation][spec] I use for teaching JIT principles, [module imports][import], and [characters][char].
While a *laissez faire* approach to extensions has worked so far, it's also a mess:
there's no systematic way to tell which extensions a given program uses or which language features a given tool supports.
[A more explicit approach to extensibility][38] would make the growing ecosystem easier to manage.

(Most of these extensions were contributed by CS 6120 students.
In the first semester, for instance, I was low on time and left both memory and function calls as an exercise to the reader.
You can read blog posts [by Drew Zagieboylo & Ryan Doenges about the memory extension][memory-blog]
and [by Alexa VanHattum & Gregory Yauney about designing function calls][func-blog].
Laziness can pay off.)

Finally, Bril does not require not SSA.
There is [an SSA form][ssa] that includes a `phi` extension, but the language itself has mutable variables.
I wouldn't recommend this strategy for any other IL, but it's helpful for teaching for three big reasons:

1. I want students to feel the pain of working with non-SSA programs before the course introduces SSA. This frustration can help motivate why SSA is the modern consensus.
2. The course includes a task where students [implement into-SSA and out-of-SSA transformations][ssa-task].
3. It's really easy to generate Bril code from frontend languages that have mutable variables. The alternative would be LLVM's [mem2reg][]/"just put all the frontend variables in memory" trick, but Bril avoids building memory into the core language for simplicity.

Unfortunately, this aftermarket SSA retrofit has been a huge headache.
TK persistent problems with undefinedness.
TK weird/bad phi semantics.
I think Bril's SSA form needs a significant rework, probably based on a more radical change to the core language such as adding [basic block arguments][block-args].
It has been an interesting lesson for me that SSA comes with subtle design implications that are difficult to retrofit onto an existing mutation-oriented IL.

[core]: https://capra.cs.cornell.edu/bril/lang/core.html
[ssa-task]: https://www.cs.cornell.edu/courses/cs6120/2023fa/lesson/6/#tasks
[memory]: https://capra.cs.cornell.edu/bril/lang/memory.html
[float]: https://capra.cs.cornell.edu/bril/lang/float.html
[spec]: https://capra.cs.cornell.edu/bril/lang/spec.html
[import]: https://capra.cs.cornell.edu/bril/lang/import.html
[char]: https://capra.cs.cornell.edu/bril/lang/char.html
[ssa]: https://capra.cs.cornell.edu/bril/lang/ssa.html
[memory-blog]: https://www.cs.cornell.edu/courses/cs6120/2019fa/blog/manually-managed-memory/
[func-blog]: https://www.cs.cornell.edu/courses/cs6120/2019fa/blog/function-calls/
[38]: https://github.com/sampsyo/bril/issues/38
[mem2reg]: https://llvm.org/doxygen/Mem2Reg_8cpp_source.html
[block-args]: https://mlir.llvm.org/docs/LangRef/#blocks

## The Bril Ecosystem

<img src="{{site.base}}/media/bril/ecosystem.svg"
    class="img-responsive bonw" style="max-width: 450px;">

TK shaded blocks are things that students built.

TK link to [playground][]

draw a graph of all the stuff?
definitely link to the cool web playground

highlight things that people have built. distinguish the extremely tiny set of tools we started with, and where we are at now (in the monorepo and beyond).

TK in the first semester, Bril didn't even have memory or function calls.
the language for these was invented by students.

[playground]: https://agentcooper.github.io/bril-playground/
