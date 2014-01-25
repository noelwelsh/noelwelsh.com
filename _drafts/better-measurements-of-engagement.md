---
layout: post
category: data
title: Better Measurements of Engagement
---

# Introduction:
anecdote hook. You've read this but you probably aren't going to finish ...

# Context

Before we get into details it is important to clarify that I'm talking about a site much like this one, where content is used as a brand building tool. The ultimate goal is to sell something to visitors, such as a product or consulting engagement, with intermediate steps such as signing up to a mailing list or connecting a warm fuzzy feeling to the brand. Ad-driven sites, particularly those that specialise in viral content, may have different goals due to the payment model used in ads (typically page views or clickthrough).

Form a positive impression of. This may lead to sharing.

# How Engagement is Typically Measured

# So how can we do better?

Site wide and over time.

CTA. How do you measure engagement?


Once you start blogging seriously (or start *content marketing*, to use the fancy term) it's natural to start wondering if anyone is actually reading what you write. Actually, asking people to read an article, from top to bottom, is [too much](www.slate.com/articles/technology/technology/2013/06/how_people_read_online_why_you_won_t_finish_this_article.html). But that's ok! There are many ways someone can interact with content (skimming it, if they're already familiar with the topic, reading a particular section that addresses a problem they have, and so on) and still find it valuable, so let's talk about measuring engagement instead.

Before we get into details it is important to clarify that I'm talking about a site much like this one, where content is used as a brand building tool. The ultimate goal is to sell something to visitors, such as a product or consulting engagement, with intermediate steps such as signing up to a mailing list or connecting a warm fuzzy feeling to the brand. Ad-driven sites, particularly those that specialise in viral content, may have different goals due to the payment model used in ads (typically page views or clickthrough).

Engagement should be measured on a site-wide, not page-wide, basis. Sites have different types of visitors. [Myna](http://mynaweb.com/) has marketers, data scientists, and product managers within scope, for example. Content on the inner workings of bandit algorithms (as seen in the [bandit course]({% post_url 2013-08-05-why-you-should-know-about-bandit-algorithms%})) should interest data scientists, might interest some marketers, but will probably leave product manages cold.

I'm not the first person to think about engagement. Industry standard measures are page views and average time on page (also called dwell time). A bit of thought shows that these measures aren't very useful. Page views are uninformative because a lot of people bounce straight away. Average dwell time is a few microns more useful, but again loses a lot of information

[has been well characterised](http://research.microsoft.com/apps/pubs/default.aspx?id=137655), and it is pretty much what you'd expect: a lot of people leave quickly, and progressively fewer stay for longer periods of time. That gives a bit more insight, but it still isn't enough.

Recently I've been thinking measuring engagement for content based sites, and I have come to the conclusion the standard tools aren't up to the task. Engagement is a complex concept. Ideally we'd measure it on a site-wide and long-term basis.
However in this article (which I hope you find engaging) I'm mostly going to talk about a basic building block: measuring engagement on a single page.



Analytics are useless if they don't lead to action, so let's clarify the goal first. I want to determine what topics and types of content are of interest to my audience. A concrete example helps. Consider [a post](http://underscoreconsulting.com/blog/posts/2013/12/20/scalaz-monad-transformers.html) I published on [the Underscore blog](http://underscoreconsulting.com/blog/). This received nearly 500 views, which is a lot for the Underscore blog at this point in time.

- Did some people read to the end?
- Did people skip over the code?
- Did the post get teal deered?
- Did the post make some heads explode?

I don't expect one article to appeal to all possible readers ... diversity.

So how do we currently measure engagement? The tool virtually everyone uses is Google Analytics which has by default two measures: a histogram of time on site, or the average time on page. The histogram of time on site is obviously useless for telling me about a single post. The average time on page provides a little more information. The post under discussion has an average time on page of 3:34. That seems quite good (site average is just over a minute) but it's quite a long post. So we see the first problem with time on page -- it isn't normalised for the page length. The second problem is that looking only at average loses a lot of information. See [Anscombe's Quartet](http://en.wikipedia.org/wiki/Anscombe%27s_quartet) for an elegant demonstration of the wildly different data sets that can have the same average.

It is possible to get Google Analytics to spit out the distribution of times on page but this is more work than I want to perform for this article. Luckily I don't need to do this, because the distribution of time on page [has been well characterised](http://research.microsoft.com/apps/pubs/default.aspx?id=137655), and it is pretty much what you'd expect: a lot of people leave quickly, and progressively fewer stay for longer periods of time. That gives a bit more insight, but it still isn't enough.

http://ir.mathcs.emory.edu/data/WWW2012/www2012_pcb_guo.pdf


Hits. Time on site.

But this doesn't really tell much of the story. At the very least, we should normalise time on site by the length of the page (this was quite a long post). Then we should look at

Typical measure is time on site. Google analytics. Doesn't give much insight. Different audiences. Different uses.

Hypotheses:

Time on site is related to engagement

If we measure scroll position and time at position we'll have a more useful measure.
teal dear. http://www.urbandictionary.com/define.php?term=teal%20deer

http://www.slideshare.net/mounialalmas/measuring-userengagement

http://janette-lehmann.de/index.html

http://www.dcs.gla.ac.uk/~mounia/
