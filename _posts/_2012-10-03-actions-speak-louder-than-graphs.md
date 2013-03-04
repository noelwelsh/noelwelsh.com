---
layout: post
title: "Actions Speak Louder than Graphs"
description: "The big data value chain and why you need to move up it."
category: streaming-algorithms
tags: [business, ml, big-data, streaming-algorithms, online-learning]
---
{% include JB/setup %}

Attending Strata reinforced my view that the big data field is still focused on the least valuable data analysis. Way back in 2000 I worked at Touch Clarity and one of our main features was an analytics system much like Google Analytics today. Back in 2000 this kind of stuff was new and exciting, and customers loved it (more so than the personalisation features we were actually trying to sell!) Over a decade later at Strata it seemed the field hasn't really moved forward. The major of vendors and people I talked to were still concerned with data collection and running simple aggregation queries on it.

This is the least valuable segment of the data value chain. The kinds of results you get (e.g. "53% of our visitors came from Facebook") don't lead directly to improvements. Aggregations are not generally meaningful without further analysis. Pointless dashboards, vanity metrics which brings me to the next segment, classification.

Classification involves finding how some variable of interest (e.g. purchasing) is affected by some other input variables (e.g. referrer). Finding that only 25% of visitors from Facebook go on to purchase, while 60% of organic search visitors do is an example of a classification result. There is a blurry line between aggregation and classification for simple examples like this, but consider the case where you have tens or hundreds of input variables. Aggregation fails here, and you need to use statistical techniques like logistic regression to find interesting patterns in the data.

Classification and aggregation techniques are still only producing reports that someone must later do something about. Acting -- closing the feedback loop with automated systems -- is the final step of the value chain. Here machine learning techniques like bandit algorithms and reinforcement learning are appropriate.

The reason acting is such an improvement over classification and aggregation is the same reason you start funding your retirement early: the amazing power of compound interest. Automated systems can iterate much faster than systems with a human in the loop. Each iteration might get some small incremental gain, and over time these small gains will compound together.

This is the reason we created [Myna](http://mynaweb.com/), to replace the batch (classification) approach of A/B testing with an automated feedback loop.

Web analytics have been around for at least a decade but the field continues to evolve. New software offerings and the rise of the data scientist all point to growth, but I believe the field is still focused on the least valuable data analysis.

Funadmentally, the majority of the field is still focused on summarising data, typically ny producing graphical displays of these summaries. The posterchild of this is the web dashboard, de rigeur in all hip Internet companies.

Summarising data is the least valuable thing you can do with it after throwing it away. Simply summarising data still requires the user interpret it, so next up the value chain is classifying the data. Which would you rather see, summaries of user behaviour, or the key differences in behaviour between users that convert and those that don't? But the value chain doesn't end with classification -- the next stop is action. I'm not talking about providing "actionable insights" for the monthly board meeting. I'm talking about intelligent systems taking automated actions to improve conversion and increase retention.

Right now some of you are thinking that we have to have a human in the loop to stop the machine doing something stupid. I agree -- to an extent. Creating the possible actions requires creativity and insight that only humans possess, but if A/B testing has taught us anything is that's we're really bad at predicting how things will play out with real customers. Far better to leave this choice up to the machine, which can make real-time decisions in response to customers' actions far more effectively than any person. The compounding rate of return from a tight, automated feedback loop guarantees a win over any system that requires manual intervention.

In case you think this is science fiction, this is exactly what recommender systems do every day at Netflix, LinkedIn, Amazon, and others. Similar techniques drive the choice of headline story at Yahoo and other major news sites. The technology exists, it just isn't widely available. Democratising access to this technology is exactly why we created [Myna](http://mynaweb.com/).

It's time to stop summarising and start acting.
