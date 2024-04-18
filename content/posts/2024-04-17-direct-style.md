+++
title = "Direct-style Effects in Scala"
draft = true
+++

What are direct-style effects, why should we care about them, and if we do care about them how can we implement them in Scala? These are three questions this post addresses.

<!-- more -->

## What We Care About

When we argue for one programming style over alternatives we are making a value judgement about programming. It is helpful to be explicit about what those values are. As I've written [elsewhere][fp], I believe the core values of functional programming are the two related concepts of **reasoning** and **composition**. Side effects stop us achieving both of these, but every useful program must interact with the world in some way. Therefore, replacing side effects with something more manageable is a core problem in functional programming. (If you're uncertain what is meant by a side effect, [this chapter of Creative Scala][substitution] goes into detail.)

Nota bene: in this post I use the term *side effect* for uncontrolled effects, and just *effect* for effects that are controlled in a more desireable way.

Monads are the most common approach to managing effects in modern functional programming, but this doesn't mean they are the only approach. Older versions of Haskell used streams instead. The [Clean][clean] language uses uniqueness types, which are very closely related to the affine types seen in Rust's borrow checker. Most current research work focuses on what are called *algebraic effects* and *effect handlers*, and these are generally known as *effect systems*.

Our goals in this post are:

1. to describe the design space of effect systems;
2. to show how we can implement an effect system in Scala 3; and
3. to point at what's needed to get a full effect system in Scala 3.


## Dirct and Other Styles

Direct style code is code as it is usually written. You call functions, they return results, and you use those results in further computations. Here's the kind of code we write in direct style.

```scala
val a: A = ???
val b = doSomething(a)
val c = doSomething2(b)
val d = doSomething3(c)
```

An alternative to direct style is called state passing style (or continuation passing style; they are basically the same thing). We can motivate state passing style as an approach to handling effect. We have some type that represents the state of the world. Call this `World`. Now any function that wants to have effects can take the world as a parameter, and return an updated world as a result. So in general we write functions with types like

```scala
def doSomething[A, B](a: A, world: World): (B, World) =
  ???
```

Now `doSomething` is a pure function, as it is a function only of its inputs and all its effects are captured in the `World` it returns. However, writing code in this style is annoying. Consider the code below. Passing the state around quickly gets tedious.

```scala
val a: A = ???
val w1: World = ???

val (b, w2) = doSomething(a, w1)
val (c, w3) = doSomething2(b, w2)
val (d, w4) = doSomething3(c, w4)
(d, w4)
```

We can hide the `World` parameter by using a monad, giving us familiar looking code like the following.

```scala
doSomething(a)
  .flatMap(b => doSomething(b))
  .flatMap(c => doSomething(c))
  .run(w1)
```

This isn't too bad. Lots of developers have written code like this. However, it's still a different style of coding that has been learned, and hence a barrier to entry. It's also a virus. Once one part of our code start using monads, it quickly infects the rest of our code and forces us to transform it into monadic style.

So the quest continues. Can we write code in a simple direct style, while still getting the benefits of using monads? This is one issue we'll try to address.


## Describing and Doing

Hard requirement.

Reasoning and composition imply we must have a separation between describing the effects that should occur, and actually carrying out those effects. Consider perhaps the simplest effect in any programming language: printing to the console. In Scala we can accomplish this as a side effect with `println`:

```scala
println("OMG, it's an effect")
```

Imagine we want to compose the effect of printing to the console with the effect that changes the color of the text on the console. With the `println` side effect we cannot do this. Once we call `println` the output is already printed; there is no opportunity to change the color.

We can certainly use two side effects that happen to occur in the correct order to get the output with the color we want.

```scala
println("\u001b[91m") // Color code for bright red text
println("OMG, it's an effect")
```

However this is not the same thing as composing an effect that combines these two effects. For example, the code above doesn't reset the foreground color. This will cause all subsequent output will be bright red, not just the output we intended to be colored. This is an example of the non-compostionality of side effects. One side effect affects the behaviour of other side effects, which means we lose the ability to reason compositionally.

What we really want is to write code like

```scala
Effect.println("OMG, it's an effect").foregroundBrightRed
```

which we can only do if we have a separation between describing the effect, as we have done above, and actually running it.


## Unpacking IO

Let's unpack how `IO` addresses the issues we've discussed. The `IO` monad has a distinction between describing and running, so it meets the requirement above. It also, by definition, requires we wrote code in monadic style.

Using the `IO` monad does many things. Here I want to focus on the following:

1. Using `flatMap` forces us to be explicit about the control flow of our program.
2. `IO` has all sorts of methods that allow us to compose effects.
3. If we see a method returns `IO` it helps us reason that it performs effects.

Being explicit about control flow is annoying. Scala already has well defined and easy to reason about control flow: things evaluate from top to bottom and left to right. Simple! However to use a monad we have to write everything out using `flatMap` so the monad can understand it. This is the core complaint with going away from direct style.

Now notice that the `IO` monad does two different things in two different contexts: sometimes we use `IO` to compose effects and sometimes to reason about effects. Can we separate the two? This gets us most of the way to effect systems.

Before we get into effect systems, there another issue I want to quickly deal with, which is composition of effects. One criticism of `IO` is that it lumps all effects into one type. We might want to be more precise, and say, for example, this method requires logging and database access, while that methods reads from the keyboard and prints to the screen. Tagless final has been used as one solution to this. However I'm not convinced this is an important problem. I can't think of any time when in practice I have wanted this information. So while composition of effects is nice, I'm not worried about it as an explicit goal.


## Effect Systems

[fp]: https://noelwelsh.com/posts/what-and-why-fp/
[substitution]: https://www.creativescala.org/creative-scala/substitution/index.html
[clean]: https://wiki.clean.cs.ru.nl/Language_features
