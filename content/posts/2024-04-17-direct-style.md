+++
title = "Direct-style Effects in Scala"
+++

Direct-style effects, also known as algebraic effects and effect handlers, are the next big thing in programming languages. They are already available in [Unison][unison-effects] and [OCaml][ocaml-effects], are coming to [Scala][direct-style-scala], and I'm seeing discussion about them in other [closely-related-to-industry contexts][coroutines-and-effects]. 

At the same time I see [some][tweet-1] [confusion][tweet-2] about direct-style effects. In this post I want to address this confusion by explaining the what, the why, and the how of direct-style effects using a Scala 3 implementation as an example. There is quite a bit going on here. First we'll talk about the problem we're trying to solve and the constraints we're operating under. Then we'll look at a simple implementation in Scala 3 and describe the language feature, contextual functions, that enables it. Next up we'll see some shortcomings of this implementation and see how they can solved by two language features, one well known (delimited continuations) and one in development (type system innovations). Finally I'll give some pointers to more about information on this topic.

<!-- more -->

[unison-effects]: https://www.unison-lang.org/docs/fundamentals/abilities/
[ocaml-effects]: https://github.com/ocaml-multicore/ocaml-effects-tutorial
[direct-style-scala]: https://www.youtube.com/watch?v=0Fm0y4K4YO8
[coroutines-and-effects]: https://without.boats/blog/coroutines-and-effects/
[tweet-1]: https://twitter.com/debasishg/status/1780636969841914279
[tweet-2]: https://twitter.com/channingwalton/status/1780517826505166989

## What We Care About

When we argue for one programming style over alternatives we are making a value judgement about programming. It is helpful to be explicit about what those values are. As I've written [elsewhere][fp], I believe the core values of functional programming are **reasoning** and **composition**. Side effects stop us achieving both of these, but every useful program must interact with the world in some way. (If you're uncertain what is meant by a side effect, [this chapter of Creative Scala][substitution] goes into detail.) Therefore, replacing side effects with something in keeping with these core principles is considered an important problem in functional programming. Solutions to this problem are called **effect systems**. 

Nota bene: in this post I use the term *side effect* for uncontrolled effects, and just *effect* for effects that are controlled in a more desirable way.

Monads are the most common effect system in modern functional programming, but this doesn't mean they are the only approach. Older versions of Haskell used streams. The [Clean][clean] language uses uniqueness types, which are very closely related to the affine types seen in Rust's borrow checker. Most current research work focuses on what are called **algebraic effects** and **effect handlers**. It's this kind of approach we will be exploring, though we have some background to get through first.

Now we known why effect systems are interesting, let's look at some of the design choices in effect systems.


## The Design Space of Effect Systems

Reasoning and composition are non-negotiable criteria for any effect system. 
There are other criteria that are desirable, however. 
Here we will look at the style in which code is written, the separation between description and action, and some of the nuances in how effect systems can help us reason about and compose effectful code.

### Direct and Monadic Style

The style of code that we have to write to use the effect system is a major determinant of how usable the system is. If an effect system requires too much work from the programmer it is unusable in practice, no matter what other properties it has. Here we will look at **direct style**, which is code as we want to write it, and **monadic style**, which is code as monadic effect systems force us to write it.

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

Before we get into effect systems, there another issue I want to quickly deal with, which is composition of effects. One criticism of `IO` is that it lumps all effects into one type. We might want to be more precise, and say, for example, *this* method requires logging and database access, while *that* method reads from the keyboard and prints to the screen. Tagless final is sometimes used to achieve this. The method signature

```scala
def cthulhuFhtagn[F[_]: WakeGreatOldOne](): F[Unit]
```

indicates this method requires a `WakeGreatOldOne` effect, which we might use to decide to not call the method.


## Direct-style Effect Systems

Let's now implement a direct-style effect system in Scala 3. This requires some machinery that is new in Scala 3. Since that's probably unfamiliar to many readers we're going to start with an example, explain the programming techniques behind it, and then explain the concepts it embodies.

Our example is a simple effect system for printing to the console. The implementation is below. You can save this in a file (called, say, `Print.scala`) and run it with `scala-cli` with the command `scala-cli Print.scala`.

```scala
//> using scala 3

// For convenience, so we don't have to write Console.type everywhere.
type Console = Console.type

type Print[A] = Console ?=> A
extension [A](print: Print[A]) {

  /** Insert a prefix before `print` */
  def prefix(first: Print[Unit]): Print[A] =
    Print {
      first
      print
    }

  /** Use red foreground color when printing */
  def red: Print[A] =
    Print {
      Print.print(Console.RED)
      val result = print
      Print.print(Console.RESET)
      result
    }
}
object Print {
  def print(msg: Any)(using c: Console): Unit =
    c.print(msg)

  def println(msg: Any)(using c: Console): Unit =
    c.println(msg)

  def run[A](print: Print[A]): A = {
    given c: Console = Console
    print
  }

  /** Constructor for `Print` values */
  inline def apply[A](inline body: Console ?=> A): Print[A] =
    body
}

@main def go(): Unit = {
  // Declare some `Prints`
  val message: Print[Unit] =
    Print.println("Hello from direct-style land!")

  // Composition
  val red: Print[Unit] =
    Print.println("Amazing!").prefix(Print.print("> ").red)

  // Make some output
  Print.run(message)
  Print.run(red)
}
```

