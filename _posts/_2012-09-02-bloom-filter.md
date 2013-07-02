---
layout: post
title: "The Bloom Filter"
description: "A simple general-purpose "
category: data
tags: [ml, big-data, streaming-algorithms, online-learning]
---
{% include JB/setup %}

In a [previous post](http://noelwelsh.com/streaming-algorithms/2012/08/29/lean-data/) I laid out my manifesto: *lean data, not Big Data!* In this post I'm going to show you how to storm the battlements.

In less hyperbolic terms, I'm looking at ways of handling big data that don't require equally big computing resources. Today I'm going to look at a data structure known as the [Bloom filter](http://en.wikipedia.org/wiki/Bloom_filter).

The Bloom filter is a set. It allows us to answer questions like "have I seen this user already this week?" or "does this file contain the data I'm looking for?" A hash table is the standard way to implement a set. It is fast but inefficient with space, requiring one hash (usually 32-bits) per element in addition to storing the actual elements to guard against hash collision[^overhead]. The best practical case is storing integers, where we'd need 64-bits (the integer and the hash) per element. In a Bloom filter we can get away with about 7 bits per element, a 9 times improvement, if we accept a false positive rate of about 0.01. That is, we will sometimes say that an element is a member of the Bloom filter when in fact it has not previously been added. Note we never say an element is not a member of the Bloom filter when in fact it is.

[^overhead]: Most implementations will use some constact factor more than this. In contrast a Bloom filter typically doesn't add any additional constant factor overhead.

The Bloom filter is based on a [bit set](http://en.wikipedia.org/wiki/Bit_array), so let's quickly go over that. It we have *m* items in the set we can number them from 0 to *m*-1 and represent the set using just *m* bits. In practice we don't know exactly which items we're going to see so we can't arrange to give them sequential numbers. Instead we might use a hash function to map our elements into our *m* available slots.

Now we run the risk of collisions -- more than one element might end up mapped to the same slot. The key idea of the Bloom filter is to use more than one hash function.


This allows us to make more interesting tradeoffs between space consumption and false positive rate.
