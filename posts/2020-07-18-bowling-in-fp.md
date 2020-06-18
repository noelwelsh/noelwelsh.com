---
title: Scoring Ten-Pin Bowling with FP
---

I recently led a training session where we implemented the [rules for scoring ten-pin bowling][bowling-case-study] in Scala. This is an interesting case study. It's small enough that you can pick up the rules in a few minutes, but the dependencies between frames makes calculating the score non-trivial. I found it interesting enough that I implemented [my own solution][implementation] and decided to write up my process here. 

For my implementation I solely focused on scoring the game. I didn't implement any parsing code, as that part of the problem didn't interest me.

<!--more-->

## The Data

The core of my approach is getting the data structure right. Once they're in place the rest of the code is relatively straightforward. This approach relies on some foundational features of functional programming, namely algebraic data types and structural recursion. Lets have a quick diversion into these topics.

### Algebraic Data Types and Structural Recursion

"Algebraic data type" is a fancy phrase that functional programmers use to refer to data that is modelled in terms of logical ands and logical ors. Here are some examples:

- a `User` is a name *and* an email address *and* a password;
- a `Result` is a success *or* a failure;
- a `List` of `A` is:
    - the empty list (conventionally called nil) *or*
    - a pair (conventionally called cons) containing a head of type `A` *and* a tail of type `List` of `A`.

If a language has support for algebraic data types, once we have a description of data such as the examples above we can directly translate it into code. Let's use the example of the list as it is the most complex.

Here's how we can define it in Scala.

```scala
sealed trait List[A]
final case class Nil[A]() extends List[A]
final case class Cons(head: A, tail: List[A]) extends List[A]
```

Here's the same thing in Typescript.

```javascript
type Nil<A> = { kind: "nil" }
type Cons<A> = { kind: "cons", head: A, tail: List<A> }
type List<A> = Nil<A> | Cons<A>

const Nil = <A>(): List<A> => 
  ({ kind: "nil" });
const Cons = <A>(head: A, tail: List<A>): List<A> => 
  ({ kind: "cons", head: head, tail: tail });
```

Here's Rust.

```rust
enum List<A>{
    Nil,
    Cons(A, Box<List<A>>)
}
```

Each language requires some language specific knowledge in the implementation. For example:

- in Scala we can choose between covariance and invariance;
- in Typescript we need to define constructors seperately;
- in Rust we must wrap recursion in a `Box`.

The general concept, however, applies to all these languages and we can transfer knowledge from one language to another. To avoid writing all the code three times for the rest of this post I'll be sticking to Scala.

Given an algebraic data type we can implement *any* transformation on that type using structural recursion (also known as a fold or a catamorphism)[^proof]. The rules, informally, for structural recursion are:

- each case (logical or) in the data must have a case in the structural recursion; and
- if the data we are processing is recursive the function we are defining must be recursive at the same place.

Structural recursion cannot solve everything for us---we must add problem-specific code to fill out the implementation---but it gives us a substantial help. 

Here's one way we could write the structural recursion skeleton for a list in Scala.

```scala
def transform[A](list: List[A]): SomeResultType =
  list match {
    case Nil() => 
      ???  // Problem specific
    case Cons(h, t) => 
      ??? // Problem specific but *must* include the recursion transform(t)
  }
```

If we want to calculate the length of a list we can start with the skeleton

```scala
def length[A](list: List[A]): Int =
  list match {
    case Nil() => 
      ???  // Problem specific
    case Cons(h, t) => 
      ??? // Problem specific but *must* include the recursion length(t)
  }
```

and fill out the problem specific parts

```scala
def length[A](list: List[A]): Int =
  list match {
    case Nil() => 
      0
    case Cons(h, t) => 
      1 + length(t)
  }
```

Any (yes, really, any) other method we can write that transforms a list to something else (or even another list) is going to have the same skeleton. So in summary, all we have to do is work out how to model our data using logical ands and ors and then we immediately get for free:

- the representation of that data in code; and
- a generic template for transforming that data into anything.

Diversion over! Let's get back to bowling.


## Bowling as an Algebraic Data Type

From reading the rules of bowling we can pull out a reasonably simple structure:

- A game consists of 10 frames
- Each frame can be a strike, a spare, or an open frame where
    - an open frame is two rolls that sum to less than ten;
    - a spare is one roll that is less than ten (the second rule is implied by the first roll); and
    - a strike doesn't need any additional information.
  
This is the model I started with but as I worked on it I realised the true model is more complicated because the final frame may have up to two bonus rolls. Hence I changed the model to

- A game consists of 9 frames and 1 final frame
- A frame can be a strike, a spare, or an open frame where
    - an open frame is two rolls that sum to less than ten;
    - a spare is one roll that is less than ten (the second roll is implied by the first roll); and
    - a strike doesn't need any additional information.
- A final frame can be a strike, a spare, or an open frame which have the same definition as above and also
    - a spare final frame has one bonus roll; and
    - a strike final frame has two bonus rolls.
  
These definitions fit the criteria for an algebraic data type (they consist of logical ands and ors) and therefore translate to code in a straightforward way. Rather than paste a big lump of code I'll just link to [Frame][frame], [FinalFrame][finalframe], and [Game][game] in the code repository. Note that not all the invariants can be expressed in the type system. For example, we cannot express the criteria that the rolls in an open frame must sum to less than 10. The problem specification says we only need to consider valid data, but I put some dynamic checks in the "smart constructors" on the companion objects. This turned out to be useful as it caught some errors in my tests (which I'll talk about in a bit.)

