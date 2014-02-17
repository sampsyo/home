---
title: "Green Clouds"
kind: article
layout: post
excerpt: |
    [Janet Tu writes in the Seattle Times today][times] about a new [Greenpeace
    report][report] analyzing the use of renewable energy in data centers (or,
    as they put it, "the cloud"). I provided a couple of comments for the Times
    story and I'll expand a little bit here on the importance and feasibility
    of improving energy efficiency in a cloud-centric world.

    [report]: http://www.greenpeace.org/international/Global/international/publications/climate/2012/iCoal/HowCleanisYourCloud.pdf
    [times]: http://seattletimes.nwsource.com/html/businesstechnology/2017997234_greenpeace18.html
---
[Janet Tu writes in the Seattle Times today][times] about a new [Greenpeace report][report] analyzing the use of renewable energy in data centers (or, as they put it, "the cloud"). I provided a couple of comments for the Times story and I'll expand a little bit here on the importance and feasibility of improving energy efficiency in a cloud-centric world.

While energy efficiency is a hot topic in computer architecture currently, environmental impact is not. With [notable exceptions][hpasplos], academics focus on other motivations for efficiency: cost, cooling, battery life, and fundamental power density limits. But [computers consume a large portion of the world's energy][data center energy], so it's important to recognize that computational efficiency can have an impact on climate change and other negative effects of energy consumption.

"Cloud" energy consumption is particularly relevant from this perspective. Personal computing is currently undergoing a shift from mostly local (on-device) computation to a local--remote hybrid model. Gmail, Siri, Google Docs, iCloud, and Office 365 all rely on data center computation in cooperation with local devices. (Academic proposals like [MAUI][] and [Pocket Cloudlets][] follow the same trend.) Modern personal computers, from laptops to iPhones, spend energy from two different sources: energy from their batteries and energy "in the cloud". You can be energy-conscious---buy green energy from your utility and choose modern, low-power devices---while remaining unaware of the energy you're using in data centers.

[maui]: http://research.microsoft.com/en-us/um/people/alecw/mobisys-2010.pdf
[pocket cloudlets]: http://www.princeton.edu/~ekoukoum/papers/Koukoumidis_Pocket_Cloudlets_ASPLOS_2011.pdf

So Greenpeace is right to highlight the sustainability of cloud infrastructures. But, in doing so, the report conflates two different aspects of the cloud energy problem: *sourcing* and *efficiency*. The report's quantitative analysis mainly examines the cloud providers' renewable energy sources, but efficiency---the amount of energy used in the first place---is arguably the more important long-term issue for sustainability.

When we think in terms of efficiency, the picture becomes more complex than who's-buying-what-from-whom. For example, the report  (rightly) praises Facebook for focusing on its servers' energy efficiency as demonstrated by its [Open Compute Project][open compute], but Facebook is not the only provider working aggressively on energy efficiency. In fact, cloud computing consolidates lots of work---the work that we would once have done on desktops in our houses---into data centers where a single company foots the bill for the energy used by that work. So cloud providers like Amazon and Microsoft have a powerful incentive to reduce their energy consumption and they take computational efficiency very seriously. This is one of the great benefits of cloud computing: you can let the experts at Microsoft or Rackspace focus on energy efficiency while you focus on the work you need to do. As [Amazon told Tu for the Times article][times], "cloud" computing is probably intrinsically more energy-efficient than operating many independent server rooms.

The advantages of cloud consolidation apply to sourcing as well as efficiency.
[Apple is building massive on-site solar arrays][apple solar] to power its North Carolina and (upcoming) Oregon data centers. It's much easier for Apple to convert iCloud to run on a private solar array than it is to mobilize millions of homes to do the same---which would be necessary in a pre-cloud world where most computational work is local.

It's also important to realize that much of the responsibility for energy-efficient computation lies with hardware designers rather than data center operators. Greenpeace doesn't mention the role played by chip designers---Intel, AMD, IBM, and Oracle---in the energy consumption of clouds. Hardware design is at least as important as the deployment decisions made by cloud providers.

Energy efficiency is a critical aspect of computing's transition to a cloud-centric model---for environmental reasons as well as others---and Greenpeace's report helps bring the issue into the public eye. In the long term, however, individual companies' power sourcing decisions are likely to be less important than the fundamental efficiency of computers. Computer architecture research needs to focus on issues like server energy proportionality, energy-based accounting, and energy-aware programming to address the need for efficient computing. The economic realities of cloud computing are such that cloud providers are incentivized to adopt innovations that curb energy consumption, so this is an area where we as researchers can hope for significant real-world impact.


[report]: http://www.greenpeace.org/international/Global/international/publications/climate/2012/iCoal/HowCleanisYourCloud.pdf
[times]: http://seattletimes.nwsource.com/html/businesstechnology/2017997234_greenpeace18.html
[open compute]: http://opencompute.org/
[hpasplos]: http://dl.acm.org/citation.cfm?id=2150976.2150980
[apple solar]: http://arstechnica.com/apple/news/2012/02/apple-confirms-plans-for-oregon-data-center-outlines-green-initiatives.ars
[data center energy]: http://iopscience.iop.org/1748-9326/3/3/034008/
