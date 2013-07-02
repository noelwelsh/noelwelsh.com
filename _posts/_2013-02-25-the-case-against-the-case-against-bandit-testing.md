---
layout: post
title: "The case against the case against bandit testing"
description: "No really, bandits work."
category: data
tags: [ml, big-data, online-learning, bandit]
---
{% include JB/setup %}

Dan McKinley, Principal Engineeer at Etsy, recently posted (The Case Against Bandit Testing)[http://mcfunley.com/the-case-against-bandit-testing]. While is some ways a good post (it quotes me several times) I believe it overgeneralises from Etsy's experience and makes a few incorrect assumptions about how bandit algorithms work. Let me attempt to address them.

The post starts innocently enough. Dan sets out to tell us why Etsy doesn't use bandit testing. Now if we restrict the discussion to Etsy, any reasons Dan gives are valid. Maybe Etsy doesn't use bandits because they don't like the name, or they already have enough money, or they heard that everyone else was and they want to be different. Their company their rules. However by the end of this first section Dan has already expanded the scope of discussion to make general comments about bandit testing.

## Traffic Police

The first argument Dan advances concerns Etsy's continuous deployment principle. I think I can summarise the argument as follows:

1. Etsy deploys lots of feature variants in parallel.
2. Errors in feature variants that don't receive significant traffic will go unnoticed.
3. Bandit testing will send small amounts of traffic to underperforming variants *forever*.
4. Thus, Etsy won't be able tell to if variants are underperforming because they suck or because they are broken.

(I have no idea how to interpret the Venn diagram.)

I'm not going to challenge points one or two. That's all Etsy specific stuff I have no place commenting on. However, I can offer some insight into point three.

When we talk about bandit algorithms we generally focus on algorithms for minimising expected regret. In plain(er) speak, this means the goal is to minimise on average the number of times we choose a sub-optimal variant when we assume we're going to run the algorithm forever. This assumption is important because it means we can try every variant infinitely often in the infinite time available, and thus eventually becomes absolutely positively certain which variant is best. In practice we don't have infinite time but a few hundred thousand views a good enough approximation.

Another problem people have considered is finding with high probability the best *k* variants in as few views as possible. When we don't have infinite time we can only find the best variant(s) with high probability. We will get it wrong sometimes, just like traditional A/B testing will. So, slightly different setup and thus slightly different algorithms. I could give you a few bazillion cites on ways to solve this problem, but I'll restrict myself to [one](https://www.cs.utexas.edu/~shivaram/papers/ks_icml_2010.pdf).

There are various reasons to prefer one problem setup over another. It Etsy's case it seems they'd prefer this second problem setup, as each variant will receive relatively high traffic until it is eliminated.


## Regularized Accounting

Dan's next argument mixes up issues with infrastructure and testing methodology.
Let's try to tease them out.

Dan makes various claims about the complexity of infrastructure to support bandit testing. I don't really want to get into this argument, because it depends a lot on your existing infrastructure and so on. My only point is this: if you have already built the infrastructure it's no extra work. That's what [Myna](http://mynaweb.com) is.

Credit assigment

Reward allocation


## Runaways Gone Fishing

## No Regrets

This argument indicates a misunderstanding of bandit algorithms.

## In Closing

There are more things in heaven and earth than are dreamt of in your philosophy.
