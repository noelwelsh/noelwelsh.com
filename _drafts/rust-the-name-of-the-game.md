---
layout: post
title: Rust The Name of the Game
category: post
---

I've been attempting to learn Rust. It's an attractive language to me because it has alarge expressive width, a term I made up for languages that allow a high level of abstraction and close to the metal control.

The language is changing rapidly and the documentation is struggling to keep pace, but I think I've managed to piece together the important concepts.

To me, Rust brings three things to the table:

1. It's a modern language. It is expression oriented. It has closures and pattern matching. It doesn't have null references. Its type system has generics and type classes (but, sadly, no higher kinded types yet.) If you've used other modern typed languages this is standard stuff.
2. It provides light-weight message-passing concurrency using typed channels, which I prefer over the actor model.
2. It provides memory safety while still giving control over memory layout (stack vs heap) and deterministic allocation (memory is not managed by garbage collection by default). This is the f
