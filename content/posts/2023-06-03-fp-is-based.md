+++
title = "Functional Programming is Based"
+++

Function programming is based[^1]; that is, based on principles that allow a *systematic* and *repeatable* process for creating software. As a working functional programmer this is one of the major advantages of FP. I can spend my mental cycles on understanding the problem, knowing that once I have done so the implementation follows in a straightforward way. The inverse also holds: if someone uses these principles to write code I can easily work out what it does.

In this post I'm going illustrate this process with an example of summing the elements of a list, inspired by [this conversation](https://news.ycombinator.com/item?id=35031092). We'll mostly be looking at *algebraic data types* and *structural recursion* (which often uses *pattern matching*, but is not synonymous with it). I'm going to start with a quick overview of these concepts, and then see how they apply to the problem.

<!-- more -->

## Algebraic Data Types

Algebraic data types are data where individual elements are combined using logical ands and logical ors. For example, we could say a `User` data type consists of a name *and* an email address *and* a password, or that a `UserStatus` is active *or* banned *or* suspended. All languages I know of that have some way of declaring data having logical ands, but most lack logical ors[^2].

A (singly linked) list is one of the simplest examples of an interesting algebraic data type. A `List` with elements of type `A` is either:

- the empty `List`, or
- a `Pair` with a head of type `A` and a tail of type `List` of `A`.

Notice in this example we have both an *and* and an *or*, and that the definition of list is recursive: a list contains a list in the `Pair` case.

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

The point to note is that this Scala definition *follows directly* from the abstract definition of `List` and the patterns for the encoding in Scala. We could write a program to do the translation, if we so wanted.

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

Regardless of the language the principle is the same: there is a direct translation of the structure in terms of ands and ors into code.


## Structural Recursion

Structural recursion is the complement to algebraic data types. Algebraic data types tell us how to construct data. Structural recursion tells us how to transform that data into something else. In other words, how to deconstruct data and do something with it. Any time we are working with an algebraic data type we can use structural recursion.

Structural recursion is often implemented using pattern matching, but pattern matching is not synonymous with structural recursion. We can implement structural recursion in other ways, and implement things that are not structural recursion using pattern matching. I'm going to use pattern matching but keep this point in mind.

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

The right-hand side of the `match` expressions, which I've filled in with `???` is where we implement our problem specific functionality.

There is one additional rule, which is very important. When the data is recursive, the method we're implementing is recursive in the same place.


## An Example

Let's see how structural recursion applies to implementing a method to sum the element in a list of integers. We start by defining the method header.

```scala
def sum(list: List[Int]): Int =
  ???
```

The first step is to we recognize that `list` is an algebraic data type, and therefore we can use structural recursion to convert this list into the `Int` output we're after. We start by filling out the structural recursion skeleton.

```scala
def sum(list: List[Int]): Int =
  list match {
    case Empty => ???
    case Pair(head, tail) => ???
  }
```

This is a direct application of the two structural recursion patterns. However, I've forgotten one thing, the recursion rule! `List` is recursive in the `tail` of `Pair`, so `sum` should be recursive there. Let's add that, giving us

```scala
def sum(list: List[Int]): Int =
  list match {
    case Empty => ???
    case Pair(head, tail) => ??? sum(tail)
  }
```

I've kept the `???` in place, indicating that we haven't quite finished yet. This is as far as structural recursion on its own will take us, but we can finish the implementation with two reasoning principles.


### Reasoning about Structural Recursion

To finish the implementation we can use two principles for reasoning about structural recursion:

1. we can consider each case independently; and
2. we can assume any recursive calls will return the correct value.

Here is our starting point:

```scala
def sum(list: List[Int]): Int =
  list match {
    case Empty => ???
    case Pair(head, tail) => ??? sum(tail)
  }
```

Let's first look at the case for `Empty`. Remember we can consider it independently of the `Pair` case. So we simply need to ask ourselves "what is the `sum` of the empty list?" Zero is the only sensible answer here.

```scala
def sum(list: List[Int]): Int =
  list match {
    case Empty => 0
    case Pair(head, tail) => ??? sum(tail)
  }
```

Now we move on to the `Pair` case, where we can use the reasoning principle for recursion: assume it returns the value it should, which is the sum of the tail of the list. We can do this because the recursion comes from the recursion rule. So long as we take care of the non-recursive parts, the recursion is guaranteed to be correct.

Given this, we ask ourselves "if we have the sum of the tail of the list, what should sum of the tail and the head be?" The answer is to add the head to the sum of the tail.

```scala
def sum(list: List[Int]): Int =
  list match {
    case Empty => 0
    case Pair(head, tail) => head + sum(tail)
  }
```

With that we are done.


## Tail Recursion

The `sum` method is not tail recursive, but once again there is a simple process to transform it into a tail recursive version. The steps of the transform[^4] are:

1. Identify what will summarize the data we've already seen at any point in the process. Here that is the partial sum of the list elements we've seen so far.
2. Add an additional parameter to hold this value, usually called an accumulator.

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

There is a lot in this simple example. The most important point is that there is a process that explains every step of creating the method we're after. This same process scales up to complex problems like compilers and [graphics](https://www.creativescala.org/doodle/). This is a contrast to how I was taught imperative programming, and I think most programmers think about code, which is as a random collection of language features that combine in some ineffable way to produce working programs. In the context of the conversation that motivated this post, there is no need to even think about things like early returns. They simply aren't a concept that is needed when you can just bash out the code using the patterns I've described.

The second point is applicable to languages like Python that are adding pattern matching. The real benefit, in my opinion, is not pattern matching as a language feature on its own but pattern matching as a tool for implementing structural recursion. This usually comes with compiler support for checking that all cases have patterns, known as exhaustivity checking. It is a mistake to think of functional programming as a collection of language features. The language features are in service to deeper ideas. 

The third point is that functional programming is full of great stuff like this, but the academic community has done a terrible job communicating it to industry. For example, I believe algebraic data types and structural recursion were first explored in the antecedents of [Functional Programming with Bananas, Lenses, Envelopes and Barbed Wire](https://ris.utwente.nl/ws/files/6142047/db-utwente-40501F46.pdf). This paper has some of the most opaque notation I've ever read, and does a incredibly poor job of conveying incredibly interesting ideas.


[^1]: "Based" is a term for something that is good or true, according to my children.

[^2]: Go is a great example of the problems caused by the absence of logical ors. In Go a function returns a success *and* and error value, when functions should really return success *or* error values. This design forces Go to include a null value, the billion dollar mistake, because functions need to return some value for the success case even when an error means there is no sensible value to return. Algebraic data types were fully formed by [1983 when Standard ML was created](https://smlfamily.github.io/history/SML-history.pdf), while development on Go started 24 years later in 2007. One of the "primary considerations" for Go is ["it must be modern"](https://go.dev/talks/2012/splash.article#TOC_6.).

[^3]: There is an annoying irregularity in Scala 3's syntax. For a case inside an `enum` we write what is given, but outside an `enum` we use a `final case class` instead.

[^4]: The full transform is known as continuation passing style as it a bit more complex than what I present here.
