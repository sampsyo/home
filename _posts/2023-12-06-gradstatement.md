---
title: Critiquing a PhD Application Statement
excerpt: |
    I offer some feedback on a thoroughly mid statement of purpose for PhD applications from fifteen years ago.
---
My [best advice][grad-post] for applying to grad school is to get feedback on your statement. Let's see what that feedback might look like by critiquing [a sample statement][sop]. I'll quote the full text verbatim, as it was submitted in 2008.

> When I saw my mother after I heard my first NP-completeness proof in my Sophomore-year algorithms course, she asked how my classes were going.

This is a worrisome start. This draft makes two classic mistakes right out of the gate:

1. Resist the temptation to open with a cute anecdote. To the extent they convey anything, little personal stories like this mainly serve to illustrate your enthusiasm—but everyone applying to CS PhD programs is enthusiastic about CS (I hope). Spend the space instead showing off your experience, interests, and expertise, which are what make you unique.
2. It really helps for the first few sentences to help readers quickly "route" your application. That means writing, clearly and early on, which research areas you like. These areas can be broad, like "systems" or "theory," and they help people know who should pay attention.

> My first instinct, of course, was to relate to my mom---a public school child psychologist with a math phobia---the bizarre and thrilling tale of NP-completeness. Her hesitant acknowledgements and supportive but bewildered face betrayed that my explanation needed some work. That curious, surprised face, however, reminded me of my own astonishment at a host of earlier concepts that now seem basic: asymptotic complexity, self-balancing search trees, functional programming, and a litany of others. The repeated feeling of surprise, intrigue, and elation has marked time as I have become entranced with computer science.

I recommend cutting this whole paragraph. The anecdote doesn't add much, and---worse---the topics you mention are both pretty basic and fairly scattershot. Again, this story can really only illustrate that you _like CS in general_, not anything about your specific interests or past experience. That latter, more individual stuff is what potential advisors want to know about.

> My experiences with research and tutoring as an undergraduate have focused my intent to pursue a career in CS. I am applying to the PhD program in CS at the University of Washington in order to eventually become a professor.

This is too generic. It's not necessarily a bad idea to say what career you eventually want, but these sentences are otherwise a no-op. Consider replacing this with specificity about the research areas you hope to work in.

> My first major research was part of an NSF Research Experience for Undergraduates project after my sophomore year. I worked with two other students and Professor Ran Libeskind-Hadas on algorithm design and complexity analysis in the realm of optical network routing. My colleagues and I started with very little direction, defined our own research area, and constructed a solution start-to-finish. This was my first encounter with the intricacies of constructive, undirected theoretical research and my first large-scale technical writing project.

We are finally talking about research. It's helpful that you have given the context for the project and given credit to other students who worked on it with you. However, this summary is missing two big things:

* Any specifics about what the research project was actually about. You presumably learned something about how to frame and "sell" your research during this project; put that into action here. Tell the reader about the problem, its importance, and your solution. By clearly describing the research contribution, you will not only illustrate your experience but also show off your ability to _discuss_ research.
* A specific description of your role in the project. It's good to know that you worked with two other students on this project, but which part of it was "yours"? The original ideas, the algorithmic development, the complexity analysis, the experimental results, or something else? Be specific.

> Our paper, "On-line Distributed Traffic Grooming," was accepted to the IEEE Communications Society's 2008 International Conference on Communications. I traveled to Beijing with Professor Libeskind-Hadas to present it. I prepared the presentation with the help of Professor Libeskind-Hadas but was the sole presenter.

It's useful to know that you have experience with preparing and giving conference talks. But this could be reduced to one sentence. You can just cite the paper to convey where it was published to anyone who might care and delete the part about traveling to Beijing, which doesn't matter.

> The experience exposed the unique difficulty of designing presentations that keep theoretical topics tenable and interesting for an uninitiated audience.

This is pretty generic; I'd cut it. As a general rule, I recommend removing most of the stuff in this statement that talks about your _reactions to_ your experience unless you have something truly unique to add. The problem with this stuff is that it's usually obvious: these are exactly the things that everybody learns when giving their first talk. You can use the space you'll recover to say things that distinguish you from other applicants.

> My enthusiasm for this first project ensured that I would pursue research constantly throughout the remainder of my career at Harvey Mudd.

Most statements about enthusiasm are not helpful: we hope most people applying to grad school are enthusiastic about research. Skip it.

> I pursued an independent research project with Professor Robert Keller on neural-network techniques for automated processing of structured text. I identified a problem called "adaptive parsing": the interpretation of certain kinds of grammars with minimal knowledge of the grammars themselves. I constructed and implemented a technique based on rival-penalized competitive learning to accomplish a basic adaptive parsing task. Working alone with occasional advice from my advisor, I was entirely responsible for the framing of my problem and the construction of my solution.

This research-project summary is better than the last one; you've told us what the problem was and how you approach it. You even have a sentence in there specifically describing your role. Nice work! The problem description still goes by pretty quickly, though; another sentence or two could make it clearer why this work matters.

I'd probably add a citation for "rival-penalized competitive learning" because this technique is not common knowledge. (If it were *k*-means or whatever, you wouldn't need to cite it.)

> While the experience was challenging, I proved to myself that I had the motivation required to produce something I consider significant.

You can delete this sentence, which is another somewhat generic "my reaction" statement.

> More recently, I've conducted research in two fields distant from theory and machine learning: computer security and filesystems. The first, conducted under the supervision of Professor Everett Bull at Pomona College, examined the security implications of a unique storage system called Venti. I proposed a succinct, low-overhead method for implementing capabilities-based security in the system.

