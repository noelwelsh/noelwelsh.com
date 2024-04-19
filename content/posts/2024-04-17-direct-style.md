+++
title = "Direct-style Effects in Scala"
+++

What are direct-style effects, why should we care about them, and how can we implement them in Scala? These are three questions this post addresses.

<!-- more -->

## What We Care About

When we argue for one programming style over alternatives we are making a value judgement about programming. It is helpful to be explicit about what those values are. As I've written [elsewhere][fp], I believe the core values of functional programming are **reasoning** and **composition**. Side effects stop us achieving both of these, but every useful program must interact with the world in some way. (If you're uncertain what is meant by a side effect, [this chapter of Creative Scala][substitution] goes into detail.) Therefore, replacing side effects with something in keeping with these core principles is considered an important problem in functional programming. Solutions to this problem are called **effect systems**. 

Nota bene: in this post I use the term *side effect* for uncontrolled effects, and just *effect* for effects that are controlled in a more desirable way.

Monads are the most common effect system in modern functional programming, but this doesn't mean they are the only approach. Older versions of Haskell used streams. The [Clean][clean] language uses uniqueness types, which are very closely related to the affine types seen in Rust's borrow checker. Most current research work focuses on what are called **algebraic effects** and **effect handlers**. It's this kind of approach we will be exploring, though we have some background to get through first.

Our goals in this post are:

1. to describe the design space of effect systems;
2. to show how we can implement a direct-style effect system in Scala 3; and
3. to point at what's needed to get a full direct-style effect system in Scala 3.


## The Design Space of Effect Systems

### Direct and Monadic Style

Reasoning and composition are non-negotiable criteria for any effect system. There are other criteria that are desirable, however. A major one is the style of code that we have to write to use the effect system. If an effect system requires too much work from the programmer it is unusable in practice, no matter what other properties it has. Here we will look at **direct style**, which is code as we want to write it, and **monadic style**, which is code as monadic effect systems force us to write it.

Direct style code is code as it is usually written. You call functions, they return results, and you use those results in further computations. Here's the kind of code we write in direct style.

```scala
val a: A = ???
val b = doSomething(a)
val c = doSomething2(b)
val d = doSomething3(c)
```

We don't need to say much about direct style, other than that it is desirable to write in this style.

As most Scala programmers will have experienced, we must write code in a different style if we are to use monads. In monadic style the code above ends up looking something like

```scala
doSomething(a)
  .flatMap(b => doSomething(b))
  .flatMap(c => doSomething(c))
```

This isn't too bad. Lots of developers have written code like this. However, it's still a different style of coding that has been learned, and hence a barrier to entry. It's also a virus. Once one part of our code start using monads, it quickly infects the rest of our code and forces us to transform it into monadic style. So ideally an alternative effect system would allow us to continue to write in direct style.


### Description and Action

Any effect system must have a separation between describing the effects that should occur, and actually carrying out those effects. This is a requirement of composition. Consider perhaps the simplest effect in any programming language: printing to the console. In Scala we can accomplish this as a side effect with `println`:

```scala
println("OMG, it's an effect")
```

Imagine we want to compose the effect of printing to the console with the effect that changes the color of the text on the console. With the `println` side effect we cannot do this. Once we call `println` the output is already printed; there is no opportunity to change the color.

Let me be clear that the goal is *composition*. We can certainly use two side effects that happen to occur in the correct order to get the output with the color we want.

```scala
println("\u001b[91m") // Color code for bright red text
println("OMG, it's an effect")
```

However this is not the same thing as composing an effect that combines these two effects. For example, the example above doesn't reset the foreground color so all subsequent output will be bright red. This is the classic problem of side effects: they have "action at a distance" meaning one part of the program can change the meaning of another part of the program. This in turns means we cannot reason locally, nor can we build programs in a compositional way.

What we really want is to write code like

```scala
Effect.println("OMG, it's an effect").foregroundBrightRed
```

which limits the foreground colour to just the given text. We can only do if we have a separation between describing the effect, as we have done above, and actually running it.


### Reasoning and Composing with Effects

Effect systems should help us reason about what code does. Take for example, the following method signature:

```scala
def cthulhuFhtagn(): Unit
```

What happens when we call this method? Returning `Unit` suggests it has some side-effect, but what is that side-effect? It could print to the console, raise an exception, or wake a Great Old One to destroy the Earth. We cannot tell.

Using the `IO` monad is similar. If we instead see the method signature

```scala
def cthulhuFhtagn(): IO[Unit]
```

we again don't know what effects will occur but we do have some way to manipulate those effects. We can attempt to cancel the effects, for example, by writing

```scala
IO.canceled *> cthulhuFhtagn()
```

or instead recover from errors using `handleError`.

