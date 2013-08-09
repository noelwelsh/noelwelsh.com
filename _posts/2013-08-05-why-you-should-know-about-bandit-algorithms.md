---
layout: post
title: "Why You Should Know About Bandit Algorithms"
description: ""
category: data
tags: [bandits]
lead: I think bandit algorithms are great &mdash; so much so that I'm running a free course on them. This post trys to give a quick overview of why I feel such enthusiasm for them, and tells you how you can sign up to my free course.
---
{% include JB/setup %}

If you're a data scientist or online marketer, I want to convince you that you need to know about bandit algorithms, and you should sign up below for my course. Here's the pitch, in three easy steps:

1. All your data and metrics and analytics don't mean squat if they don't translate into action.
2. Some of the actions you take are going to work, and some are going to fail. The computer is faster and better at sorting them out than you are.
3. Bandit algorithms are the "faster and better" way of getting your computer to make decisions.

Step one should be obvious, but step two benefits from more explanation:

If you've done the numbers you'll know that sometimes your actions improve over what was there before and sometimes they don't. (If you haven't done the numbers, you're just throwing money away. Drop me an email so we can talk about this.) Sensational improvements (or failures) are going to be obvious quite early, but the much more common case is a small change that requires statistical methods to reliably distinguish. I've you've ever had to calculate stats by hand -- say in high school -- then I hope you agree that this is a job better delegated to the computer.

By far the best known statistical tests are the [t-test](https://en.wikipedia.org/wiki/Student%27s_t-test) and friends. These methods are over 100 years old! There have been a lot of advances since then. One of the most important is the development of bandit algorithms. We can view the old methods, like the t-test, as a kind of bandit algorithm. More modern methods do two things:

1. They work faster, which means you can make more improvements in a given period of time, which means more money in the bank.
2. They can be applied to a wider range of problems. For example, if you have a customer profile, there are bandit algorithms that can use that profile to personalise suggestions. Or perhaps you have rapidly changing content, like news stories, in which case you could use bandit algorithms to suggest the best articles. And so on. This also means more money in the bank.

If I've convinced you that bandit algorithms are interesting, I want to offer you a way to learn more about them. I'm presenting on bandit algorithms at the [Strata London Conference](http://strataconf.com/strataeu2013/public/schedule/detail/31019). In preparation for the talk I'm preparing accessible but in-depth material on the field. This is material that you'd have to read tens or hundreds of research papers to find for yourself. If you sign up to my mailing list you'll receive drafts of my material -- about one email a fortnight -- as I prepare it. It's a great opportunity for you to learn about bandit algorithms without trudging through the literature, so I hope you take advantage of it.
