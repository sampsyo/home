---
title: Back to the Building Blocks' Building Blocks
---
<aside>
This post is based on a keynote I gave at <a href="https://www.dagstuhl.de/26042/">Dagstuhl Seminar #26042, <i>Trustworthy System Architectures for the Age of Custom Silicon</i></a>. Many thanks to the seminar's organizers and to the Dagstuhl staff for a fun and enlightening workshop.
</aside>

If there are hardware engineers who love Verilog, I haven't met them.
Almost universally, the attitude toward Verilog seems to be that it's frustrating, ridiculous, error-prone, and the only pragmatic choice.

Verilog is inescapable because it is the input format to essentially every EDA tool.
Its centrality means that it is a <i>de facto</i> intermediate representation implementing for every other HDL:
even if you prefer [Bluespec][], [Chisel][], [Amaranth][], or [Spade][], they all have to compile to Verilog to interact with the rest of the hardware world.

I am worried that Verilog's flaws will be the cause of a new wave of hardware bugs.
There is an analogy to the problems with C and C++:
as designing custom hardware becomes more popular, we risk allowing a dangerous HDL to proliferate and fester in the same way that memory-unsafe programming languages have in software.

I don't know yet what the analog of memory safety is for hardware bugs, or even if there will be a single dominant defect category.
Footguns abound in Verilog, though, so there are many good candidates.
This post makes the case that we should invest in better understanding the problems with Verilog so that future HDLs can avoid them.

[chisel]: https://www.chisel-lang.org
[bluespec]: https://github.com/B-Lang-org/bsc
[amaranth]: https://amaranth-lang.org/
[spade]: https://spade-lang.org

## On Building Blocks

<figure style="max-width: 256px">
<a href="https://bidenwhitehouse.archives.gov/wp-content/uploads/2024/02/Final-ONCD-Technical-Report.pdf"><img src="{{site.base}}/media/buildingblocks.png"></a>
</figure>

For American programming languages nerds,
["Back to the Building Blocks"][bbb] was one of the most exciting things to happen in recent memory.
It's a 2024 report from the White House Office of the National Cyber Director that argued the importance of memory safety.
It called for critical infrastructure to move on from memory-unsafe languages like C and C++ and even mentioned [Rust][] by name as a promising alternative.

"Back to the Building Blocks" didn't break new ground:
by 2024, it was obvious to most right-thinking people that memory safety was a huge problem.
It was exciting because *Joe Biden* was saying the same things that we had all been saying for years.[^biden]
I'm not a very patriotic person, but my heart soars like an eagle when I read stuff like this in a government report:

> Despite rigorous code reviews as well as other preventive and detective controls, up to 70 percent of security vulnerabilities in memory unsafe languages patched and assigned a CVE designation are due to memory safety issues.

And I start hearing the national anthem when Joe Biden says:

> For new products, choosing to build in a memory safe programming language is an early architecture decision that can deliver significant security benefits. Even for existing codebases, where a complete rewrite of code is more challenging, there are still paths toward adopting memory safe programming languages by taking a hybrid approach.

God bless America.

"Back to the Building Blocks" distills a hard-to-refute syllogism along these lines:

1. Correctness matters.
2. There exist large classes of bugs with similar root causes.
3. Some languages lead to a higher frequency of these bug classes than other languages.
4. We should therefore see these bugs as the "fault" of the language, not the programmer.
5. Languages that are "harder to use" but dramatically reduce the frequency of these bugs may be worth it.

In the original report, this "Building Blocks" argument was about C.
But I believe the same reasoning applies to Verilog.

[bbb]: https://bidenwhitehouse.archives.gov/wp-content/uploads/2024/02/Final-ONCD-Technical-Report.pdf
[rust]: https://rust-lang.org

[^biden]: I choose to believe that Biden wrote "Back to the Building Blocks" all by himself, and I am not interested in evidence to the contrary.

## The Claim (Weak and Strong Forms)

I'll state my thesis in a weak form and a strong form; you can pick which level you want to consider.
The weak form is:

> Verilog causes lots of bugs.

And the strong form is:

> The next "Building Blocks" crisis will happen in hardware, and it will be Verilog's fault.

