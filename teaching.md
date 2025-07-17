---
title: Teaching
layout: shorty
---
{% assign teaching = site.data.cv.teaching | first %}
{% assign classes = teaching.classes %}

{% for class in classes %}{% if class.current %}
I am teaching:
{% break %}{% endif %}{% endfor %}

{% for class in classes %}{% if class.current %}
* {% if class.link %}[{% endif %}{{class.term}}: {{class.number}}, "{{class.title}}."{% if class.link %}]({{class.link}}){% endif %} {{class.desc}}{% endif %}{% endfor %}

{% for class in classes %}{% if class.future %}
I will teach:
{% break %}{% endif %}{% endfor %}

{% for class in classes %}{% if class.future %}
* {% if class.link %}[{% endif %}{{class.term}}: {{class.number}}, "{{class.title}}."{% if class.link %}]({{class.link}}){% endif %} {{class.desc}}{% endif %}{% endfor %}

I previously taught:

{% for class in classes %}{% unless class.future or class.current %}
* {% if class.link %}[{% endif %}{{class.term}}: {{class.number}}, "{{class.title}}."{% if class.link %}]({{class.link}}){% endif %} {{class.desc}}{% endunless %}{% endfor %}
