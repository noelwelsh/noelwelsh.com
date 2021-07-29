+++
title = "Techniques for Teaching GADTs"
draft = true
+++

I was asked to comment on [this question][question] about teaching GADTs. Here's my answer. 

In summary:

- teach the components
- 

<!-- more -->

You can't answer this question without making some assumptions about the students' prior knowledge. I'm going to assume they have been introduced to `enum` (so, algebraic data types) but not the desugaring of `enum` into `sealed traits` and `final case classes`. As we'll see I think understanding what's going on requires a limited understanding of the desugaring.

First I would introduce type variables. A good example to work up to is defining a list type with a fixed element type like `IntList` below.

```scala
enum IntList:
  case Empty
  case Pair(head: Int, tail: IntList)
```

This naturally motivates type parameters (what if we wanted to store a different type in the list?) It can also lead to discussion on using `Any` as our element type, which is something that students with a dynamically typed language background might reach for.

When introducing type parameters I like to make an analogy to method parameters:

1. There is a distinction between declaration, which introduces a parameter and gives it a name, and use, which refers to a parameter that has already been introduced. For a method we declare parameters within parentheses. We declare type parameters within square brackets. In both cases we refer to parameters by their name, and the scoping rules are similar.

2. When we call a method we must pass values for each of its parameters. When we refer to a type (constructor) that has type parameters we must provide types for each parameter.

We also need to know that only enums, classes, and methods can declare type parameters. Objects may not, with the exception of [polymorphic function types][polymorphic-function-types] in Scala 3. 

With this we can write an attempt at implementing a polymorphic list.

```
enum LinkedList[A]:
  case Empty
  case Pair(head: A, tail: LinkedList[A])
```
This has both an introduction and a use of a type parameter, but it doesn't compile. There is an error on the `Empty` case

```
Cannot determine type argument for enum parent class LinkedList,
type parameter type A is invariant
```

The reason is a bit subtle but still fits with what we've presented: 


[question]: https://contributors.scala-lang.org/t/teaching-beginners-simple-gadts-without-introducing-variance/4893
[polymorphic-function-types]: https://dotty.epfl.ch/docs/reference/new-types/polymorphic-function-types.html