It's important to note that we can do this manipulation of effects in a composable way. For instance, we can pass the `IO` to some other method that chooses how to manipulate it.

```scala
def cancelOrRecover(effect: IO[Unit]): IO[Unit] =
  // Continue only if the stars are right
  IO.realTimeInstant
    .map(time => starsAreRight(time))
    .ifM(
      true = effect.handleError(...),
      false = IO.cancel *> effect 
    )
    
cancelOrRecover(cthulhuFhtagn())
```

We cannot do this in the first case that uses side-effects.

Before we get into effect systems, there another issue I want to quickly deal with, which is composition of effects. One criticism of `IO` is that it lumps all effects into one type. We might want to be more precise, and say, for example, this method requires logging and database access, while that methods reads from the keyboard and prints to the screen.Tagless final is sometimes used to achieve this. The method signature

```scala
def cthulhuFhtagn[F[_]: WakeGreatOldOne](): F[Unit]
```

indicates this method requires a `WakeGreatOldOne` effect, which we might use to decide to not call the method.


## Direct-style Effect Systems

Direct-style effect systems in Scala require some machinery that is new in Scala 3. Since that's probably new to many readers we're going to start with an example, explain the programming techniques behind it, and then explain the concepts it embodies.

Our example is a simple effect system for describing effects that produce random numbers. This is a very simple type of effect. In a monadic system we'd implement this using the probability monad. For comparison, an implementation of the probability monad is [here](https://github.com/creativescala/doodle/blob/main/core/shared/src/main/scala/doodle/random.scala). 

The implementation is below. You can save this in a file (called, say, `Sample.scala`) and run it with `scala-cli` with the command `scala-cli Sample.scala`.

```scala
//> using scala 3

import scala.util.Random

// A `Sample[A]` is a description of an effect that, when run, will generate a
// values of type `A` possibly using a random number generator
type Sample[A] = Random ?=> A
object Sample {
  // This runs a `Sample[A]` producing a value of type `A`. By default it uses
  // the global random number generator, but the user can pass in a different
  // generator as the first argument.
  def withRandom[A](random: Random = scala.util.Random)(sample: Sample[A]): A = {
    given r: Random = random
    sample
  }

  // Utility to use inside a `Sample[A]` to produce a random `Int`
  def int(using r: Random): Int =
    r.nextInt()

  // Utility to use inside a `Sample[A]` to produce a random `Double`
  def double(using r: Random): Double =
    r.nextDouble()

  // Constructs a `Sample[A]`.
  inline def apply[A](inline body: Random ?=> A): Sample[A] =
    body
}

@main def go(): Unit = {
  val randomCoordinate: Sample[Int] = Sample.int

  val randomPoint: Sample[(Int, Int)] =
    Sample {
      // Direct-style composition
      val x = randomCoordinate
      val y = randomCoordinate
      (x, y)
    }

  // Run the description. Again using direct-style
  Sample.withRandom(){
    println(randomPoint)
    println(randomPoint)
  }
}
```

We have the usual separation between description and action. In direct-style code, a description is a [context function][context-function]. You can think of a context function as a normal with given (implicit) parameters. In our case the descriptions have the type `Sample[A]`, which is an alias for a context function with a `Random` given parameter. `Random` is the type of random number generators in the Scala standard library. Creating a random number is a stateful operation, and therefore an effect.

Context function types have a special rule that makes constructing them easier.
The rule is that a normal expression will be converted to an expression that produces a context function if the type of the expression is a context function.
Let's unpack that by seeing how it works in practice.
In the example above we have the line

```scala
val randomCoordinate: Sample[Int] = Sample.int
```

`Sample.int` is an expression with type `Int`, not a contextual function type. However `Sample[Int]` is a contextual function type. This type annotation causes `Sample.int` to be converted to a contextual function type. You can check this yourself by removing the type annotation:

```scala
val randomCoordinate = Sample.int
```

This will not compile.

We use the same trick with `Sample.apply`, which is a general purpose constructor. You can call `apply` with any expression and it will be converted to a contextual function. (As far as I know it is not essential to use `inline`, but all the examples I learned from do this so I do it as well. I assume it is an optimization.)

Direct-style composition needs another bit of special sauce: if there is given value of the correct type in scope of a context function, that values will be automatically applied to the function. This is what makes our example of direct-style composition, shown below, work. When we refer to `randomCoordinate` we get an `Int` value back, because `randomCoordinate` is a context function in the scope of the given `Random` by the call to `Sample.apply`.

```scala
val randomPoint: Sample[(Int, Int)] =
  Sample {
    // Direct-style composition
    val x = randomCoordinate
    val y = randomCoordinate
    (x, y)
  }
```

That's the mechanics of how direct-style effect systems work in Scala: it all comes down to context functions.

I'm going to deal with composition of effects and more in just a bit. First though, I want describe the concepts behind what we've done.

