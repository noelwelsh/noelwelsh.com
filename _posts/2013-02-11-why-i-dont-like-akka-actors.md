---
layout: post
title: "Why I Don't Like Akka Actors"
description: ""
category:
tags: []
---
{% include JB/setup %}

We recently rewrote [Myna's](http://www.mynaweb.com/) back-end service. The architecture changed dramatically, and it now both faster and easier to extend. One of the significant architectural changes was removing all [Akka](http://akka.io) [actors](http://en.wikipedia.org/wiki/Actor_model). Having used them extensively in the first version of the back-end, I have come to prefer other methods of managing concurrency. Since Akka's actors are so prominent within the Scala community I thought it might be of interest to describe my objections to actors in Scala.


## Actors are Coarse Abstractions

If you fully embrace the actor world view, they are all you need for concurrent programming. That is, they present as a unifying abstraction for concurrency, in the same way that Scala unifies Java's primitive and object types into just objects, or Python tries to represent all values as mutable dictionaries.

The problem with these unifying abstractions is that they hide important distinctions. For example, CPUs make a sharp distinction between primitive types (fit in a register, most operations complete in a single cycle) and objects (accessing typically requires a pointer dereference, operations take many cycles). Scala gets away with this for the most part through clever compilation in both the Scala compiler and Hotspot[^Python].

[^Python]: Python basically does nothing about this issue, which is why it's so slow. In fact this decision is one big reason it's so hard to optimise Python. I know about [PyPy](http://www.pypy.org/). It has taken about 8 years and several million currency units to get where it is today.

Concurrent programming involves at least three distinct concerns: concurrency, mutual exclusion, and synchronisation. With actors the first two always come combined, and you're left to hand-roll your own synchronisation through custom message protocols. It's an unhappy state of affairs if you want to do something as simple as separating control of concurrency and mutual exclusion. This is not an esoteric concern -- it is exactly what a [ConcurrentHashMap](http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ConcurrentHashMap.html) provides, for example. If you're really seeking performance then you probably want to use [lock-free algorithms](http://en.wikipedia.org/wiki/Non-blocking_algorithm). Again, these don't fit into the actor model. So basically the actor model is forcing us to give up a lot of tools so we can fit within its rigid conception of a concurrent program.


## Actors do not Compose

Composition is a desireable property of abstractions. Functions compose. If I create some functions, say, plus and minus, you can create another function, say multiply, that uses my functions. In particular I don't have to anticipate your usage ahead of time to allow you to use my functions.

Actors don't compose. By default actors hard-code the receiver of any messages they send. If I create an actor A that sends a message to actor B, and you want to change the receiver to actor C you are basically out of luck. If you're lucky I anticipated this in advance and made it configurable, but more likely you have to change the source. Lack of composition makes it difficult to create big systems out of small ones.


## Akka's Actors are not Usefully Typed

Akka's actors give you static typing within a single actor, but the communication between actors -- the complex bits that are most likely to go wrong -- are not typed in any useful manner. I could live with the above two issues, but this one really gets me.

For me the type system is the point of Scala; otherwise I'd use JRuby or something. Akka supports a number of features, such as [become](http://nurkiewicz.blogspot.co.uk/2012/11/becomeunbecome-discovering-akka.html) and transparent distribution, that make statically typing messages difficult. This is the wrong tradeoff as far as I'm concerned. Other languages, like Concurrent ML and Haskell, have demonstrated it's possible to have great concurrent and distributed programming abstractions in a statically typed language. I expect the same in Scala.


## So What Does Myna Use?

So given the above, what does Myna use? We use Akka's Futures, which I think are fantastic,
