---
title: "Time for New Journals"
kind: article
layout: post
excerpt:
    Computer science conferences have shortcomings that many of us in the community are motivated to solve. One alternative to reforming conferences incrementally is to start alternative venues. New, lightweight, open-access journals could provide a proving ground for publishing-model ideas. It's a risky prospect, but it's a risk worth taking.
---
A favorite conversation topic at computer science conferences is griping about computer science conferences. While we may not agree on the specifics, everyone seems to concur that the list of shortcomings is long.

The most popular complaints range from the ambitiously idealistic to the mundanely bureaucratic:

* Nondeterministic reviewer assignment makes authors play [Whac-A-Mole][wam] with wildly shifting criticisms from submission to resubmission.
* Secret reviews and high per-PC-member load incentivize shoddy reviewing.
* The latency from submission to presentation---typically six months or more---is too long.
* Once-a-year conference deadlines incur undue tolls on grad-student stress levels compared to monthly review cycles.
* Overhead from [ACM][] or [IEEE][] affiliation precludes reasonably priced open-access publication. ("How much can it possibly cost to serve a bunch of PDFs?")

[acm]: http://www.acm.org
[ieee]: http://www.ieee.org/index.html
[wam]: http://en.wikipedia.org/wiki/Whac-A-Mole#Colloquial_usage

These issues, in some combination, have appeared at every conference business meeting I've attended. Unsurprisingly, the system is slow to change. Innovation is risky and requires time investment; steering committees are understandably risk-averse and populated by busy senior faculty. Some prominent people on the publishing side [don't believe there is a problem][vardioa].

[vardioa]: http://cacm.acm.org/magazines/2014/8/177025-openism-ipism-fundamentalism-and-pragmatism/fulltext

We should keep pushing for incremental change within the current system. At the same time, there's room for a different approach. We can attack the stagnation from the outside in: we can start something new. The new thing will need to start from scratch with earning attention and credibility, but it could break with tradition more rapidly.

We should take inspiration from other sciences that have been more proactive in adopting new publication norms: [the arXiv][arxiv] for preprints, open-access journals like [the Forum of Mathematics][forum], and---closer to home---[VLDB][], a notable computer science exception to conference conservatism.

[arxiv]: http://arxiv.org
[forum]: http://journals.cambridge.org/forumofmathematics
[vldb]: http://www.vldb.org

## A Lightweight, Independent, Open-Access Journal

It's time for new, independent journals. An Web-only journal has low overhead, in both time and money, and can work as an experiment for new ideas in publishing.

If I were to start a new journal today, it would look like this:

* Fast reviewing cycle: a monthly or rolling deadline, with a decision promised in one month. Decisions are four-valued: reject, major revisions, minor revisions, accept. *Major revisions* means you can resubmit and we'll make an effort to assign you the same reviewers who recommended the revisions.
* Broad reviewing base: as with a conference's external review committee, we select the best matches from a long list of volunteers who expect to be contacted only occasionally.
* No meddling: unlike most current journals, we do not copy-edit or meticulously format. We post PDFs exactly as the authors upload them. Instead, the journal could accompany papers with their reviews, an editorial introduction, or moderated public comments.
* ["Diamond" open access][diamond]: free to publish, free to read. Web hosting is our only real cost; this is minuscule, easily covered by a sponsor university or grants.

[diamond]: https://gowers.wordpress.com/2013/01/16/why-ive-also-joined-the-good-guys/

The goal of these design decisions is to keep the notional new journal *lightweight:* to avoid the conservatism and overheads intrinsic to established venues.

##  Next Steps

Starting a new journal poses clear risks. It will need to address the chicken-and-egg problem of credibility: authors will submit and reviewers will volunteer only if the venue seems worthwhile. The time commitment will initially be dubious for such an untested idea.

But one challenge I don't worry about is infrastructure. The [tools][github] [we][jekyll] [need][s3] to build a Web-based review and dissemination system are free, high quality, and open source. The baggage of [Manuscript Central][mc] is eminently avoidable and [reliable hosting][s3] is [cheaper][do] than ever.

[github]: https://github.com
[jekyll]: http://jekyllrb.com
[s3]: https://aws.amazon.com/s3/
[mc]: https://mc.manuscriptcentral.com/
[do]: https://www.digitalocean.com

The project is risky, but as researchers we should be familiar with long bets.

I want to hear from other computer scientists: What are your favorite complaints about the conference system? What could we build that would sidestep them? How can a new, lightweight publication venue achieve relevance? I know you have great ideas---please [get in touch][email].

[email]: mailto:asampson@cs.washington.edu
