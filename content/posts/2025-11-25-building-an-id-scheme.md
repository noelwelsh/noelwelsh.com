+++
title = "Designing an ID Generation Scheme"
+++

In this post I'll describe the process of creating an algorithm for generating unique identifiers.
This combines mathematics, computer science, and business requirements.
It is one of the more interesting problems I've worked on recently, 
and I think it makes a good case study of how theory and practice go together.

<!-- more -->

## Identifiers

Just about every piece of data needs some kind of unique identifier.
Random (type 4) [UUIDs][uuid] are my preferred way to create these identifiers. 
With 122 bits of random data, there is a very low chance of generating the same UUID more than once (known as a collision). 
Random UUIDs also don't require coordination between processes, which simplifies implementation.
Furthermore, libraries abound for their generation and use.

In a recent project we were unable to use a standard random UUID.
The system shared identifiers with a third-party that only supported up to 20 alphanumeric characters.
This equates to just over 103 bits of information, which is not enough to store the 122 bits in a type 4 UUID.
The UUID standard allows custom UUIDs, called a type 8 UUID. 
Like a type 4 UUID they also allow up to 122 bits of data.
Therefore, if we can come up with our own algorithm, 
generating up to 103 bits of random data, 
we can represent it as a type 8 UUID to interoperate with existing systems.


## Design

We've identified we need 103 bits of random data, so it seems we can immediately turn to generating that data.
However, that is not the case.
We need to first address a business requirement:
our identifiers will be visible to customers.
There are many 20 character alphanumeric strings, like `"pleasegofuckyourself"`, that we don't want them to see.
There is no *great* way to avoid generating potentially offensive strings, but a simple and reasonable approach to mitigation is to drop vowels.
Without vowels a customer will at least have to do some creative interpretation before deciding an identifier is actually a coded insult.
However, this reduces the information capacity of identifiers to just 99 bits.

Now we have determined we have 99 bits of information to work with, 
we must decide how to apportion this between random data 
and other components such as timestamps or sequence numbers.
The key question is: how likely are we to generate the same identifier more than once?
For purely random data, the probability of generating a collision is an instance of the [birthday paradox][birthday-paradox].
There are several approximations to this probability.
We'll use

\\[ P(n, d) \approx 1 - e^{- \frac{n(n-1)}{2d}} \\]

where \\(n\\) is the number of identifiers we'll generate and \\(d\\) is the number of possible identifiers.
The choice of \\(n\\) again brings in business requirements.
For this example I'll go with 100,000,000.
Plugging these values in the equation (and using a calculator capable of high precision, such as [Wolfram Alpha][alpha]) gives us a result of

\\[ P(100000000, 2^{99}) \approx 7.89 \times 10^{-15} \\]

This is a very low probability of collision, 
so if these assumptions are reasonable purely random data makes for an acceptable generation scheme.

It is worthwhile, however, considering if adding structured data can lead to a better identifier.
In Twitter's [Snowflake][snowflake] scheme, for example, identifiers combine a timestamp, a machine identifier, and a machine-specific sequence number.
We quickly discarded machine identifiers and sequence numbers as require additional infrastructure to coordinate allocation and store values.
Timestamps, however, require no additional infrastructure so we'll examine them here.

Using a timestamp take away some bit from random data.
For example, a 100-year timestamp with 1 second resolution requires 32-bits.
This gives us 67 bits left to devote to random data. 
If the rate of identifier generation is low enough, 
and the expected lifespan of the identifiers is short enough, 
the bits we lose a timestamp can be made up for by the decreased probability of a collision arising from the smaller number of identifiers in the timestamp window.
If we expect a maximum of, say, 5 identifiers to be generated in a 1 second window, the [probability of collision][alpha-2] becomes approximately 

\\[ P(5, 2^{67}) \approx 6.78 \times 10^{-20} \\]

This is a lower probability of collision than we had without timestamps. 
Timestamps also allow us to sort identifiers.

