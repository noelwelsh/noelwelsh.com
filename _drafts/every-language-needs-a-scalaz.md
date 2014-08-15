---
layout: post
title: Every Language Needs Its Scalaz
category: programming
repost: underscore
---

I recently read a blog post entitled [Why Every Language Needs Its Underscore](http://hackflow.com/blog/2014/06/22/why-every-language-needs-its-underscore/), a sentiment we at [Underscore](http://underscoreconsulting.com) agree with. The point of the post was to show the usefulness of functional programming idioms, with reference to the [Underscore.js](http://underscorejs.org) library. The examples were all in the style of what I might write in [Racket](http://racket-lang.org). I thought it would be interesting to translate the examples to Scala. There are few changes here: the types of some constructs change[^union-typed], but more interesting is how we can be more abstract by using type classes.

My goal with this post is to explain what type classes are, and show how they allow us to solve the problems from the "Every Language" blog post in a very abstract way. That is, we don't have to specify very many concrete types at all, and so our program will work with a wide range of code. When writing the code I went *full astronaut*. That is, I made everything as abstract as I could. But don't worry! I'll describe the process to reaching this code, so you can understand the path to getting there.

My code makes use of [Scalaz](http://github.com/scalaz/scalaz). I've put a complete project [on Github](https://github.com/underscoreio/every-language-scalaz) so you can compile it yourself and play around.

[^union-typed]: In a language like Python you can store, say, an integer or false in a dictionary. You can't do this directly in Scala, because there is no useful type that contains both `Int` and `Boolean`. (There is `Any` but it is not useful to use this type.) The typical solution in Scala is to use `Option`. Some typed languages, like [Typed Racket](http://docs.racket-lang.org/ts-guide/index.html?q=typed), support [union types](http://en.wikipedia.org/wiki/Type_system#Union_types) which would allow to express "integer or false" directly in the type system without have the wrapper required in Scala.

## Type Classes

Before we get into the code let's quickly cover type classes, which are the big idea I'm leveraging here. There are three components to type classes.

The first feature of type classes is that they allow us to express common functionality between otherwise unrelated types. For instance, `Int`s, `String`s, and `Set`s can all be "added" (integer addition, string concatentation, and set union). With a type class we can express this, even though there is no useful supertype that these types have in common.

Big deal you say -- I can do this with an interface. The next trick that type classes have is they allow us to add functionality to code for which we can't modify the source.

The final thing we can do with type classes is have more than one implementation of them for a given type. For example, from an abstract perspective addition and multiplication both work as "adding" numbers: they are both commutative, associatitive, and have an identity element (0 and 1 respectively).

Type classes tend to be very abstract things, like the "addable" example above. We'll see some more examples in just a moment.

## Retrying on Failure

The first example from the blog post is retrying a function on failure. The signature of method we want to implement is

~~~ scala
def retry[A](attempts: Int)(f: => A): A = ???
~~~

The idea is we evalute `f`. If `f` fails we'll retry it up to `attempts` times. We can write this very easily as

~~~ scala
def retryException[A](tries: Int)(f: => A): A =
  tries match {
    case 0 => f
    case n =>
      try {
        f
      } catch {
        case exn =>
          retryException(n - 1)(f)
      }
  }
~~~

Job done. Not so fast! I promised you we'd go full astronaut, and this code hasn't even made it out of the troposphere. What's wrong with it? There are a few cosmetic issues. It doesn't check that `retries` is greater than or equal to zero, if we're going to use a tail-recursive loop we should add a `@tailrec` annotation, and finally it doesn't allow the user to specify which exceptions to catch and which to propagate on. This are are minor quibbles, because the fundamental flaw is that type astronauts don't use exceptions in the first place! Exceptions are reflected in the type system, so we can't use the type system to guarantee we perform error handling if we use exceptions. Instead we should use a type like `Option`, `Try`, or `\/` (Scalaz's equivalent to `Either`). Which one? We are not going to force a choice -- we're going to allow the function `f` to return any type that meets the constraints we specify. Ready for lift off? Let's go.



## Cleaning a Map

## Iterating Over Pairs
