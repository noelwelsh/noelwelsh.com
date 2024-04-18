+++
title = "Direct-style Effects in Scala"
draft = true
+++

What are direct-style effects, why should we care about them, and if we do care about them how can we implement them in Scala? These are three questions this post addresses.

<!-- more -->

## What We Care About

When we argue for one programming style over alternatives we are making a value judgement about programming. It is helpful to be explicit about what those values are. As I've written [elsewhere][fp], I believe the core values of functional programming are **reasoning** and **composition**. 

Side effects hinder both reasoning and composition. I've written [extensively][side-effects] about this, so I won't repeat myself. Simply avoiding all effects is not a solution, as all useful programs must interact with the outside world. Hencing managing side effects are a core problem in functional programming. 

Perhaps the oldest approach to managing effects is purely architectural: pushing effects "to the edges" so that the core of the program still retains desireable properties. Many language-oriented solutions have also been tried. Haskell used streams for IO in the distant past, but they do not compose well. Clean has uniqueness types. Around 1995 monads were discovered and made their way in Haskell. The `IO` monad has been the dominant approach in functional programming since. This doesn't mean research has stopped. Effect systems are a newer approach that may replace monads, and what this post is about. Rust's affine types can be seen as a limited form of effect system.


## Dirct Style and Other Styles

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

So the quest continues. Can we write code in a simple direct style, while still getting the benefits of using monads?


## Unpacking IO

Using the `IO` monad does many things. Here I want to focus on the following:

1. Using `flatMap` forces us to be explicit about the control flow of our program.
2. `IO` has all sorts of methods that allow us to compose effects.
3. If we see a method returns `IO` it helps us reason that it performs effects.

Being explicit about control flow is annoying. Scala already has well defined and easy to reason about control flow: things evaluate from top to bottom and left to right. Simple! However to use a monad we have to write everything out using `flatMap` so the monad can understand it. This is the core complaint with going away from direct style.

Now notice that the `IO` monad does two different things in two different contexts: sometimes we use `IO` to compose effects and sometimes to reason about effects. Can we separate the two? This gets us most of the way to effect systems.

Before we get into effect systems, there another issue I want to quickly deal with, which is composition of effects. One criticism of `IO` is that it lumps all effects into one type. We might want to be more precise, and say, for example, this method requires logging and database access, while that methods reads from the keyboard and prints to the screen. Tagless final has been used as one solution to this. However I'm not convinced this is an important problem. I can't think of any time when in practice I have wanted this information. So while composition of effects is nice, I'm not worried about it as an explicit goal.


## Effect Systems

[fp]:
[side-effects]:
