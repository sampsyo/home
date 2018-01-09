---
title: Spectacular
excerpt: |
    Excerpt.
---
[Spectre][] has [nerdsniped][xkcd356] me, hard. I've been walking into lampposts and stuff. The more I think about it, the less I understand it.

[xkcd356]: https://xkcd.com/356/
[spectre]: https://spectreattack.com/spectre.pdf

The thing is that the problem is so easy to see once you hear it explained. And it's a fundamental problem in an idea that's been around for decades. A bread-and-butter tool architects have used since long before I was an architect. It's one of those obvious-in-retrospect epiphanies that makes me rethink everything.

The other thing is that it’s not just about speculation. We now live in a world where side channels might exist in microarchitecture that leave no real trace in the architectural state. There are already papers about [leaks through prefetching][pfsc]---someone learns about your activity by observing how it affected a reverse-engineered prefetcher. Imagine similar attacks on TLB state, branch predictor state, store buffer coalescing, and coherence protocols. Suddenly, the [SMT side channel][tk] doesn't look so bad.

[pfsc]: https://dl.acm.org/citation.cfm?id=2978356

# Sufficient Conditions

The main thing that has me mystified is what a minimal architectural fix would be: what’s the least amount of speculation you could give up and still prevent side channels through memory activity triggered by speculative code?
I think this is a hard question to answer even just with that limited scope, ignoring the whole world of other, non-speculation-related microarchitectural side channels.

Let's do the easy ones first. Microarch need to either enforce, or appear to enforce:

- no speculation
- no speculative memops
- no speculative memops that miss in the L1

And maybe that's where this will end. Maybe processor designers will stop speculating through L1 misses, take this performance L, and move on.

But I can't help feeling that these conditions are still too strong. Or at least that they could be made weaker, if an efficient enforcement implementation can be found.

- memops that happen regardless of speculation are OK
- memops that only disclose that speculation happened (e.g., constant accesses) are OK

# Semantically Consistent Speculation

- semantically consistent. For example if we knew a lower bound on the length. If we can prove for a memop that its address cannot ever falsify the prediction assumption—there is no valuation to the unknown values (like the bound) that would contradict the address being that, it’s OK.

tk This is nonsense. 

# The Bright Side

Like many architects, I see an upside too: maybe this shock will be enough to hasten richer interfaces to hardware and software, where perhaps programs can communicate richer security policies than incremental ISA extensions would allow. Maybe it will even hasten the end of the von Neumann abstraction: one story of Spectre says that it was obscured because of the disconnect between a traditional ISA and a high-performance implementation. Maybe it's time to expose a more detailed model of how modern processing actually works so software has a chance in hell to audit it for security. Dormant VLIW and EDGE boosters, rejoice.