In other words: as we begin to get a handle on memory safety,
the next scourge of avoidable-seeming bugs will occur in hardware designs.
Better HDLs could dramatically reduce the frequency of these bugs.

It is worthwhile to ask:
if the situation is so dire, why isn't this already a crisis?
Or: what's changing *now* that will make Verilog's flaws matter more than they have in the past?

The answer is that hardware design is currently undergoing a kind of Cambrian explosion.
The traditional way to develop hardware---the kind of process that big CPU vendors use---mitigates HDLs' flaws by spending a ridiculous amount of resources on verification.
This observation is hard to justify with concrete evidence, but consider [this dubious report from an industry consortium][wilson] that claims that, in CPU design projects,
the ratio of verification engineers to design engineers is 5:1.
A terrible HDL matters less when you have a safety net like that.

But today, more and more people want to design custom, application-specific hardware.
Specialized, lower-volume hardware projects will not (and should not) use the same engineering process as Apple's next iPhone SoC.
The emerging long tail of cheaper, lighter-weight hardware design projects will be more vulnerable to Verilog's problems.

[wilson]: https://resources.sw.siemens.com/en-US/white-paper-2022-wilson-research-group-functional-verification-study-ic-asic-functional-verification-trend-report/

## Some Cheap Shots at Verilog

The main point of this post is to call for systematic study of Verilog's implications for hardware correctness, not to pick on specific flaws I personally love to hate.
But I can't resist shooting a few fish in this particular barrel.

The root of Verilog's problems is that it was not designed for implementing hardware.
It was [originally developed][hopl] as a DSL for writing event-based *simulators* of digital logic.
Later, logic synthesis tools repurposed Verilog for generating real netlists.
Many problems with Verilog stem from the confusing boundaries between simulation and implementation:

* **There is an ill-defined "synthesizable" subset.** Tools can't agree on what this subset is, but we can all agree that not all of Verilog can be sensibly translated into hardware.
* **Verilog requires load-bearing linters.** Serious hardware design shops pay for extremely expensive commercial tools that keep their engineers within the Verilog subset that their toolchain can handle.

To get concrete, let's look at three specific footguns in Verilog:
inferred latches, the semantics of the "don't care" value, and the absence of cycle-level timing information.
(As a warning, the latter is a self-serving complaint that motivates [some research from my lab][filament].)

[hopl]: https://dl.acm.org/doi/10.1145/3386337
[filament]: https://filamenthdl.com

### Inferred Latches

Verilog, people say, uses the register-transfer level (RTL) abstraction.
If this was the first thing I knew about Verilog, I would assume it works like this:
the language has special, built-in constructs for *state elements* like latches, registers, and memories.
You write a Verilog program by describing how to compute the values of all state elements on cycle *n+1* based on their values on cycle *n*.
In an RTL language, it seems obvious that all the registers should be explicit and clearly separated from stateless combinational logic.

Because of Verilog's roots in event-based simulation, that's not how it works.
Instead, variables *might* be stateful and *might* be stateless depending on how they are used.
For example, here's one way to write a 32-bit latch in Verilog:

```verilog
module latch (
  input  wire        en,
  input  wire [31:0] data_in,
  output reg  [31:0] data_out
);
  always @(*) begin
    if (en)
      data_out = data_in;
  end
endmodule
```

There's an input data port, an output data port, and a 1-bit *enable* signal that decides whether the latch should take on a new value.
The Verilog semantics say that `data_out` must be stateful *because it is assigned conditionally*.
That is, because `data_out` doesn't get assigned on cycles when `en == 0`, it keeps its old value---implying that it requires a stateful circuit for its implementation.
Verilog engineers call this an "inferred latch."[^reg]

[^reg]: It would be reasonable to guess that the `reg` keyword means that `data_out` is stored in a register. That's not the case. `reg` declares mutable variables that can be either combinational or stateful, depending on how they're used.

The footgun here is that it's disturbingly easy to accidentally create a latch.
Consider this contrived implementation of an XOR gate:

```verilog
module funny_xor (
  input   wire [1:0] in_bits,
  output  reg        out
);
  always @(*) begin
    if (in_bits == 2'b00)
      out = 1'b0;
    else if (in_bits == 2'b01)
      out = 1'b1;
    else if (in_bits == 2'b10)
      out = 1'b1;
    else if (in_bits == 2'b11)
      out = 1'b0;
  end
endmodule
```

