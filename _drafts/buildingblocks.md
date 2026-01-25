---
title: Back to the Building Blocks' Building Blocks
---
<aside>
This post is based on a keynote I gave at <a href="https://www.dagstuhl.de/26042/">Dagstuhl Seminar #26042, <i>Trustworthy System Architectures for the Age of Custom Silicon</i></a>. Many thanks to the seminar's organizers and to the Dagstuhl staff for a fun and enlightening few days.
</aside>

If there are hardware engineers who love Verilog, I haven't met them.
Almost universally, the attitude toward Verilog seems to be that it's frustrating, ridiculous, error-prone, and the only pragmatic choice.

Verilog is inescapable because it is the input format to essentially every EDA tool.
Its centrality means that it is a <i>de facto</i> intermediate representation implementing for every other HDL:
even if you prefer [Bluespec][], [Chisel][], [Amaranth][], or [Spade][], they all have to compile to Verilog for practical reasons to interact with the rest of the hardware world.

I am worried that Verilog's flaws will be the cause of a new wave of hardware bugs.
There is an analogy to the problems with C and C++:
as designing custom hardware becomes more popular, we risk allowing a dangerous HDL to proliferate and fester in the same way that memory-unsafe programming languages have in software.

I don't know yet what the analog of memory safety is for hardware bugs, or even if there will be a single dominant defect category.
Footguns abound in Verilog, though, so there are many candidates.
This post makes the case that we should invest in better understanding the problems with Verilog so that future HDLs can avoid them.

[chisel]: https://www.chisel-lang.org
[bluespec]: https://github.com/B-Lang-org/bsc
[amaranth]: https://amaranth-lang.org/
[spade]: https://spade-lang.org

## On Building Blocks

For American programming languages nerds,
["Back to the Building Blocks"][bbb] was one of the most exciting things to happen in recent memory.
It's a 2024 report from the White House Office of the National Cyber Director that argued the importance of memory safety.
It called for critical infrastructure to move on from memory-unsafe languages like C and C++ and even mentioned [Rust][] by name as a promising alternative.

"Back to the Building Blocks" didn't break new ground:
by 2024, it was obvious to most right-thinking people that memory safety was a huge problem.
It was exciting because *Joe Biden* was saying the things that we had all been saying for years.[^biden]
The report distilled a hard-to-refute syllogism along these lines:

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

I'll state my thesis in a weak form and a strong form; you can pick which level you agree with.
The weak form is:

> Verilog causes lots of bugs.

And the strong form is:

> The next "Building Blocks" crisis will happen in hardware, and it will be Verilog's fault.

In other words: as we begin to get a handle on memory safety,
the next scourge of avoidable-seeming bugs will occur in hardware designs.
Better HDLs could dramatically reduce the frequency of these bugs.

TK why isn't this already a crisis?
because of centralized monolithic waterfall design processes with extremely heavyweight verification efforts.
that will probably continue to be the case for big, high-volume CPU and GPUs.
but in the "age of custom silicon," more people will want to design more individualized hardware more cheaply... so we're in for trouble.

## Some Cheap Criticisms of Verilog

TK the bigger point is that we need work that understands what problems among the giant heap of trouble in Verilog causes bugs most often.
but I couldn't resist dunking a bit...
these are not necessarily the most important problems; they're just the funniest (or most self-serving)

* Verilog is an event-based simulation language that accidentally became an HDL. (This is the original sin.)
* There is an ill-defined "synthesizable" subset. Tools can't agree on what this subset is, but we can all agree that there _is_ some subset of Verilog that is safe to use when designing hardware (as opposed to simulations or testbenches).
* Load-bearing linters. Practical Verilog design shops have to license... TK
* Inferred latches. (See below.)
* The semantics of `X` are broken. (See below.)
* Cycle-level timing information goes in the comments. (See below.)

### Inferred Latches

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

that's combinational, but removing a case makes it stateful

TK also in VHDL

### X Optimism

* `optimism1.v`: start with `32'd5` to show math working, then introduce X/don't care; it is very necessary for allowing optimizations when you need to be insensitive to certain signals
* `optimism2.v`: show it working fine with ternary
* `optimism3.v`: show it breaking with if
* this is "objectively" wrong. in my PL classes, I tell students…
* paper reference. explain how this leads to a simulation/real disagreement. this X is _actually_ going to be either a 0 or a 1


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

```
$ iverilog optimism1.v && ./a.out
in  =          x
out =          x
```

```verilog
module optimism2;
  reg [31:0] in;
  reg [31:0] out;

  initial begin
    in = 32'bx;
    $display("in  = %d", in);

    out = (in * 2 + 4) > 42 ? 32'b1 : 32'b0;
    $display("out = %d", out);
  end
endmodule
```

```
$ iverilog optimism2.v && ./a.out
in  =          x
out =          X
```

```verilog
module optimism3;
  reg [31:0] in;
  reg [31:0] out;

  initial begin
    in = 32'bx;
    $display("in  = %d", in);

    if ((in * 2 + 4) > 42)
      out = 32'b1;
    else
      out = 32'b0;
    $display("out = %d", out);
  end
endmodule
```

```
$ iverilog optimism3.v && ./a.out
in  =          x
out =          0
```

TK unsurprisingly, this can lead to [sneaky security problems][krieg]

[krieg]: https://dl.acm.org/doi/10.1145/3061639.3062328

TK also in VHDL

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
