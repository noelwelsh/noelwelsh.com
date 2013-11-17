---
layout: post
title: "CRDTs for fun and eventual profit"
description: ""
category: programming
lead:
---

At [Velocity](http://velocityconf.com/velocityeu2013/public/schedule/detail/31058) I gave a talk on conflict-free replicated datatypes, or CRDTs for short. To be honest it wasn't the best received talk I have ever given. It was my first time at Velocity and I misjudged the audience. Nonetheless I think the material is interesting so here I want to attempt to weave a better story for CRDTs.

CRDTs are a way of handling replicated or distributed data. What is distributed data? It just means data that is copied to many machines. As soon as we have such a distributed system we have to think about what happens when our data changes. We can decide that all machines will be aware of all changes.  That is, we can maintain *consistency*. This is nice because it means we never deal with out-of-date data, but it requires every change to be sent to every machine before it is considered complete. If a machine (or the network) goes down we must refuse updates because we can't ensure everyone has seen every update, and thus we can't maintain consistency .

We can instead prefer *availability*, meaning we'll just soldier one if machines go down, but this does mean we will end up with the same piece of data having different values on different machines. In other words our data will become inconsistent. CRDTs allow us to recover a particular type of consistency, called eventual consistency, without a great deal of work. With CRDTs we will be able to merge different copies of our data together without issue, and if we merge all copies together we are guaranteed to arrive at the correct value everywhere.

So, why not just enforce consistency? I've given one argument above: to have a site that doesn't go down. There are more good reasons. The one I presented at Velocity is to reduce latency.

Studies by [Google](http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/34439.pdf) and [many others](http://highscalability.com/latency-everywhere-and-it-costs-you-sales-how-crush-it) have shown that increased latency correlates directly with user abandonment. In other words, slow web sites make less money.
