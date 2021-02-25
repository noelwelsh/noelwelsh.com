+++
title = "Techniques for Teaching GADTs"
draft = true
+++

I was asked to comment on [this question][question] about teaching GADTs. Here's my answer. 

In summary:

- teach the components
- 

<!-- more -->

I would make sure the students have been introduced to algebraic data types before adding the extra complexity that type parameters (which imply GADTs) bring. Introducing only a single new concept at a time limits the possiblities for confusion.

A good example to work up to is defining a list type with a fixed element type like `IntList` below.

```scala
enum IntList:
  case Empty
  case Pair(head: Int, tail: IntList)
```

An example like this naturally motivates type parameters (what if we wanted to store a different type in the list?) It can also lead to discussion on using `Any` as our element type, which is something that students with a dynamically typed language background might reach for.

When introducing type parameters I like to make an analogy to method parameters:

1. There is a distinction between declaration, which introduces a parameter and gives it a name, and use, which refers to a parameter that has already been introduced. For a method we declare parameters with parentheses. We declare type parameters within square brackets. In both cases we refer to parameters by their names, and the scoping rules are similar.

2. When we call a method we must pass values for each of its parameters. When we refer to a type (constructor) that has type parameters we must provide types for each parameter.

We also need to know that only enums, classes, and methods can declare type parameters. Objects may not, with the exception of [polymorphic function types][polymorphic-function-types] in Scala 3. (There's a curriculum decision to be made here: do you teach enums as a concept in their own right or do you teach them as a derived from classes and sealed traits. I'm assuming they're being introduced as as a separate concept so I mention them as a construct that allows type parameter declarations.)

With this we can write an attempt at implementing a polymorphic list.

```
enum LinkedList[A]
  case Empty
  case Pair(head: A, tail: LinkedList[A])
```

This has both an introduction and a use of a type parameter, but it doesn't compile. The reason is a bit subtle but still fits with what we've presented: 


[question]: https://contributors.scala-lang.org/t/teaching-beginners-simple-gadts-without-introducing-variance/4893
[polymorphic-function-types]: https://dotty.epfl.ch/docs/reference/new-types/polymorphic-function-types.html
