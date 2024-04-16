---
title: Research
layout: longy
blurb: |
    My research is on computer architecture and programming languages.
    I am particularly enthusiastic about rethinking hardware--software abstractions.
    For current projects, see the research happening in [my research group, Capra](https://capra.cs.cornell.edu).
---

## Publications

[Look me up at DBLP][dblp] for another view on my publications.

Some of the links below are to the ACM database (so they can affect the ACM's popularity statistics). Use the "local PDF" links if you prefer to bypass this
rigmarole.

The slides linked below are PDF files. Keynote files are available on request.
(I don't have PowerPoint versions; sorry.)

[dblp]: http://www.informatik.uni-trier.de/~ley/db/indices/a-tree/s/Sampson:Adrian.html

### Conference Papers

<ul>
{% for paper in site.data.pubs %}
    {% if paper.type == 'conference' %}
        {% include paper_human.html %}
    {% endif %}
{% endfor %}
</ul>

### Workshop Papers

<ul>
{% for paper in site.data.pubs %}
    {% if paper.type == 'workshop' %}
        {% include paper_human.html %}
    {% endif %}
{% endfor %}
</ul>

### Other Stuff

<ul>
{% for paper in site.data.pubs %}
    {% if paper.type != 'conference' and paper.type != 'workshop' %}
        {% include paper_human.html %}
    {% endif %}
{% endfor %}
</ul>

---

## Approximate Computing

Trade-offs between efficiency and accuracy are fundamental in many computing domains: graphics, vision, machine learning, compression, scientific computing, physical simulation, etc. *Approximate computing* is the idea that we can design systems that take advantage of these trade-offs and unlock efficiency gains that are impossible under fully precise execution.

Approximate computing spans the entire system stack, from hardware to applications. Approximate architectures expose new accuracy and reliability knobs; approximate compilers add new optimizations that carefully break program semantics; and programming languages constrain the impact of approximation.

My dissertation, [*Hardware and Software for Approximate Computing*][dissertation], surveys the approximate-computing research landscape.

While I'm still interested in approximate computing, I haven't worked directly on it for a bit.
I have been focusing on other topics with a similar flavor: rethinking hardware--software abstractions with techniques from programming languages and architecture.
You can see the latest on [the site for Capra, my research group](https://capra.cs.cornell.edu).

[dissertation]: {{site.base}}/media/dissertation.pdf