This module takes its two inputs on a single 2-bit port, `in_bits`.
This circuit is stateless because our `else if` cascade covers all the cases:
`out` is assigned in every situation.

But what happens if you forget one of these cases?
For example, let's delete these two lines:

```verilog
else if (in_bits == 2'b10)
  out = 1'b1;
```

The module is now stateful, and the hardware implementation requires a latch circuit.
Spooky.

### Nonsense Semantics for X

HDLs typically need a way to represent *don't-care* values, usually written as `X`.
A little like undefined behavior ([in a good way][ralfj]), `X` lets you convey to the optimizer that your specification only covers certain cases, and that it's free to do what it wants in others.

[ralfj]: https://www.ralfj.de/blog/2021/11/18/ub-good-idea.html

While `X` is a good and useful idea, Verilog's semantics for it don't make sense.
Here's how it *should* work: `X` represents a bit that *might* be 0 or 1, and we don't know which.[^top]
By that definition, it would make sense that `X` would propagate through Verilog's math operators, like this:

```verilog
module optimism1;
  reg [31:0] in;
  reg [31:0] out;

  initial begin
    in = 32'bx;
    $display("in  = %d", in);

    out = in * 2 + 4;
    $display("out = %d", out);
  end
endmodule
```

And indeed, simulating this module shows that `out` is also a *don't care* value, just like `in`:

```
$ iverilog optimism1.v && ./a.out
in  =          x
out =          x
```

All is right with the world.
Verilog also has a ternary operator, and we can try using `X` in its condition:

```verilog
out = (in * 2 + 4) > 42 ? 32'b1 : 32'b0;
```

Gratefully, the result of an undefined condition is itself `X`:

```
$ iverilog optimism2.v && ./a.out
in  =          x
out =          X
```

Because `out` might be 1 and it might be 0, it's sensible that our simulator reports is value is `X`.
Let's go one step farther and rewrite that ternary operator using the long-form `if` equivalent:

```verilog
if ((in * 2 + 4) > 42)
  out = 32'b1;
else
  out = 32'b0;
```

And try simulating again:

```
$ iverilog optimism3.v && ./a.out
in  =          x
out =          0
```

[Wat.][wat]

This footgun has a name: *X-optimism*.
That's the standard behavior for Verilog: `if` treats `X` as false, which *incorrectly* makes conditional assignments appear defined when they are actually unknown.
Tragically, this behavior was [apparently intentional][hopl]:

> This optimistic behavior of if-else was a deliberate decision by Moorby. He realized that in such a procedural context, evaluating both sides of the if-else expression could be enormously complicated. Reducing optimism requires execution time in the simulator.

Feel free to call me a PL nerd for saying this, but I don't think simulation performance is a good justification for broken semantics.

Unsurprisingly, researchers have explore how X optimism can lead to [sneaky security problems][krieg] because your simulator lies to you about what how final circuit will behave.

[krieg]: https://dl.acm.org/doi/10.1145/3061639.3062328
[wat]: https://www.destroyallsoftware.com/talks/wat

[^top]: In lattice terms, `X` should work like a *top* element.

### Timing Trouble

TK stole this example from the Filament paper...

```verilog
module Mul32 (
  input  wire [31:0] in_a,
  input  wire [31:0] in_b,
  output reg  [31:0] out,
);
  // ...
endmodule

module Add32 (
  input  wire [31:0] in_a,
  input  wire [31:0] in_b,
  output reg  [31:0] out
);
  // ...
endmodule

module alu (
  input  wire [31:0] in_a,
  input  wire [31:0] in_b,
  input  wire        op,
  output reg  [31:0] out
);
  wire [31:0] add_out;
  wire [31:0] mul_out;

  Add32 add (.in_a(in_a), .in_b(in_b), .out(add_out));
  Mul32 mul (.in_a(in_a), .in_b(in_b), .out(mul_out));

  always @(*) begin
    out = (op == 1'b0) ? add_out : mul_out;
  end
endmodule
```

TK mention Filament; details in future post...
