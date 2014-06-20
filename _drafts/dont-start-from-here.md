---
layout: post
title: Don't Start From Here
description: Choosing the right technology makes everything easier
category: programming
tags:
list_cta:
repost: underscore
---

There's an old joke that goes something like this: A young couple are going on holiday to the village of Scratchy Bottom. The village is poorly signposted and the couple are soon hopelessly lost. They pull over at a farmhouse and ask for directions. The farmer thinks for a while, scratches his head, and replies "Oooh arrr, well to get to Scratchy Bottom I wouldn't start from 'ere."

I often feel the same way when ... If you start from the right place everything is easier.

Take for example a Ruby on Rails project I've worked on. This system makes extensive use of a MySQL database to queue events for later processing[^rdbms-queue]. On average it takes over 300ms to enqueue an event, about evenly split in processing time between Ruby and the database. Some load testing of the project showed a 99.9% page rendering time of over 9s.

[^rdbms-queue]: It's a fairly dubious decision to use a relational database to store a queue, and this decision caused problems for maintainers (i.e. me), but it's not the focus of this essay.

Compare this to [Myna](http://mynaweb.com), another system I've worked on. Its 99.9% response time is about 10ms. It takes the Rails system 30 times longer to enqueue an event to perform a task at a later date than it takes Myna to actually do something right now.

Another example: I recently read a post about a startup's scaling challenges. They were handling 5000 requests *per minute* at peak load, and created a complex distributed system to handle this.

Returning again to Myna, in our load testing we pushed 650 requests *per second* through a single CPU on a shared VM with no noticable degradation of performance. I don't know how high we could have gone. There was no point doing further benchmarking as we were already well over the peak load we'd experienced in practice.

The point is not to brag about Myna, but to offer a point of comparison. This level of performance is easily achievable; we haven't made any particular effort to optimise Myna. We just did two things right: we choose fast components to start with, and combined them in a sensible way.

I want to focus on the first point: the choice of technology. Myna is written in Scala. The other examples I talked about above are written in Ruby and PHP respectively. Scala runs on the JVM, and depending on the task the JVM is 2-100x faster than Ruby and PHP.

This point is borne out in web performance comparisons. Setting the ceiling. There's no special voodoo to the JVM. Other languages can get in the same ...

Scala is not hard, but it's different. You have to learn new stuff. Scala is productive. It is just as fast to write as Ruby, while running much much faster.

One-off cost vs recurring cost.

Argument developers are expensive. Just provision another box. But it's not that simple. Distrubted systems are harder to run, harder to monitor, and harder to maintain. In the projects I've worked on the wrong choice