How should we decide that 5 identifiers per second is a good cutoff? If we assume that requests for identifiers are distributed according to a Poisson distribution, with a mean rate of 100,000,000 divided by the 3.1 billion seconds in a century, we can use the Poisson's cumulative distribution function to give a probability to this occurring. The probability of more than 5 timestamps per second is low enough that we expect it to never occur in a century. 


## Implementation

Whichever scheme we choose, with or without timestamps, needs an implementation. Generating the random data is easy enough, but massaging it into the binary format of a UUID used some skills that I haven't touched in a long while. [Bit masking][bit-masking] is fairly straight-forward, but I was tripped up when I forgot to use an unsigned right-shift to access the data. A 128-bit UUID is generally represented as two 64-bit `Longs`. The JVM (this was implemented in Scala) lacks unsigned integer types, so some of the `Long` values will be interpreted as negative values in [two's complement][twos-complement] form. A normal right-shift will fill values with `1` instead of `0`. For example, if we create the 32-bit `Int` that is all `1s` and right-shift it, we end up with all `1s`; in other words the same value.

```scala
 0xFF_FF_FF_FF >> 16
// val res: Int = -1
```

The solution is to use the unsigned shift `>>>`.

```scala
0xFF_FF_FF_FF >>> 16
// val res: Int = 65535
```

Note that in Scala 3 we can write separators (`_`) in numbers, and also [binary literals][binary-literal], which is quite handy for this kind of bit manipulation.

The resulting library is an ideal use-case for [property-based testing][scalacheck], and we can also run simulations to test our assumptions.


## Conclusions

Randomly generating data makes inefficient use of the available space, but saves us the cost of coordination. If we have enough space this tradeoff can be worthwhile. I showed how we can analyse the tradeoff in terms of the probability of collision, and how adding structured data, such as timestamps, can change the analysis.

This is not the kind of work that is common for developers, and I think there is a natural tendency to wonder if this level of analysis is necessary. I have two data points suggesting that it is. The first is the system this code replaced. I don't remember the details, but I do remember:

* I worked out the probability of collisions was about 0.5, and collisions were observed in practice.
* The previous developers had addressed collisions by regenerating identifiers until they produced one that did not collide. This process was slow, took time that increased with the number of identifiers in use, and suffered from a race condition.

When talking about this system with a developer on another team, they told me about a different identifier generation scheme that also had problems. So it appears that problems with identifiers are more common than I would have though, and a bit of design work goes a long way.

I think this case study is also a great example of the value of the core computer science curriculum. It's common to read that studying computer science is worthless. ([For example][cs-worthless]; there are plenty more.) There is nothing here that isn't covered in a standard CS curriculum&mdash;basic probability and combinatorics, and binary representations and bit manipulation&mdash;and yet it seems in practice these skills are not common.

[uuid]: https://en.wikipedia.org/wiki/Universally_unique_identifier
[birthday-paradox]: https://en.wikipedia.org/wiki/Birthday_problem
[alpha]: https://www.wolframalpha.com/input?i2d=true&i=1+-+Power%5Be%2C-+Divide%5B100000000+*+%5C%2840%29100000000+-+1%5C%2841%29%2C2+*+Power%5B2%2C99%5D%5D%5D
[alpha-2]: https://www.wolframalpha.com/input?i2d=true&i=1+-+Power%5Be%2C-+Divide%5B5+*+%5C%2840%295+-+1%5C%2841%29%2C2+*+Power%5B2%2C67%5D%5D%5D
[bit-masking]: https://en.wikipedia.org/wiki/Mask_(computing)
[twos-complement]: https://en.wikipedia.org/wiki/Two%27s_complement
[binary-literal]: https://docs.scala-lang.org/scala3/reference/other-new-features/binary-literals.html
[scalacheck]: https://scalacheck.org/
[cs-worthless]: https://www.reddit.com/r/csMajors/comments/nwpk78/cs_degrees_are_a_waste_of_time/
[snowflake]: https://en.wikipedia.org/wiki/Snowflake_ID
