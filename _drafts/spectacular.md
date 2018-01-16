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

## Sufficient Conditions

But the main thing that has me mystified is how to fix it. What is the weakest possible restriction on speculation that would prevent Spectre?
There are the easier, stronger conditions:

- **Don’t speculate at all.** The problem is speculation, so disabling it—or completely isolating all of its observable effects—suffices trivially.
- **Don’t execute speculative memory operations.** Stop speculating when the predicted path reaches a load or a store. Only execute non-speculative memops.
- **Don’t execute speculative memory operations that miss in the L1.** Keep servicing speculative loads that hit in the L1 cache, because they leave no microarchitectural trace. But stop at any memop that would need to escape to the rest of the memory hierarchy. The [SiFive blog][s5statement], for example, says that all their RISC-V parts obey this limitation.

[s5statement]: https://www.sifive.com/blog/2018/01/05/sifive-statement-on-meltdown-and-spectre/

It suffices for an architecture to do any of these things—or to pretend to do them, by rolling back the microarchitectural state when a misspeculation resolves, for example. These are big hammers, but maybe this where the Spectre will end. Maybe processor designers will stop speculating through L1 misses, take the performance L, and move on.

But I have a feeling that these restrictions are too strong. There are some situations where speculative misses *should* be safe to service, if the hardware could detect them:

- **Foregone conclusions** are a trivial case that should be safe. If a memop would be executed on either side of a branch, executing it speculatively should disclose nothing that the attacker wouldn’t learn anyway. For example, consider a condition `if (b) x = *p; else y = *p;`. The program will load the pointer `p` regardless of `b`, so loading it speculatively will cause no state leaks that wouldn’t be caused by a non-speculative execution. Of course, loading `*p` before the branch resolves isn’t really speculative at all in this case: the program will need the result in either case, so a good compiler should just hoist the load above the branch anyway.
- Missing on **constant addresses** should be safe, because they only disclose the predictor’s behavior. And one of Spectre’s main lessons is that predictor state is untrustworthy and under the attacker’s control anyway. For example, consider an attack on an indirect jump that convinces the CPU to speculatively execute the attacker’s own malicious code. If that code executes `ld 0xDEADBEEF`, the attacker can learn only that their attack was successful by measuring the time to access that fixed address. Problems only arise when the maliciously speculative memop accesses an address based on private data.
- In general, enforcing **noninterference for non-speculative state** seems to suffice. Speculative execution can safely compute new addresses for loads—as long as those speculative addresses would be the same under any starting, non-speculative state. If a CPU could somehow prove that a speculative memop accesses an address whose provenance is exclusively speculative, it could be certain that executing it will leak no useful information.

Each of these conditions is an exception to the “no speculative misses” rule. Piecemeal exceptions are unsatisfying, though. I’m suspicious that there’s a clean, general rule for deciding which speculative accesses are safe. Even if that sufficient condition is wildly impractical to enforce in hardware, we should nail it down.

## An Insufficient Fix

One tempting mitigation is to isolate the predictor state. The proof-of-concept attacks we know about rely on the attacker’s ability to manipulate the predictor into mispredicting in useful ways. Without BTB collisions, malicious code would not be able to “mistrain” the predictor to bend it to its will. For example, consider an architecture that flushes the BTB or swaps its state when transitioning between trusted and untrusted code. The untrusted code can execute as many cleverly-crafted branches as it likes, but only trusted-code branches can influence trusted-code predictions.



## The Bright Side

Like many architects, I see an upside too: maybe this shock will be enough to hasten richer interfaces to hardware and software, where perhaps programs can communicate richer security policies than incremental ISA extensions would allow. Maybe it will even hasten the end of the von Neumann abstraction: one story of Spectre says that it was obscured because of the disconnect between a traditional ISA and a high-performance implementation. Maybe it's time to expose a more detailed model of how modern processing actually works so software has a chance in hell to audit it for security. Dormant VLIW and EDGE boosters, rejoice.