---
title: "Approximate Storage"
kind: article
layout: post
excerpt: |
    I gave a talk at [MICRO][] earlier this month on the next step in our work on [approximate computing][approx]. And in an effort to attain immortal YouTube fame, I recorded a [conference talk video][video], which may be the most boring 20 minutes on the Internet.

    [approx]: /research.html
    [micro]: http://www.microarch.org/micro46/
    [video]: http://www.youtube.com/watch?v=YCoGNXSSMJo
---
I recently had the privilege of presenting our latest paper on [approximate computing][approx] at [MICRO 2013][micro] in Davis. This newest bit of work expands the scope of approximation beyond just computation itself---it follows the community's recent work on trading off accuracy for efficiency in CPUs, GPUs, and other accelerators. We wanted to demonstrate that the approximation paradigm (if you'll forgive the business-school word) is relevant in other components too: in particular, in storage systems.

Today's memory and mass storage devices hold a lot of error-tolerant data. If you look at what's filling up your smartphone's flash memory, for example, it's likely dominated by photos and music---stored in media formats that already trade off quality for size. On the opposite end of the computing spectrum, datacenter-scale machine learning systems aggregate huge amounts of fast memory but are resilient to occasional errors in the stored data.

Our project proposes [approximate storage][paper]: an abstraction and a set of techniques that exploit these kinds of error-tolerant data---in both main memory and persistent, disk-like storage---to make memories better. In particular, we wanted to exploit the unique properties of [*phase-change memory* (PCM)][pcm], an upcoming replacement for disk, flash, and potentially DRAM, to address some of its drawbacks. While PCM promises to solve [DRAM's scaling woes][dramscale] and [vastly outpace flash SSDs][pcmspeed], it has two significant pitfalls: dense multi-level PCM is slow and power-hungry compared to DRAM, and the memory has a finite lifetime---it eventually wears out. Approximation can help address both problems. By allowing sloppier writes, we can make PCM faster and denser. And by recycling failed memory blocks that otherwise would need to be thrown away, we can make devices last longer even as parts of them begin to fail.

[dramscale]: http://research.microsoft.com/apps/pubs/default.aspx?id=79150
[pcmspeed]: http://arstechnica.com/science/2012/06/write-speeds-for-phase-change-memory-reach-record-limits/
[pcm]: http://en.wikipedia.org/wiki/Phase-change_memory

We simulated both of these strategies using a variety of approximate programs and error-resilient data sets. On average, we found that approximate writes to be 1.7x faster than precise writes and that failed-block recycling extends the useful device lifetime by 27%.

## An Experiment and a Terrible Video

You can read [our paper][paper] if you're interested in the technical details. But if you'd prefer to hear me try to explain them, I'm trying something new this time.

Like all grad students, I spend a lot of time preparing conference talks. These talks are our only chance to demonstrate our honest, hopelessly nerdy excitement for the work we conduct otherwise mostly in solitude. As sentimental as it sounds, the conference setting really does make research feel vital---the right "pitchman" can make you pay attention to a great paper you'd otherwise pass over.

But in our community, conference talks are a one-time affair. Recording is not common practice, so the only option is to physically fly to conferences. Whenever I miss a conference, I wish for video. (Almost as good as actually attending, and much better coffee!)

In an endeavor to make this a reality, here's my first [conference talk video][video]. I recorded it while the real thing was still fresh in my mind to simulate the nerve-obliterating conference experience. The audio quality is not great and my delivery is pretty terrible, but it's a start. [Let me know][email] what you think---I'd like to make a routine out of this and I'm interested in feedback about how to make these videos as useful as possible.

<div class="embed">
<iframe width="560" height="315" src="//www.youtube.com/embed/YCoGNXSSMJo" frameborder="0" allowfullscreen></iframe>
</div>

[approx]: /research.html
[micro]: http://www.microarch.org/micro46/
[video]: http://www.youtube.com/watch?v=YCoGNXSSMJo
[paper]: http://dl.acm.org/citation.cfm?id=2540708.2540712
[email]: mailto:asampson@cs.washington.edu
