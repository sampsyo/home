---
title: Spectacular
excerpt: |
    Excerpt.
---
[Spectre][] has [nerdsniped][xkcd356] me, hard. I've been walking into lampposts and stuff. The more I think about it, the less I understand it.

[xkcd356]: https://xkcd.com/356/
[spectre]: https://spectreattack.com/spectre.pdf

The first shocking thing is that, once you read about it, the problem is so easy to see. Here’s how I’d summarize it: predictor state is untrusted, and mispredicted execution paths can leave traces in the memory system, so malicious code can observe the behavior of “impossible” paths. It's a fundamental problem in an idea that's been [architectural gospel][speculation] for decades. It's one of those obvious-in-retrospect epiphanies that makes me rethink everything.

The second thing is that it’s not just about speculation. We now live in a world where side channels might exist in microarchitecture that leave no real trace in the architectural state. There are already papers about [leaks through prefetching][pfsc], where someone learns about your activity by observing how it affected a reverse-engineered prefetcher. You can imagine similar attacks on TLB state, store buffer coalescing, coherence protocols, and replacement policies. Suddenly, the [SMT side channel][htch] doesn't look so bad.

[pfsc]: https://dl.acm.org/citation.cfm?id=2978356
[htch]: http://www.daemonology.net/hyperthreading-considered-harmful/
[speculation]: https://books.google.com/books?id=XX69oNsazH4C&q=Speculation#v=snippet&q=Speculation&f=false

# Sufficient Conditions

But the main thing that has me mystified is how to fix it. What is the weakest possible restriction on speculation that would prevent Spectre?
There are the easier, stronger conditions:

- **Don’t speculate at all.** The problem is speculation, so disabling it—or completely isolating all of its observable effects—suffices trivially.
- **Don’t execute speculative memory operations.** Stop speculating when the predicted path reaches a load or a store. Only execute non-speculative memops.
- **Don’t execute speculative memory operations that miss in the L1.** Keep servicing speculative loads that hit in the L1 cache, because they leave no microarchitectural trace. But stop at any memop that would need to escape to the rest of the memory hierarchy.

[s5statement]: https://www.sifive.com/blog/2018/01/05/sifive-statement-on-meltdown-and-spectre/

It suffices for an architecture to do any of these things—or to pretend to do them, by rolling back the microarchitectural state when a misspeculation resolves, for example. These are big hammers, but maybe this where the Spectre will end. Maybe processor designers will stop speculating through L1 misses, take the performance L, and move on.

But I can't help feeling that these conditions are still too strong. Or at least that they could be made weaker, if an efficient enforcement implementation can be found.

- memops that happen regardless of speculation are OK
- memops that only disclose that speculation happened (e.g., constant accesses) are OK

# Semantically Consistent Speculation

- semantically consistent. For example if we knew a lower bound on the length. If we can prove for a memop that its address cannot ever falsify the prediction assumption—there is no valuation to the unknown values (like the bound) that would contradict the address being that, it’s OK.

tk This is nonsense. 

# The Bright Side

Like many architects, I see an upside too: maybe this shock will be enough to hasten richer interfaces to hardware and software, where perhaps programs can communicate richer security policies than incremental ISA extensions would allow. Maybe it will even hasten the end of the von Neumann abstraction: one story of Spectre says that it was obscured because of the disconnect between a traditional ISA and a high-performance implementation. Maybe it's time to expose a more detailed model of how modern processing actually works so software has a chance in hell to audit it for security. Dormant VLIW and EDGE boosters, rejoice.