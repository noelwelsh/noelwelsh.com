---
layout: post
title: "Sex, Lies, and (Server-side) Javascript"
description: ""
category: programming
tags: [node, jvm, performance]
---
{% include JB/setup %}

[This](http://aphyr.com/posts/244-context-switches-and-serialization-in-node) thoughtful investigation into the performance of Node.js versus the JVM (represented by Clojure), and the [followup](http://news.ycombinator.com/item?id=4310723) comment from Node.js creator Ryan Dahl crystallized some thoughts regarding the Node.js hype-train and its intersection with reality. Within is an old lesson that anyone seeking traction with a new product would do well to remember.

Let's start with Ryan Dahl's comment on HN, which suggests a certain amount of [cognitive dissonance](http://en.wikipedia.org/wiki/Cognitive_dissonance):

> Node is popular because it allows normal people to do high concurrency servers. ... Syntax and overall vibe are important to me. I want programming computers to be like coloring with crayons and playing with duplo blocks. If my job was keeping Twitter up, of course I'd [be] using a robust technology like the JVM. ... Node has a large number of newbie programmers. I'm proud of that; I want to make things that lots of people use.

Let's leave aside the many[^arguments] arguments we could have about these statements, and just focus on the odd internal inconsistency. Node is targeted towards new programmers, but it's popular because it makes concurrency easy. Yet strangely it isn't a good fit for high concurrency applications because it isn't robust. What to make of that?

[^arguments]: Oh so many arguments! Duplo composes, but CPS is practically the paradigmatic example of a global transformation. And on it goes.

In there lies, I believe, part of the secret of Node's success. When I look at my own usage of Node, I find I, surprisingly, use Node.js almost every day. Of course I don't write high concurency servers in Node -- I take Ryan's advice and use something robust. In fact I hardly ever write any Node code, but I do use [LessCSS](http://lesscss.org/), [Coffeescript](http://coffeescript.org/), and other little utilities that run on Node in my day-to-day work.

Javascript is a very popular language, and it's the first and possibly only language for many people. This jibes with Ryan's comment. It's natural, when you're proficient with a language, to want to apply it to many tasks. It's also natural, when you're a developer, to write lots of little scripts to do small chores[^chores]. Before Node there was no platform for Javascript developers to write these kind of programs. I'm sure some people do spend substantial time developing servers in Node, but my contention is that most Node programs are of the kind I use -- useful little utilities that get a relatively simple task done.

[^chores]: Sometimes these scripts even save the developer time!

If I'm correct, why all the noise about asynchronous blah blah blah? **Because sex sells!** Scripting languages have been around for a long time, but have often been marginalised. Every developer knows the real stuff, the sexy stuff, is crazy high performance code. So by positioning Node as a language for "high concurrency servers" it is seen as a "hard-core" platform. One can view learning Node as aspiring to reach the lofty height of high-performance guru.

This [aspirational marketing](http://en.wikipedia.org/wiki/Aspirational_brand) tactic applies to many other products as well. For example, how many car ads show driving on an empty road (or in a jungle if it's a 4x4)? How does this compare with most people's daily driving experience?



## Coda

Let's just enumerate some arguments I'm not making:

- It's not conscious. I believe the Node developers really do believe
