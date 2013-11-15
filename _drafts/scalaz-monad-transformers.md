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

val result: Result[Int] = 42.point[Result]
val transformed =
  for {
    value <- result
  } yield value.toString
{% endhighlight %}

There are three changes:

1. the type definitions;
2. the way we construct values of these new types; and
3. the removal of one layer of nesting when we use the monad.

Let's go through these in order.

## Type Definitions

The type `OptionT[M, A]` is a monad transformer that constructs an `Option[A]` inside the monad `M`. So the first important point is the monad transformers are built from the inside out.

Note that I define a type alias `Error` for the monad we wrap around the `Option`. Why is this the case? It has to do with type inference. `OptionT` expects `M` to have a type (technically, a kind) like `M[A]`. This is, `M` should have a single type parameter. `\/` has two type parameters, the left and the right types. We have to tell Scala has to get from two type parameters to one. One option is to use a type lambda:

{% highlight scala %}
type Result[A] = OptionT[{ type l[X] = \/[String, X] }#l, A]
{% endhighlight %}

Clearly this horror should not be inflicted on the world. A saner option is to just define the type as I have done above with `Error`.

## Constructing Values

Constructing values of `Result` can be done in a variety of ways, depending on what we want to achieve.

If we want to construct a value in the default way, we can use the `point` method like so:

{% highlight scala %}
val result: Result[Int] = 42.point[Result]
// result: Result[Int] = OptionT(\/-(Some(42)))
{% endhighlight %}

Note that this wraps our value in `Some` and a right `\/`.

What if we want, say, a `None` for the option. We can't use `point` as we have above:

{% highlight scala %}
None.point[Result]
// Result[None.type] = OptionT(\/-(Some(None)))
{% endhighlight %}

The solution is to use the `OptionT` constructor:

{% highlight scala %}
val result: Result[Int] = OptionT(none[Int].point[Error])
// result: Result[Int] = OptionT(\/-(None))
{% endhighlight %}

Here I've used Scalaz's `none` and `point` on `Error`.

If we want to create a left `\/` we need to do a bit more work:

{% highlight scala %}
val result: Result[Int] = OptionT("Error message".left : Error[Option[Int]])
// result: Result[Int] = OptionT(-\/(Error message))
{% endhighlight %}


## Using the Monad

When we use our new monad `map` and `flatMap` do multiple levels of unwrapping for us.

{% highlight scala %}
val result = 42.point[Result]
result.map(x => x + 2)
// scalaz.OptionT[Error,Int] = OptionT(\/-(Some(44)))
result.flatMap(_ => "Yeah!".point[Result])
// scalaz.OptionT[Error,java.lang.String] = OptionT(\/-(Some(Yeah!)))
{% endhighlight %}

Of course we might not want to unwrap all the layers of our monad.
