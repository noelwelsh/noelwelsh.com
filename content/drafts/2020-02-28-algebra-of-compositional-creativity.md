+++
title = "The Algebra of Compositional Creativity"
draft = true
+++

<script defer src="/js/compositional-creativity-opt.js" onload="EntryPoint.go();"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.11.1/dist/katex.min.css" integrity="sha384-zB1R0rpPzHqg7Kpt0Aljp8JPLqbXI3bhnPWROx27a9N0Ll6ZP/+DiW/UqRcLbRjq" crossorigin="anonymous">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.11.1/dist/katex.min.js" integrity="sha384-y23I5Q6l+B6vatafAwxRu/0oK/79VlbSz7Q9aiSZUvyWYIYsd+qj+o24G5ZU2zJz" crossorigin="anonymous"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.11.1/dist/contrib/auto-render.min.js" integrity="sha384-kWPLUVMOks5AQFrykwIup5lo0m3iMkkHrD0uJ4H5cjeGihAutqP0yW0J6dpFiVkI" crossorigin="anonymous"
        onload="renderMathInElement(document.body);"></script>


## Circles

Consider the circle. It's one of the simplest shapes; we can draw it with just a stick and a piece of twine.

[circle]

What if we want to create a circle using a computer. How should we define it?
We could try using a definition from mathematics, stating that a circle is all the points a fixed distance from the origin.

$$\{ (x, y) \in \mathbb{R}^2 | \sqrt{x^2 \times y^2} = 1 \}$$

Unfortunately this definition is not computable. It tells us what a circle is but gives us no way of finding (some subset of) the points that make up a circle in a reasonable amount of time.

Better is to use a different tool, called a parametric equation. In programming terms this is simply a function from some input (the parameter) to a point. In Scala we can define the unit circle as so:

```scala
import doodle.core._

val unitCircle = (a: Angle) => Point(1.0, a)
```

Here we're defined points in polar form---using an angle and a radius---instead of cartesian form---in terms of x- and y-coordinates.

We could plot this shape, but if we want to see something that looks like a circle we need to scale the points so they're a bit further from the origin. Right now they'll just be drawn all on top of each other unless we zoom in a lot. Scaling is another function, in this case from a point to a point. We can define this in code.

```scala
val scale = (factor: Double) => (pt: Point) => pt.scaleLength(factor)
```

Now we can combine---more formally, compose---these two functions to produce a circle we can usefully visualize.

```scala
val largeCircle = unitCircle.andThen(scale(100))
```

Finally we can visualize our circle by sampling points at a number of different angles and drawing these points on the screen.

We'll start by defining the shape we'll use to draw the points. We'll put in a little bit of effort to make this pretty, because it's worth it. Don't worry if you find the type signature here a bit odd. It just makes it easier for me to write code that I can draw on a web page and you can paste into a Scala console.


```scala
import doodle.language.Basic
import doodle.algebra.Picture
import doodle.syntax._

def dot[Alg[x[_]] <: Basic[x], F[_]]: Picture[Alg, F, Unit] =
  circle(10)
    .fillColor(Color.deepPink)
    .strokeColor(Color.deepPink.spin(-15.degrees))
    .strokeWidth(3.0)
```

Our next step is to create a method that samples from a parametric equation and produces an animation. We'll use this a lot in this post so it's worth creating the abstraction.

```scala
import cats.implicits._
import doodle.interact.syntax._
import doodle.interact.animation.Transducer

def sample[Alg[x[_]] <: Basic[x], F[_]](stop: Angle, steps: Int)(f: Angle => Point): Transducer[Picture[Alg, F, Unit]] =
  (0.degrees)
    .upToIncluding(360.degrees)
    .forSteps(17)
    .scanLeft(empty[Alg, F]) { (picture, angle) =>
      picture.on(circle(10).at(largeCircle(angle)))
    }
```

Now let's create an animation. We'll repeat the animation five times, so you can get a good look at it.

```scala
import doodle.java2d._
import monix.reactive.Observable
import scala.concurrent.duration._

sample(360.degrees, 17)(largeCircle)
  .repeat(5)
  .toObservable
  .withFrameRate(100.millis)
  .animate(Frame.size(300, 300).background(Color.midnightBlue))
```

<figure>
  <div id="circle"></div>
  <figcaption>A circle</figcaption>
</figure>

We have a circle!

It took a bit of code to get to the result. Our topic is creativity, not code, so don't worry if you don't follow all the details in the code. The code makes the ideas concrete but don't let lack of familiarity with the coding patterns distract you from the ideas.


## Changing Scale

Where can we go from here? Our strategy is to look at the components that make up our current system, and then change a component. Right now our `largeCircle` consists of two parts: the unit circle and the scaling. Let's changing the scaling at see we come up. Currently our scaling is constant. We might instead make it a function of the angle, perhaps so it increases as the angle increases.


This is perhaps the simplest function we can use. We convert the angle to "turns". A full circle is one turn, half a circle is half a turn, and so on.

```scala
val linear = (pt: Point) => pt.scaleLength(pt.angle.toTurns)
```

Now we can combine this with our `unitCircle` function to create a spiral (in particular, it is an [Archimedean spiral](https://en.wikipedia.org/wiki/Archimedean_spiral)).

```scala
val archimedeanSpiral = unitCircle.andThen(linear)
```

As with our circle we need to scale the spiral before we can usefullly visualize it.

```scala
val largeArchimedeanSpiral =
  archimedeanSpiral.andThen(scale(100))
```

Finally, our animation as before. This time we sample a larger range to display more of the spiral's shape.

```scala
sample(1080.degrees, 49)(largeArchimedeanSpiral)
  .repeat(5)
  .toObservable
  .withFrameRate(100.millis)
  .animate(Frame.size(600, 600).background(Color.midnightBlue))
```

<figure>
  <div id="archimedean"></div>
  <figcaption>An Archimedean spiral</figcaption>
</figure>

Now we have the basic idea we can go wild trying different functions for building spirals. Here are a few examples.

```scala
import scala.math._
val power = (p: Double) => (pt: Point) => pt.scaleLength(pow(pt.angle.toTurns, p))
val exponential = (pt: Point) => pt.scaleLength(exp(pt.angle.toTurns))
```

We can build spiral animations as before. This time I've plotted the spirals on top of each other.

```scala
val logarithmicSpiral = unitCircle.andThen(exponential).andThen(scale(50))
val quadraticSpiral = unitCircle.andThen(power(2)).andThen(scale(50))

def spiralAnimation[Alg[x[_]] <: Basic[x], F[_]]
    : Observable[Picture[Alg, F, Unit]] =
  sample[Alg, F](1080.degrees, 97)(logarithmicSpiral)
    .product(sample[Alg, F](1080.degrees, 97)(quadraticSpiral))
    .map {
      case (log, quad) =>
        log
          .fillColor(Color.hotpink)
          .strokeColor(Color.hotpink.spin(-15.degrees))
          .on(quad)
    }
    .repeat(5)
    .toObservable
    .withFrameRate(100.millis)
```

Finally render the animation.

```scala
spiralAnimation.animate(Frame.size(900, 900).background(Color.midnightBlue))
```

<figure>
  <div id="spiral"></div>
  <figcaption>Lots of spirals</figcaption>
</figure>

There are many other functions you could try. What happens if you use, say, \\\( cos^2 \\\)? What if you mix a few functions together? Explore and have fun.


## Changing Shape

What else could we change? Changing shape is the other major components


## What's Left?

Color, animation speed, lines instead of dots.