We have the usual separation between description and action. In direct-style code, a description is a [context function][context-function]. You can think of a context function as a normal function with `given` (implicit) parameters. In our case the descriptions have the type `Print[A]`, which is an alias for a context function with a `Console` given parameter. (`Console` is a type in the Scala standard library.)

Context function types have a special rule that makes constructing them easier: a normal expression will be converted to an expression that produces a context function if the type of the expression is a context function.
Let's unpack that by seeing how it works in practice.
In the example above we have the line

```scala
val message: Print[Unit] =
  Print.println("Hello from direct-style land!")
```

`Print.println` is an expression with type `Unit`, not a context function type. However `Print[Unit]` is a context function type. This type annotation causes `Print.println` to be converted to a context function type. You can check this yourself by removing the type annotation:

```scala
val message =
  Print.println("Hello from direct-style land!")
```

This will not compile.

We use the same trick with `Print.apply`, which is a general purpose constructor. You can call `apply` with any expression and it will be converted to a context function. (As far as I know it is not essential to use `inline`, but all the examples I learned from do this so I do it as well. I assume it is an optimization.)

Direct-style composition needs another bit of special sauce: if there is given value of the correct type in scope of a context function, that values will be automatically applied to the function. This is what makes direct-style composition, an example of which is shown below, work. The calls to `Print.print` are in a context where a `Console` is available, and so will be evaluated once the surrounding context function is run.

```scala
def red: Print[A] =
  Print {
    Print.print(Console.RED)
    val result = print
    Print.print(Console.RESET)
    result
  }
```

That's the mechanics of how direct-style effect systems work in Scala: it all comes down to context functions.

I'm going to deal with composition of effects and more in just a bit. First though, I want describe the concepts behind what we've done.

Notice in direct-style effects we split effects into two parts: context functions that define the effects we need, and the actual implementation of those effects. In the literature these are called algebraic effects and effect handlers respectively. This is an important difference from `IO`, where the same type indicates the need for effects and provides the implementation of those effects.

Also notice that we use the argument type of context functions to indicate the effects we need, rather the result type as in monadic effects. This difference avoids the ["colored function"][colored-function] problem with monads. We can think of the arguments as specifying requirements on the environment or context in which the context functions, hence the name.

Now let's look at composition of effects, and effects that modify control flow.


### Composition of Direct-Style Effects

Direct-style effects compose in a straightforward way: we just add additional parameters to our context function. Here's a simple example that defines another effect, `Sample`, for producing random values, and then builds a program that requires both `Print` and `Sample`.

First we define the effect, using the same pattern as before.

```scala
import scala.util.Random

// A `Sample[A]` is a description of an effect that, when run, will generate a
// values of type `A` possibly using a random number generator
type Sample[A] = Random ?=> A
object Sample {
  // This runs a `Sample[A]` producing a value of type `A`. By default it uses
  // the global random number generator, but the user can pass in a different
  // generator as the first argument.
  def run[A](random: Random = scala.util.Random)(sample: Sample[A]): A = {
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
```

Now we can use both `Print` and `Sample`.

```scala
val printSample: (Console, Random) ?=> Unit =
  Print {
    val i = Sample { Sample.int }
    Print.println(i)
  }

Print.run(Sample.run()(printSample))
```


### Effects That Change Control Flow

So far, the effects we've looked have very simple control flow. In fact they don't alter the control flow at all. Many interesting effects, such as error handling, concurrency, and backtracking search, require dramatic changes to the control flow of the program. How do we handle this in our model?

We need a slight extension to accomodate this: when the user program calls an effect handler method, the effect handler is passed not just that method's arguments but also also a **continuation** that it can resume when the effect is complete. What's a continuation? It represents the "rest of the program". You can think of it as a coroutine or generator that the effect handler can resume (though coroutines and friends are strictly less expressive than full continuations.) This requires some run-time support, namely the ability to capture and resume continuations.

Scala 3 does not yet have continuations, but it does have non-local exits in `scala.util.boundary` that can express a few interesting things. Here's an example implementing error-handling in the style of exceptions. 

