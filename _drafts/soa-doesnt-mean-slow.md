---
layout: post
title: SOA doesn't mean slow
description: Just because you're using service oriented architecture doesn't mean your latency has to get out of control.
category: programming
tags:
list_cta:
repost: underscore
---

Let's talk about a typical web architecture. Stateless web servers connecting to a database. Simple. Database does all the hard work of controlling concurrency.

SOA, or service oriented architecture, is becoming increasingly popular. There are several reasons

- scale development teams [link]
- scale database, particularly writes
- scale processing

Three things

- latency inversely proportional to $s
- network trip is orders of magnitude slower than function call (Haywire, ~5ms. Real systems from 10-300ms.)
- modern computers are pretty powerful

So let's take a typical example. Most sites have authentication and authorization. We could split this out into a service. Virtually every call is going to go via this service. Good job us; we've just added 50ms of latency to our application.

Why does a separate service have to run on a separate box? How many users are we going to have? Only exceptional cases have more than thousands. This easily fits on a box. How about we put an instnace of our authentication service -- database and code -- onto every box that runs a web server? Let's even put it into the same codebase, so it's just a function call. Now we're fast again.

So we have multiple copies of our authentication service running. We have a different problem now, which is one of *consistency*. Different instances of our authentication service many end up believing different things who and how our users can login. Let's say someone changes their password. One of our instances gets updated. We have to propagate this change to all instances of our authentication service is running. And changes can happen concurrently, so we have to account for that. This sounds difficult, but it's not. It's just different. No-one thinks twice about using a relational database. We need to use a different database technology in this case. It's newer and less well known than relational DBs, but there is extensive operational usage of this technology and it works.

This technology is known as
