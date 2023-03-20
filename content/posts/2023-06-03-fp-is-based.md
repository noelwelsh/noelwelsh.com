+++
title = "Functional Programming is Based"
+++

Function programming is based[^1]; that is, based on principles that allow a *systematic* and *repeatable* process for creating software. In this post I'm going illustrate this process with an example of summing the elements of a list, inspired by [this conversation](https://news.ycombinator.com/item?id=35031092). We'll mostly be looking at *algebraic data types* and *structural recursion* (which often uses *pattern matching*, but is not synonymous with it). 

For me, a working functional programmer, this process is one of the main advantages of FP. It means I can spend my mental cycles on understanding the problem, knowing that once I have done so the implementation follows in a straightforward way. The inverse also holds: if someone uses these principles to write code I can easily work out what problem it solves.

<!-- more -->

## Overview

The main concepts we'll discuss are:

- algebraic data types, which builds up data; and
- structural recursion, which tears down data.

As the description suggests, they go together. If we use an algebraic data type to define data, we can then use structural recursion to manipulate that data. 

We'll also see two reasoning principles for structural recursion, and we'll take a quick look at the process for converting a function into a tail recursive form.

Functional programming has many of these concepts, which form the functional programming equivalent of [design patterns](https://en.wikipedia.org/wiki/Software_design_pattern) in the object-oriented world. Like OO design patterns, they exist above the code and the representation in code often uses several language features. Unlike OO patterns they usually have a formal definition. Formality adds precision, but formal definitions are not very approachable. In my presentation below I'll be quite informal.


## Algebraic Data Types

Algebraic data types are data where individual elements are combined using logical ands and logical ors. For example, we could say a `User` data type consists of a name *and* an email address *and* a status. We might say a `UserStatus` is active *or* banned *or* suspended. All languages I know of that have some way of declaring data using logical ands, but most lack logical ors[^2].

A (singly linked) list is one of the simplest examples of an interesting algebraic data type. A `List` with elements of type `A` is either:

- the empty `List`, or
- a `Pair` with a head of type `A` and a tail of type `List` of `A`.

Notice in this example we have both an *and* and an *or*, and that the definition of list is recursive: a list contains a list in the tail of the `Pair` case.

There is a direct translation of this structure into code. In Scala 3 we have the following patterns:

- If `A` is a `B` or `C` we write

```scala
enum A {
  case B
  case C
}
```

- If `A` is a `B` and `C` we write[^3]

```scala
case A(b: B, c: C)
```

Taken together, and adding the syntax for generic types, we can write the definition of `List`:

```scala
enum List[+A] {
  case Empty
  case Pair(head: A, tail: List[A])
}
```

The point to note is that this Scala definition *follows directly* from the abstract definition of `List` and the patterns for algebraic data types in Scala. We could write a program to do the translation, if we so wanted.

Other languages with algebraic data types follow the same principles, with their own language specific quirks. For example,
in O'Caml we write type declarations backwards, with the generic type variable before the concrete type it applies to.

```ocaml
type 'a list =
  | Empty 
  | Pair of 'a * 'a list
```

In Rust we must add indirection for the recursion in the form of a `Box`, and worse, indent by 4 spaces instead of 2.

```rust
enum List<A> {
    Empty,
    Pair(A, Box<List<A>>)
}
```

We can also express algebraic data types in languages that don't directly support them. In this case we have to rely on conventions instead of language support.


## Structural Recursion

Structural recursion is the complement to algebraic data types. Algebraic data types tell us how to construct data. Structural recursion tells us how to transform that data into something else. In other words, how to deconstruct data. Any time we are working with an algebraic data type we can use structural recursion.

Structural recursion is often implemented using pattern matching, but pattern matching is not synonymous with structural recursion. We can implement structural recursion in other ways, and implement things that are not structural recursion using pattern matching. I'm going to use pattern matching in the example here, but keep this point in mind.

Given we have two patterns for structural recursion, ands and ors, we need two patterns for structural recursion. Once again, I'm using Scala 3 here.

- If `A` is a `B` or `C` we write

  ```scala
  anA match {
    case B => ???
    case C => ???
  }
  ```

- If `A` is a `B` and `C` we write

  ```scala
  anA match {
    case A(b, c) => ???
  }
  ```

The right-hand side of the `match` expressions, which I've filled in with `???`, is where we implement our problem specific functionality.

There is one very important additional rule: when the data is recursive, the method we're implementing is recursive in the same place.


## An Example

Let's see how structural recursion applies to implementing a method to sum the element in a list of integers. We start by defining the method header.

```scala
def sum(list: List[Int]): Int =
  ???
```

The first step is to recognize that `list` is an algebraic data type, and therefore we can use structural recursion to convert this list into the `Int` output we're after. We start by filling out the structural recursion skeleton.

```scala
def sum(list: List[Int]): Int =
  list match {
    case Empty => ???
    case Pair(head, tail) => ???
  }
```

This is a direct application of the two structural recursion patterns to the `List` algebraic data type. However, I've forgotten one thing, the recursion rule! `List` is recursive in the `tail` of `Pair`, so `sum` should be recursive there. Let's add that, giving us

```scala
def sum(list: List[Int]): Int =
  list match {
    case Empty => ???
    case Pair(head, tail) => ??? sum(tail)
  }
```

I've kept the `???` in place, indicating that we haven't quite finished yet. This is as far as structural recursion on its own will take us, but we can finish the implementation with two reasoning principles.


## Reasoning about Structural Recursion

To finish the implementation we can use two principles for reasoning about structural recursion:

1. we can consider each case independently; and
2. we can assume any recursive calls will return the correct value.

Starting with the code

```scala
def sum(list: List[Int]): Int =
  list match {
    case Empty => ???
    case Pair(head, tail) => ??? sum(tail)
  }
```

we'll first look at the case for `Empty`. Remember we can consider it independently of the `Pair` case. So we simply need to ask ourselves "what is the `sum` of the empty list?" Zero is the only sensible answer here.

```scala
def sum(list: List[Int]): Int =
  list match {
    case Empty => 0
    case Pair(head, tail) => ??? sum(tail)
  }
```

Now we move on to the `Pair` case, where we can use the reasoning principle for recursion: assume it returns the value it should, which is the sum of the tail of the list. We can do this because the recursion comes from the recursion rule for structural recursion. So long as we take care of the non-recursive parts, the recursion is guaranteed to be correct.

Given this, we ask ourselves "if we have the sum of the tail of the list, what should sum of the tail and the head be?" The answer is to add the head to the sum of the tail.

```scala
def sum(list: List[Int]): Int =
  list match {
    case Empty => 0
    case Pair(head, tail) => head + sum(tail)
  }
```

With that we are done!

Notice that every step of the development of this method is justified by a general principle. This is what I mean by functional programming providing a systematic and repeatable process. Systematic because the process guides us along every step, and repeatable because we can apply the same process in many situations.


## Tail Recursion

The `sum` method is not tail recursive, but once again there is a process to transform it into a tail recursive version. The steps of the transform[^4] are:

1. Identify what will summarize the data we've already seen at any point in the process. Here that is the partial sum of the list elements we've seen so far.
2. Add an additional method parameter to hold this value, usually called an accumulator.

   ```scala
   def sum(list: List[Int], accum: Int): Int =
     list match {
       case Empty => 0
       case Pair(head, tail) => head + sum(tail)
     }
   ```

3. Change any base cases to return the accumulator.

   ```scala
   def sum(list: List[Int], accum: Int): Int =
     list match {
       case Empty => accum
       case Pair(head, tail) => head + sum(tail)
     }
   ```
4. Change any recursive cases to update the accumulator and perform the recursion in tail position.

   ```scala
   def sum(list: List[Int], accum: Int): Int =
     list match {
       case Empty => accum
       case Pair(head, tail) => sum(tail, head + accum)
     }
   ```

This explanation could do with more detail. I've skipped over the definition of tail position, for example. My goal here is to illustrate the process to someone who has already used it but is perhaps cannot articulate the underlying steps, rather than teach the process to someone who has no prior knowledge.


## Conclusions

We've seen the following:

- algebraic data types for modelling data expressed in terms or logical ands and ors;
- structural recursion for transforming algebraic data types;
- reasoning principles for completing structural recursions; and
- conversion to tail recursive form.

There is a lot in this simple example. The most important point is that there is a process that explains every step of creating the method we're after. This same process scales up to complex problems like compilers and [graphics](https://github.com/creativescala/doodle/blob/main/image/shared/src/main/scala/doodle/image/Image.scala). This is a contrast to how I was taught imperative programming, and I think most programmers think about code, which is as a random collection of language features that combine in some ineffable way to produce working programs. In the context of the conversation that motivated this post, there is no need to even think about things like early returns. They simply aren't a concept that is needed when you can produce working code using the patterns I've described.

The second point is applicable to languages that are adding "functional programming" features. For example, Python has recently added pattern matching. The real benefit of pattern matching, in my opinion, is not as a language feature on its own but as a tool for implementing structural recursion. This usually comes with compiler support for checking that all cases have patterns, known as exhaustivity checking. It is a mistake to think of functional programming as a collection of language features. The language features are in service to deeper ideas. 

The third point is that functional programming is full of great stuff like this. The academic community has mostly done a terrible job communicating it to industry. For example, I believe algebraic data types and structural recursion were first explored in the antecedents of [Functional Programming with Bananas, Lenses, Envelopes and Barbed Wire](https://ris.utwente.nl/ws/files/6142047/db-utwente-40501F46.pdf). This paper has some of the most opaque notation I've ever read, and does a incredibly poor job of conveying incredibly interesting ideas. A notable exception is [How to Design Programs](https://htdp.org/), which presents algebraic data types and structural recursion in a way that completely new programmers can understand. I believe that making these patterns more accessible is the next step in the growth of functional programming.


[^1]: "Based" is a term for something that is good or true, according to my children.

[^2]: Go is a great example of the problems caused by the absence of logical ors. Go functions return a success *and* an error value. The logical design would be to have function returning success *or* error values. Go's design forces it to include a null value, the billion dollar mistake, because there needs to be some value to return for the success case when an error means there is no sensible value to return. Algebraic data types were fully formed by [1983 when Standard ML was created](https://smlfamily.github.io/history/SML-history.pdf), while development on Go started 24 years later in 2007. One of the "primary considerations" for Go is ["it must be modern"](https://go.dev/talks/2012/splash.article#TOC_6.).

[^3]: There is an annoying irregularity in Scala 3's syntax. For a case inside an `enum` we write what is given, but outside an `enum` we use a `final case class` instead.

[^4]: The full transform is known as continuation passing style and is a bit more complex than what I present here.
