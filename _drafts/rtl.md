---
title: 'What is Register-Transfer Level Design, Exactly?'
---
In our lab, we are deeply dissatisfied with mainstream hardware description languages (HDLs).
A big part of the problem is the way the *register-transfer level* (RTL) abstraction gets implemented in actual programming languages.
RTL is a little hard to describe directly, but
Verilog, VHDL, [Chisel][], [PyMTL][], [Amaranth][], and most other popular HDLs all embody the RTL abstraction in one way or another.
My complaint, though, is that it's really hard to isolate the core semantic foundation for the RTL abstraction and to separate it from the long tail of weird features that make up a complete HDL.

[Maybe a diagram here showing RTL in the abstraction stack, below high-level languages and above netlist and physical layout? The point here is that we want to keep this abstraction stack, but dispense with Verilog. The semantics of a netlist are very clear, and the semantics of a high-level language can be made clear. What's missing is an intermediate non-Verilog step that has good, understandable semantics... as an interface between any high-level language and synthesis tools, to describe the job of synthesis.]

Let's pick specifically on Verilog, which is arguably the worst offender in this morass of semantic muddiness.
It's not all the fault of Verilog itself---part of the problem is social, in the way Verilog has taken on a *de facto* role as the universal language for all hardware design tasks.
To many, "RTL language" means "Verilog-like language"; there is no daylight between the fundamental concept and the full complexity of Verilog itself.

TK can we show an example of how Verilog makes this confusing?
Maybe the ability to write things that are not very "RTL"y in Verilog...
* something very behavioral, simulator-y
* something that seems to have to do with physical time
* combinational cycles
* obvious metaprogramming that is not separate from the object program

[To do this, we probably want to define what a "netlist" is. Seems pretty straightforward... and then something about `+` having different meanings in RTL (part of an abstract function definition) vs. a netlist (a physical instantiation of an adder circuit, wired up to other stuff.]

Anyway, I would like to know what the core semantic model is that we should have in mind for RTL languages.
That means identifying the features of these languages that are "essential," which is a weaselword that just means "probably common to any language like it, no matter how simple."
(Maybe a good example is [LambdaJS][].)
I don't know if we have agreement about what "essential RTL semantics" actually consist of.

One way of answering this question is imagine an *intermediate language* that any RTL language could share.
In fact, we don't even have to imagine it; these ILs for RTL design already exist.
FIRRTL, Yosys RTLIL, LGraph/LNAST.
[Somewhere in here: some extra context about why I care about this, which is that we are writing a lot of compilers that produce hardware, and they definitely want to produce something like RTL (so they are not, by default, in the logic synthesis game), but producing Verilog basically sucks. What would a good target language look like for those high-level languages? Maybe it's one of these existing ILs, but I want to understand their semantics better.]

What should it be? Basically, the embodiment of "synchronous digital logic"...
* logical time (clock cycles) only
* registers are "special"
* the program is something that computes the next state of all registers based on the previous state (and the previous state only)

Some things that are definitely not essential:
* metaprogramming

beyond RTL:
* Bluespec: guarded assignments semantics, as epitomized in ["The Essence of Bluespec"][koika]
* [DFiant][]: data flow semantics

...but I think all of these are best thought of as *compiling to* RTL.
That is, I think RTL deserves its position in the hardware compiler stack as the abstraction layer just above the netlist (the input to synthesis)... it's just that this representation should not be Verilog.

[amaranth]: https://github.com/amaranth-lang/amaranth
[dfiant]: https://dl.acm.org/doi/10.1145/3373087.3375377
[koika]: https://dl.acm.org/doi/10.1145/3385412.3385965
[lambdajs]: https://cs.brown.edu/~sk/Publications/Papers/Published/gsk-essence-javascript/
