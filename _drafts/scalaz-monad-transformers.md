---
layout: post
title: "Scalaz Monad Transformers"
description: ""
category: programming
lead:
---

Monad transformers allow us to stack monads. Say we have a monad, like `Option`, and we want to wrap it in another monad, like `\/`, in a convenient way (where convenient is to be defined shortly). Monad transformers let us do this. Scalaz comes with lots of monad transformers. Let's see how to use them and the benefits they supply.

## Example

Let's motivate monad transformers with the above example. We have an operation that may or may not generate a value. Something like getting a value from a database. Thus we model it as an `Option`. This operation may also encounter various other errors. To keep things simple we'll encode the errors as `String`s. So we basically have three different types of result:

1. value found;
2. value not found; or
3. error occurred.

We can model this as `type Result[+A] = String \/ Option[A]`. (Note that `\/` is Scalaz's version of `Either`.)  We can construct values of this type by hand:

{% highlight scala %}
import scalaz._
import Scalaz._

type Result[+A] = String \/ Option[A]

val result: Result[Int] = some(42).right
// result: Result[Int] = \/-(Some(42))
{% endhighlight %}

To use `result` we must unwrap it twice, which is tedious:

{% highlight scala %}
val transformed =
  for {
    option <- result
  } yield {
    for {
      value <- option
    } yield value.toString
  }
// transformed: scalaz.\/[String,Option[String]] = \/-(Some(42))
{% endhighlight %}

This is fairly horrible. The desugared version is actually a bit clearer:

{% highlight scala %}
val transformed = result map { _ map { _.toString } }
// transformed: scalaz.\/[String,Option[String]] = \/-(Some(42))
{% endhighlight %}

Still, can't we avoid this nesting? It seems like we should be able to chain calls to `flatMap` and friends and just have it do the right thing. With monad transformers we can. Here's the transformed version.

{% highlight scala %}
type Error[+A] = \/[String, A]
type Result[+A] = OptionT[Error, A]

val result: Result[Int] = OptionT(some(42).point[Error])
val transformed =
  for {
    value <- result
  } yield value.toString
{% endhighlight %}

There are three changes:

1. the type definitions;
2. the way we construct values of these new types; and
3. the removal of one layer of nesting.

Let's go through these in order.

## Type Definitions



The type `OptionT[M, A]` is a monad transformer that
