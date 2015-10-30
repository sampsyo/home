---
title: Research
layout: longy
blurb: |
    My research is on hardware--software abstractions. It includes computer architecture, programming languages, compilers, and software engineering.
---

## Approximate Computing

Trade-offs between efficiency and accuracy are fundamental in many computing domains: graphics, vision, machine learning, compression, scientific computing, physical simulation, etc. *Approximate computing* is the idea that we can design systems that take advantage of these trade-offs and unlock efficiency gains that are impossible under fully precise execution.

Approximate computing spans the entire system stack, from hardware to applications. Approximate architectures expose new accuracy and reliability knobs; approximate compilers add new optimizations that carefully break program semantics; and programming languages constrain the impact of approximation.

My dissertation, [*Hardware and Software for Approximate Computing*][dissertation], surveys the approximate-computing research landscape.

[dissertation]: {{site.base}}/media/dissertation.pdf

-------

## Publications

[Look me up at DBLP][dblp] for another view on my publications.

Some of the links below are to the ACM database (so they can affect the ACM's popularity statistics). Use the "local PDF" links if you prefer bypass this
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
