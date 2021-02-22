---
title: Building the Right Abstraction
---

Abstraction 

<!--more-->

## Abstraction Is Not About Removing Duplication

If we're going to talk about abstraction we need to define what abstraction is. For our purposes, an abstraction is a realization in code of a coherent concept from some relevant domain. "Coherent" is a key property here. I'll have more to say about this in moment. For now, let's just say that when we define an abstraction there must be some group of people who can look at that abstraction and say it makes sense.

Equating abstraction with removing duplication was a common theme in the [blog][aha-programming] [posts][wrong-abstraction] I read. This is, I believe, a mistake and the root of the problem both blog posts take issue with. Removing duplication is a benefit but it shouldn't be the goal that drives creating abstractions. If there isn't a coherent concept behind the code it's just stuff, not an abstraction. Sometimes it is useful to reduce duplication in stuff, but the result is not abstraction. It's still just stuff. 

So what is the benefit of abstraction? It's how we scale our code and our understanding of code. When we use an abstraction we don't have to care what's inside the abstraction. We have a whole pile of code we don't have to write (or only write once). More important is that we can build one model of how the abstraction works and then we can use that model everywhere we use the abstraction. The limiting factor with software development is not the production of code but the production of understanding. Abstraction means our mental model does not need to scale with the size of the code base. It's the only tool that allows us to write larger systems without falling into a twisty maze of spaghetti code and confusion.


## The Properties of Abstractions

If an abstraction is a coherent concept, is there any way we can tell an abstraction from stuff? We have to be able to say something about the abstraction *in the abstract.* In the functional programming world this often means "laws", which means statements in some formal language (usually first-order logic) about the properties of the abstraction. (Note that I hate the term "laws". It's so pompous. I prefer "properties".)

A simple example is a [monoid]. A monoid is:

- some set of values `A`;
- a binary operation, which we'll call `+`, so `a + b = c` for some `a`, `b`, and `c` in the set`A`
- and the properties
  - the operation is associative, so `(a + b) + c = a + (b + c)` for all `a`, `b`, and `c` in `A`;
  - there is an identity element, written `0`, in `A` so that `0 + a = a = a + 0` for all `a` in `A`.

An example of a monoid is the set of integers, and operation `+` with identity `0` or the operation `*` with identity `1`. A non-monoid operation would be `-`, which is not associative: `(1 - 2) - 3` is not `1 - (2 - 3)`.
  
The properties of associativity and identity distinguish a monoid from the vast sea of binary operations that don't make a monoid. They also allows us to reason in interesting ways. For example, associativity says that (a certain type of) order doesn't matter. This means we're free to parallelize monoid operations, an idea that is exploited in the reduce portion of Map-Reduce and it's successors. We could also interpret the identity as an empty element or missing value, with `+` meaning to choose the last non-empty value. This gives us a way to handle default values or configuration settings: make the default the first value we pass to `+`. Then the user can override it but by specifying a non-empty value but will get the default if they pass the empty value. This is a kind of "last write wins" policy, which might make us think about distributed system, and indeed monoids turn up everywhere in distributed systems (for example, see "commutative replicated data types" aka CRDTs). This is just a glimpse of the power we get from monoids. We have *one* mental model, which we can completely specify in a few lines, which gives us a huge number of use cases. This is what real abstraciton is about.

Despite the userfulness of formal properties, don't get hung up on them. Sometimes they're too tedious to state. For example, [Doodle][doodle] has lots of properties (including several monoids) but I haven't bothered to write them dowm as I can't see the value in it. Very occasionally things without any properties are useful. Finding properties is a good metric, though.


## Why Functional Programming Abstractions Work

When I switched from object-oriented to functional programming I noticed that the abstractions just seemed to work better. My experience in OO-land is that abstractions tended to be intricate little state machines with often hidden invariants and dependencies. Extending the abstraction to cover new cases required a deep understanding of the internal workings of the code. In constrast creating a monoid just requires understanding the properties above and then implementing an appropriate binary function.

A big part of the magic of functional programming abstractions is *composition*. Things compose if you can stick them together like Lego. For example, if you have a function from `A` to `B` and a function from `B` to `C` you can compose them to produce a function from `A` to `C`.

Abstractions that compose also allow us to compose mental models. The properties of an abstraction composed with another is defined by the properties of the individual pieces and the properties of the composition operation. These are independent. Composable abstractions scale, because the number of mental models doesn't grow with the number of compositions.


## Bad Abstractions

It might be helpful to show a few examples of bad abstractions, though bagging other people's work is not usually my jam.

Another type of bad abstraction is reinventing a well known concept. D3's scales are an example of this. The [documentation][d3-scale] says "perhaps the most important concept in D3 is the scale, which maps a dimension of abstract data to a visual variable." So a scale is something you pass a value to and get a value out ... which is just a function. No need to write a few thousand words explaining this concept.

Java Image

11ty random crap


## Leaky Abstractions

[aha-programming]: https://kentcdodds.com/blog/aha-programming 
[wrong-abstraction]: https://www.sandimetz.com/blog/2016/1/20/the-wrong-abstraction
[monoid]: https://typelevel.org/cats/api/cats/kernel/Monoid.html
[doodle]: https://github.com/creativescala/doodle
[d3-scale]: https://medium.com/@mbostock/introducing-d3-scale-61980c51545f