It's a good start, but this needs more detail. What is Venti? A citation would be helpful, but please also describe whatever is salient about Venti and what makes security interesting or different in this setting. Otherwise, it's hard to tell what you actually did, i.e., what experience you have that may be relevant to your time in grad school.

> During the same time period, I worked with Professor Geoff Kuenning on the structural complications of filesystems with interfaces based on arbitrary, unstructured metadata ("tags") rather than directory hierarchies. I applied the canonical disk-layout techniques from the Berkeley Fast Filesystem (FFS) to outline a filesystem optimized for tag-based storage.

This sounds like a pretty wild project! I think you may be underselling the "big idea" a little bit. Are you really proposing to replace hierarchical directory-based filesystems with something else entirely? That's a radical change, and you could amp up the marketing here to make sound as radical as it is.

Also, I'm not sure what you mean by "structural complications"; maybe you can think of a more specific thing to say here.

> The project exposed me to the intricacies of constructive systems research. An enormous range of considerations, from interface to low-level data structures, had to be identified and carefully analyzed in order to create a coherent and useful proposal.

The passive voice obscures your role in the project. Instead of focusing on this somewhat vague "lesson" that you learned, it would be more helpful to write down what you actually did for this project. Did you implement a whole filesystem? Did you do any performance experiments? Be specific about your concrete work, which will help potential advisors understand what you're capable of.

> My positive experiences with this wide range of research were enough to convince me to investigate graduate school in CS. During my REU project in particular, it was exhilarating to have intellectual pursuit as my primary day-to-day responsibility, to spend eight hours a day talking to my research team and coming away every day feeling like we invented something clever and insightful.

This is more "reaction" stuff; I'd cut it.

> Aside from research, however, my experiences with tutoring both in computer science and in writing have further solidified my intention to become a professor. I have tutored for Harvey Mudd's CS department and worked as a consultant for the Writing Center for three years. My success in these areas has suggested that I am able to communicate abstract ideas clearly. As a writing consultant, I constantly reflect on the infinite complexities of writing and how to best inspire the same considerations in other students. This year, four other consultants and I presented at the 2008 National Conference on Peer Tutoring in Writing on the relationships between tutoring styles for technical and non-technical exposition. This experience has motivated me to think of teaching, alongside research, as an end goal for my career.

It's interesting that you have this other experience and I'm glad you included it. Teaching and writing are both big parts of grad school, so any "extracurricular" background you have on these themes is relevant. It also helps explain why you say you want an academic career.

I'm not sure about the "my success" sentence. You haven't actually shown us specific successes here. It might be better to just let the reader decide what this experience suggests you are able to do.

> As evidenced by the diversity of my research endeavors, upper-division electives have not helped at all to narrow my enthusiasm for computer science. Every time I take a new course---in filesystems, in complexity theory, in computer security---I plan out a new path through graduate school in another subfield. Only intense consideration has led me to narrow my aspirations to the fields I find most fascinating: theory and systems. While I am fascinated by both of these fields individually, I also see possibility in studying in their intersection.

Move this direct statement of your research interests to the top so it's easier to find.

While I think it's awesome that you have such broad CS interests, I admit I'm a little concerned about the emphasis you place on that here. I can imagine some readers being confused enough by this generality that they don't see themselves as potential advisors for you. I'd consider leading with the specific areas, and briefly mention this breadth of interest but don't spend much ink on it.

Remember that a grad app statement is not a contract. It's pretty common for PhD students to change their focus after they start. (Maybe you'll get interested in programming languages or computer architecture; who knows?) Being specific for the sake of specificity will help you show off your technical depth better, even if the choice is somewhat arbitrary.

> I want to attend the University of Washington because it is a large university with outstanding programs in many subfields. If I find that systems-based research is not my favorite research area, for instance, UW also has an exceptional theory group. Not only is the department top-ranked, but it also comes highly recommended from professors I trust and respect. At a large, diverse, and highly-ranked school like UW, I anticipate opportunities to explore many research areas before committing to one.

This is a weird paragraph. "Large university," while accurate, isn't exactly a distinguishing feature of UW. And while it's also true that a big department affords you the opportunity to change your mind, this doesn't seem all that relevant to the committee deciding whether or not to admit you. Maybe just cut this stuff because it doesn't add much?

> For instance, I am intrigued by Professor Paul Beame's research on modern data structures. His work highlights the interactions between theory and systems by examining the algorithmic implications of realistic instruction sets. This intersection between two disparate fields is attractive for its combination of two different ways of reasoning about the same set of problems. I am applying to UW because of the wide variety of compelling research opportunities like Professor Beame's.

It's a good idea to briefly mention the professors you might want to work with at each school. It's also nice that you found someone with research that nominally combines two of your interests.

I recommend adding a few more professors. Including a handful of names will again help "route" your application to the right set of readers. Some names to consider here might include Luis Ceze and Dan Grossman, for example.

---

Well, it's a start! I recommended a few places where you can cut, especially some material that doesn't feel very unique to you. Hopefully you can use the extra space to add more technical detail about your past work, which will help readers understand your experience better. Remember, your past research experience is probably the most important factor readers will be looking for.

Good luck! I don't know if this statement will get you into UW, but if it does, I'm sure it will be a great place to pursue your PhD.

[grad-post]: {{site.url}}/blog/gradschool.html
[sop]: {{site.url}}/media/sop.pdf