```scala
//> using scala 3

import scala.util.boundary
import scala.util.boundary.{break, Label}

trait Error[-A](using label: Label[A]) {
  def raise(error: A): Nothing =
    break(error)
}

type Raise[A] = Error[A] ?=> A
object Raise {
  inline def apply[A](inline body: Error[A] ?=> A): Raise[A] =
    body

  def raise[A](error: A)(using e: Error[A]): Nothing =
    e.raise(error)

  def run[A](raise: Raise[A]): A = {
    boundary[A] {
      given error: Error[A] = new Error[A]
      raise
    }
  }
}

@main def go(): Unit = {
  val program: Raise[String] =
    Raise {
      // This early return is difficult to write in a purely functional style
      List(1, 2, 3, 4)
        .foreach(x => if x == 3 then Raise.raise("Found 3"))
      "No 3 found"
    }

  val result = Raise.run(program)
  println(result)
}
```

Notice that we still have the separation between description and action. The `program` isn't run until we call `Raise.run`, and the control-flow exits at the point where it is run, not at the point where it is defined.

Using direct-style effects we can write programs that would have to use `traverse` or other combinators in monadic style. Here's an example that produces an `Option[List[Int]]` from a `List[Int]`.

```scala
val traverse: Raise[Option[List[Int]]] =
  Raise {
    Some(
      List(1, 2, 3, 4).map(x => if x == 3 then Raise.raise(None) else x)
    )
  }
println(Raise.run(traverse))
```

This is the equivalent of the following program using Cats:

```scala
val traverseCats: Option[List[Int]] =
  List(1, 2, 3, 4).traverse(x => if x == 3 then None else Some(x))
```

You might wonder how monads implement effects that play with control flow without requiring runtime support. The answer is that monads require the user to explicitly specify the control-flow. This is exactly what `flatMap` does: it expresses what should happen in what order, and by giving the monad this information as a chain of `flatMaps` it can evaluate them in the order that makes sense for the particular monad implementation.


## Capturing, Types, and Effects

What we've seen so far suggests that effects are straightforward to implement and use, and they are for the most part. However there is at least one wrinkle that we need to be aware of: capturing effects.

In the following code we capture a `Error[String]` in a closure, and then attempt to call the `raise` method on that `Error` outside of the block where it is valid. This leads to an error.

```scala
val capture: Raise[() => Raise[String]] =
  Raise { () =>
    if 3 < 2 then "Nothing to see here" else Raise.raise("Hahahahaha!")
  }

val closure = Raise.run(capture)
println(closure)
```

Is this a serious flaw in the entire foundation of direct-style effects? No! What we've seen so far is only the portion of the effect system that is currently in Scala 3. [Capture checking][cc], which is still experimental, rules out this kind of bug. The [Capturing Types][capturing-types] paper has all the technical details.

Capture checking in fact goes further than the examples we've seen so far. It tracks usage in the dynamic scope of the program, which means it can be used to implement, for example, region-based memory management or safe resource usage.


## Conclusions and Further Reading

Overall, I'm pretty excited by direct-style effects in general, and direct-style effects in Scala in particular. I think they are much more ergonomic than monadic effects, which in turn makes them accessible to a wider range of programmers. I'm also excited to have access to continuations, and presumably tail calls, in more languages. Tail calls are really useful for certain problems, such as [virtual machine dispatch][vm-dispatch].

I'm also excited to see Scala continuing to evolve. Scala has always been a language of innovation, and these changes are nothing more than a continuation (pun-intended) of that heritage. These developments will, I think, make Scala Native a interesting and attractive platform. I think it's only in Scala Native that the developers will have the flexibility to implement the runtime support needed for a full effect system, and also to really maximise its advantages by providing things like region based memory management. I also think Scala Native is important for Scala's industrial adoption in use cases like serverless, so I think more investment in Scala Native as a *big* win for the community.

If you'd like to read more about direct-style effects here are some suggestions, which are a mix of accessible introduction and academic papers:

* [Abilities for the monadically inclined][abilities], a very nice post from the Unison team that covers a lot of the same material from a different perspective.
* Dean Wampler's post [What is "Direct Style"][what-is-direct-style].
* The [Gears][gears] concurrency library being developed for Scala 3.
* [Raise4s][raise4s], a simple example of error handling as a direct-style effect.
* [An Introduction to Algebraic Effects and Handlers][handlers-tutorial] is a tutorial from a more theoretic perspective.
* [Handlers in Action][handlers-in-action] is one of the more readable academic papers on implementing effect handlers.
* [Capturing Types][capturing-types] describes the extensions to the Scala type system that are necessary for correctly implementing effects.

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
[cc]: https://dotty.epfl.ch/docs/reference/experimental/cc
[vm-dispatch]: https://noelwelsh.com/posts/understanding-vm-dispatch/
[handlers-tutorial]: https://www.eff-lang.org/handlers-tutorial.pdf