Notice in direct-style effects we split effects into two parts: context handlers that define the effects we need, and the actual implementation of those effects. In the literature these are called algebraic effects and effect handlers respectively. This is an important difference from `IO`, where the same type indicates the need for effects and provides the implementation of those effects.

Also notice that we use the argument type of context functions to indicate the effects we need, rather the result type as in monadic effects. This difference avoids the ["colored function"][colored-function] problem with monads. We can think of the arguments as specifying requirements on the environment or context in which the context functions, hence the name.

Now let's look at composition of effects, and effects that modify control flow.


### Composition of Direct-Style Effects

Direct-style effects compose in a straightforward way: we just add additional parameters to our context function. Here's a simple example that defines another effect, `Console`, for printing and then builds a program that requires both `Console` and `Random`.

First we define the effect, using the same pattern as before.

```scala
final class Console() {
  def stdout(msg: String): Unit =
    println(msg)
}

type Print[A] = Console ?=> A
object Print {
  val console: Console = Console()

  def println(msg: String)(using c: Console): Unit =
    c.stdout(msg)

  def withConsole[A](print: Print[A]): A = {
    given c: Console = console
    print
  }

  inline def apply[A](inline body: Console ?=> A): Print[A] =
    body
}
```

Now we can use both `Console` and `Random`.

```scala
val printRandom: (Console, Random) ?=> Unit =
  Print {
    val i = Sample { Sample.int }
    Print.println(i.toString)
  }

Print.withConsole(Sample.withRandom()(printRandom))
```


### Effects Changing Control Flow

Many interesting effects, such as error handling, concurrency, and backtracking search, require changing the control flow of the program. We can handle these in the same system, but we require some runtime support to do the control flow gymnastics that we require. Scala 3 already has some limited support for this, and more is coming. See Martin Odersky's talk [Direct Style Scala][direct-style-scala] for more on this.

You might wonder how monads can play with control flow without requiring runtime support. The answer is that monads require the user to explicitly specify the control-flow. This is exactly what `flatMap` does: it expresses what should happen in what order, and by giving the monad this information as a chain of `flatMaps` it can evaluate them in the order that makes sense for the particular monad implementation.


## Conclusions and Further Reading

Overall, I'm pretty excited by direct-style effects in Scala. I think they are much more ergonomic than monadic effects, which means they make the power of Scala more accessible. I'm also really excited by continuations, and presumably tail calls, arriving Scala. These are really interesting and useful tools for a variety of purposes. I also think more investment in Scala Native is a good thing, as the native platform has advantages over the JVM in some important cases.

One thing I haven't talked about is resource tracking. There are many times when the order of operations is an important part of ensuring safety of an effect. A simple example is ensuring that all files that are opened are closed. This is usually handled by what are known as substructural type systems, which Rust is an example of. This is not directly addressed by direct-style effects, but it would a useful addition to them.

If you'd like to read more about direct-style effects here are some suggestions, which are a mix of accessible introduction and academic papers:

* [Abilities for the monadically inclined][abilities], a very nice post from the Unison team that covers a lot of the same material from a different perspective.
* Dean Wampler's post [What is "Direct Style"][what-is-direct-style].
* The [Gears][gears] concurrency library being developed for Scala 3.
* [Raise4s][raise4s], a simple example of error handling as a direct-style effect.
* [Handlers in Action][handlers-in-action] is one of the more readable academic papers on implementing effect handlers.
* [Capturing Types][capturing-types] describes some extensions to the Scala type system are probably coming to a Scala implementation near you.
* [Degrees of Separation: A Flexible Type System for Safe Concurrency][degrees] is a paper I've only lightly skimmed but it seems like it addresses the resource use problem I described above.

[fp]: https://noelwelsh.com/posts/what-and-why-fp/
[substitution]: https://www.creativescala.org/creative-scala/substitution/index.html
[clean]: https://wiki.clean.cs.ru.nl/Language_features
[context-function]: https://docs.scala-lang.org/scala3/reference/contextual/context-functions.html
[colored-function]: https://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/
[direct-style-scala]: https://www.youtube.com/watch?v=0Fm0y4K4YO8
[gears]: https://github.com/lampepfl/gears
[what-is-direct-style]: https://medium.com/scala-3/scala-3-what-is-direct-style-d9c1bcb1f810
[abilities]: https://www.unison-lang.org/docs/fundamentals/abilities/for-monadically-inclined/
[raise4s]: https://github.com/rcardin/raise4s/tree/main
[handlers-in-action]: https://denotational.co.uk/publications/kammar-lindley-oury-handlers-in-action.pdf 
[capturing-types]: https://dl.acm.org/doi/10.1145/3618003
[degrees]: https://infoscience.epfl.ch/record/310307