Now that we have defined the data we just need to write a structural recursion over the `Game` type. Well, not quite. The scoring rules have dependencies between frames. For example, if a frame is a strike the next two rolls are added to the score for that frame. We need to keep around the information about pending frames---frames that have yet to be scored---while we process the data.

Reading through the rules we can extract the following.

The pending frames can be

- a strike; 
- a spare; or
- a strike and a strike .

This is another algebraic data type.

```scala
sealed trait Pending
case object Strike extends Pending
case object Spare extends Pending
case object StrikeAndStrike extends Pending
```

When we score a frame in a game we must calculate:

- the score for this frame if it is not pending futures frames;
- the score for any pending frames that are now complete; and
- the pending frames after this frame.

In this way the scoring algorithm is a finite state machine (FSM). The pending frames are the current state of the FSM, the current frame is the output, and we output the next state (the updated pending frames) in addition to a score.

It's useful to wrap the `Pending` information up with the score calculated so far, which gives all the information to calculate the total score so far. I called this `State`. Note that `Pending` is wrapped in an `Option`; there may be no frames for which the score is pending.

```scala
final case class State(
    score: Int,
    pending: Option[Pending]
) {
  def next(additionalScore: Int, newPending: Option[Pending]): State =
    this.copy(
      score = score + additionalScore,
      pending = newPending
    )
}
```

With this definition the scoring function has type `(State, Frame) => State`, which is exactly the type of the transition function of a FSM. We can calculate the score of a `List[Frame]` by passing this function as the second argument to `foldLeft`, with the initial state forming the first argument. In code this is

```scala
frames.foldLeft(initialState)(transitionFunction)
```

The transition function, the scoring algorithm, is a structural recursion over the `Frame` as well as the `State`. [The code is lengthy][score], but it isn't hard to write and a good deal of it is generated by the IDE (in my case, Metals with Doom Emacs.)

### Testing

Testing was important. The scoring rules aren't amenable to much support from the type system (though now I think about it I could have expressed the rules in a different way that would have given me more compiler support) which means testing is the next best way to ensure the code is correct. This is an excellent application for property-based testing, for which I used [ScalaCheck][scalacheck].

I defined a few different [generators][generators] for the various types of frames. For example here is how I generate open frames.

```scala
def genOpen: Gen[Frame] = {
  for {
    misses <- Gen.choose(1, 10)
    hits = 10 - misses
    roll1 <- Gen.choose(0, hits)
    roll2 = hits - roll1
  } yield Frame.open(roll1, roll2)
}
```

These generators enabled me to [test][gamespec] both the examples given in the instructions and examples generated at random. I found quite a few errors with these tests, both in my scoring algorithm and in how I was generating data. Luckily they were all very easy to diagnose. As the scoring algorithm was very explicit it was easy to work out what I had done wrong (which was usually forgetting to include a roll somewhere).


## Conclusions

I hope this article has given an insight in how I approached this case study. In summary there are three important components:

- the core of my approach is to model the data correctly, as I know once I have the data model in place almost all of the rest of the code follows from it;
- recognising the scoring algorithm was a finite state machine was another insight I needed to model it cleanly; and
- using property-based testing allowed me to achieve a high degree of confidence in my implementation without a great deal of effort.

I have presented my process as if I moved straight from problem to implementation. This was *not* the case. It was a highly iterative process, and I changed the data model at least three times as I came to better understand the problem. I also interleaved developing the tests with the code under test.

Of course my approach is the only one. There is a write-up of a [TDD approach in C#][ron-jeffries] which may make an interesting contrast to mine.

[bowling-case-study]: https://github.com/davegurnell/bowling-case-study/
[implementation]: https://github.com/noelwelsh/bowling-case-study/
[ron-jeffries]: https://ronjeffries.com/xprog/articles/acsbowling/
[malcolm90]: https://www.sciencedirect.com/science/article/pii/0167642390900237 
[hutton99]: https://www.cs.nott.ac.uk/~pszgmh/fold.pdf
[scalacheck]: http://scalacheck.org/
[frame]: https://github.com/noelwelsh/bowling-case-study/blob/master/src/main/scala/code/Frame.scala
[finalframe]: https://github.com/noelwelsh/bowling-case-study/blob/master/src/main/scala/code/FinalFrame.scala
[game]: https://github.com/noelwelsh/bowling-case-study/blob/master/src/main/scala/code/Game.scala
[score]: https://github.com/noelwelsh/bowling-case-study/blob/master/src/main/scala/code/Game.scala#L7-L105
[generators]: https://github.com/noelwelsh/bowling-case-study/blob/master/src/test/scala/code/Generators.scala
[gamespec]: https://github.com/noelwelsh/bowling-case-study/blob/master/src/test/scala/code/GameSpec.scala

[^proof]: Although this is well known in programming language theory I haven't been able to find a reference that has a chance of being comprehensible to the average programmer. I think the first place to state this result is [Data Structures and Program Transformation][malcolm90], but this uses the Bird-Meertens formalism which I find very hard to read. [A tutorial on the universality and expressiveness of fold][hutton99] only considers folds on list, but uses Haskell and more standard mathematical notation. I imagine this is still quite obscure for most but it is an improvement!
