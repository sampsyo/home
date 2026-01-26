---
title: Failure to Adapt
---
We're about to start the spring 2026 semester, and it is no longer possible to ignore that LLMs are fundamentally changing the software industry.
I have been trying for about 18 months to come up with a way to adapt my teaching.
I have no good ideas.

The suggestion I hear most often is that CS classes should simply "level up."
We should create assignments that are much larger in scope and to ensure that they are still challenging even with unlimited LLM assistance.

For the classes I teach, I have tried and failed to conceive of a way to follow that advice.
I think it may be impossible.
For now at least, I am keeping the style of assignments in my undergrad class the same as in the pre-LLM era.

## Where I'm At

The main undergraduate class I teach these days is Cornell's required systems course, [CS 3410][].
Students learn about bits and bytes, numbers, pointers, interrupts, threads, processes, synchronization, and a tiny bit of digital design.
This kind of class usually has a lot of programming, and ours is no exception.

Coding agents can easily solve any reasonable C or assembly programming assignment I can think of for this course.
For example, one thing we've asked students to do in the past is to implement spinlock in RISC-V assembly using its [LR/SC instructions][riscv-a].
Try this in your favorite chatbot---it will likely produce a correct implementation in one shot.
I don't find this surprising at all: this kind of code must exist many times over in any LLM's training set.

Does the fact that LLMs can easily solve these problems mean that we shouldn't assign them?
I can think of two arguments for why this style of assignment should change:

1. Cheating: It's easy to do these assignments with LLM assistance, so students will do it. And they'll therefore learn nothing.
2. Practicality: In the real world, short-but-tricky code like this will always be LLM-generated. So teaching students to write code like that isn't useful anymore.

This post is an attempt to refute both arguments.

TK reorganize around these two arguments

[riscv-a]: https://www.five-embeddev.com/riscv-user-isa-manual/latest-adoc/a-st-ext
[cs 3410]: https://www.cs.cornell.edu/courses/cs3410/2024fa/

## Certificates for Principles

The problem is that my job, as I see it, is to teach the principles of computer science.
If my job were to teach marketable skills for prospective software engineers, I think the path forward would be much clearer.
The goal would roughly be to teach the processes that real software engineers use.

Teaching principles is different from teaching programming.
It's confusing because the ability to do some programming task is a *certificate* for the understanding of many of the principles I want students to learn.
In other words, the way that a student can tell that they have learned a concept is to write some code that embodies that concept.
They can approach principles by practicing implementation work.
But the principles are the point, not the programming.

For the CS principles in my classes, writing a few knotty lines of C or RISC-V assembly is an excellent certificate.
I can't think of a way that prompting LLMs to produce code could ever be an adequate certificate.

Let's assume we believe that, within three years, hand-writing any lines of C, Rust, or assembly will be an antiquated hobby for old people, and that Claude Code does all the work in the real world.
That wouldn't change this fact:
LLM-powered software engineering is a bad certificate.

## An Example

One topic students in CS 3410 learn is about call stacks and calling conventions.
A good certificate for understanding this stuff is that you can implement functions and call them in assembly.

TK some code

It was *never* the case that we believed that our students were likely to write lots of RISC-V assembly in their future careers.
The ability to implement and call functions is not a learning objective in itself.
But doing it, and getting a confusing error, and debugging your assembly, and eventually seeing it work is all good *practice* for learning the concept.
It was historically convenient that this practice used to resemble something like software engineering, but it was always just practice.

The thing I've been struggling with since last year is that *I can't think of anything resembling LLM-powered software engineering* that is nearly as good.

TK thought experiment with the example above

## Mediocre Ideas

I said above I have no good ideas.
Here are my mediocre ideas:

* Put a lot more grade weight on in-person, on-paper exams.
* Try to persuade students that they should not use LLMs for their programming coursework.

The latter takes the form of making the arguments in this post clearly and frequently to students.
It may be impossible to convince most 20-year-olds of all this, but I'm going to try anyway.

The former is a sad concession to make: I would rather students spend more time with hands-on programming and less time preparing for written puzzles.
But alas, my university still assigns grades, and my students still care about them way too much.
Exam-heavy weighting is a way to give them some of what they want:
an assessment scheme that will psychologically encourage them to put in the work.

Grades are a pretty miserable system anyway.
So here' an optimistic take: maybe
pervasive [homework machines][shel] will make it clear that an adversarial model of classrooms and assessment was always ridiculous.
If your model casts professors as the homework cops,
and students as their natural enemies who ought to stop at nothing to maximize their grades as long as they don't get caught,
then that's a terrible model for learning.
The availability of LLMs makes cheating *so easy* that maybe we'll eventually have to do away with grades entirely.
We'll need to shift toward a model built on trust, where students take responsibility for what they hope to get out of college.
I can dream, anyway.

[shel]: https://kottke.org/25/12/the-imperfect-homework-machine

## The Existential Question

This post is about how to teach computer science principles, assuming students want that.
There's a separate question about whether we even need people to know CS principles anymore.
I'm happy to let other people argue about that one.
If we don't, then I can quit my job and look for an apprenticeship at a bakery.
