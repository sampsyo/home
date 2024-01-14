---
title: 'What is Register-Transfer Level Design, Exactly?'
---
In our lab, we are deeply dissatisfied with mainstream hardware description languages (HDLs).
One problem among many is that the core semantic foundation for mainstream HDLs is so slippery.

Verilog, VHDL, [Chisel][], [Amaranth][], and most other popular HDLs are *register-transfer level* (RTL) languages.
Or another way of putting it is that these languages all clearly have something in common, and that thing tends to get called "the RTL abstraction."
However, I think it's troubling that it's hard to describe what that abstraction is:
if you boil away all the details of a specific RTL language, what do you have left?
What is the core semantic foundation that all of these languages build on?

[Is there room for an analogy here? I have a pretty clear idea of the rough outline of any "virtual machine" for CPU machine code. A list of instructions, places to put them (virtual registers), jumps/branches for control flow, probably functions… but what that abstract language looks like for RTL HDLs is less clear]

[Show the stack: RTL above netlist above physical layout.]

I'm convinced that a big reason why the concept of "RTL design" is so unclear is the popularity of Verilog and Verilog-like HDLs.
The problem is that Verilog supports a *lot* of different programming styles, and it's often hard to tell where one ends and another begins.
So while everyone can agree that Verilog supports both RTL and non-RTL design, there's a lot less agreement about exactly which subset of Verilog is the RTL language.

[Collect some existing definitions that are floating out there.]
The one thing that seems to be universal is that RTL is a higher level of abstraction than a netlist, but it's not a *lot* higher:
it's about one notch up on some abstraction meter.
[Do sources often say that going RTL->netlist is logic synthesis?]

What I'm interested in is: what must a language have to make it qualify as an RTL language?
What is the common semantic model for how we should think about RTL programs, as distinct from netlists?

Here's a proposal:
RTL is all about *synchronous digital logic*, which means it's about clock cycles.
Stuff only happens at discrete points in time, and real time is irrelevant.
So, *an RTL program specifies a function for computing the state of all registers in cycle N+1 based on the state of all registers in cycle N*.

Contrast between RTL and netlists:

* netlists are about “what is connected to what” (structural). RTL is about “how to compute the values of registers” [this is too fuzzy, it's just an overview]
* The thing is, under this proposal, *you cannot construct a flip-flop in RTL*; the registers have to be given to you.
  And that is really really not true in Verilog... the existence of registers is weird and implicit.
* Maybe netlists are not directional?? Just wires... whereas RTL needs assignments "to" values.

The thing is, *I don’t think Verilog is a particularly good example of the RTL paradigm.*
So in detecting the essence of RTL, we can be led astray.

---

A big part of the problem is the way the *register-transfer level* (RTL) abstraction gets implemented in actual programming languages.
RTL is a little hard to describe directly, but
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
[Actually, there is "The Essence of Verilog"... but it takes a subtractive approach, and as previously mentioned, Verilog is not a great example of RTL, paradoxically.)
I don't know if we have agreement about what "essential RTL semantics" actually consist of.

One way of answering this question is imagine an *intermediate language* that any RTL language could share.
In fact, we don't even have to imagine it; these ILs for RTL design already exist.
FIRRTL, Yosys RTLIL, LGraph/LNAST.
[Somewhere in here: some extra context about why I care about this, which is that we are writing a lot of compilers that produce hardware, and they definitely want to produce something like RTL (so they are not, by default, in the logic synthesis game), but producing Verilog basically sucks. What would a good target language look like for those high-level languages? Maybe it's one of these existing ILs, but I want to understand their semantics better.]
[Link to "readable Verilog is a non-goal". We want a non-RTL target language. In practice, we currently emit a little ad hoc IL made out of a tiny fragment of Verilog; this is not great.]

[On the other hand, you could imagine that all these high-level languages should just be targeting netlists directly... but I think that's a bad idea! RTL is useful! It's a really valuable place to target! Embraces the clock cycle abstraction, sits above logic synthesis (which is super useful) nicely. Natural fit for simulation, again if what you want is synchronous digital logic (only care about the values in each clock cycle, not in between).]

What should it be? Basically, the embodiment of "synchronous digital logic"...
* logical time (clock cycles) only
* registers are "special"
* the program is something that computes the next state of all registers based on the previous state (and the previous state only)

Some things that are definitely not essential:
* metaprogramming
* the specific "control" constructs, if/while

beyond RTL:
* Bluespec: guarded assignments semantics, as epitomized in ["The Essence of Bluespec"][koika]
* [DFiant][]: data flow semantics

...but I think all of these are best thought of as *compiling to* RTL.
That is, I think RTL deserves its position in the hardware compiler stack as the abstraction layer just above the netlist (the input to synthesis)... it's just that this representation should not be Verilog.

[amaranth]: https://github.com/amaranth-lang/amaranth
[dfiant]: https://dl.acm.org/doi/10.1145/3373087.3375377
[koika]: https://dl.acm.org/doi/10.1145/3385412.3385965
[lambdajs]: https://cs.brown.edu/~sk/Publications/Papers/Published/gsk-essence-javascript/
