+++
title = "Designing an ID Generation Scheme"
+++

For a recent project I developed an algorithm for generating unique identifiers.
This was a lot of fun, and involved a combination of mathematics, computer science, and business requirements.


In most situations random (type 4) [UUIDs][uuid] are a good way to generate unique identifiers. 
With 122 bits of random data, the chance of a collision (generating the same UUID more than once) is very low. 
This means they don't require coordination between processes, which simplifies implementation.
Furthermore, libraries abound for their generation and use.

However, in a recent project we were forced to come up with our own algorithm for generating identifiers.
The system integrated with a third-party, and they only supported identifiers with up to 20 alphanumeric characters.
This equates to just over 103 bits of information, which is not enough to store a type 4 UUID.
The UUID standard allows custom UUIDs, called a type 8 UUID in the spec. 
Like a type 4 UUID they also allow 122 bits of data.
Thus we can create identifiers using our own algorithm, and represent them as type 8 UUIDs to interoperate with existing libraries.

## Design

It seems like the next step is to create our identifier generation algorithm, but no! 
First we should address a business requirement.
Our identifiers will be visible to customers.
There are many 20 character strings, like `"pleasegofuckyourself"`, that we don't want them to see.
There is no *great* way to avoid generating potentially offensive strings, but a simple and reasonable approach to mitigation is to drop vowels.
Without vowels a customer will at least have to do some creative interpretation before deciding an identifier is actually a coded insult.
However, this reduces the information capacity of identifiers to just 99 bits.

Now we can get on to generating identifiers.
The key question is: how likely are we to generate the same identifier more than once?
The probability of generating such a collision is an instance of the [birthday paradox][birthday-paradox].
The [Wikipedia page][birthday-paradox] gives several approximations for this probability.
We'll use

\\[ P(n; d) \approx 1 - e^{- \frac{n(n-1)}{2d}} \\]

where \\(n\\) is the number of identifiers we'll generate and \\(d\\) is the number of possible identifiers.
The choice of \\(n\\) again brings in business requirements.
For the real system it was expected to be in the low millions.
For this example I'll go with 10,000,000.
Plugging these values in the equation (and using a calculator capable of high precision, such as [Wolfram Alpha][alpha]) gives us a result of

\\[ P(10000000, 20^{31}) \approx 2.33 \times 10^{-27} \\]

Thus we have a very low probability of collision under the given assumption, which in most situations makes for an acceptable generation scheme.

We can do better if we know something about the rate of identifier generation and the expected lifespan of the identifiers.
If the rate of generation is low enough, we can give some bits over to a timestamp.
If the rate of identifier generation is low enough, 
and the expected lifespan of the identifiers is short enough, 
the bits we lose to the timestamp can be made up for by the smaller number of identifiers in the timestamp window.

For example, a 100-year timestamp with 1 second resolution requires just under 32-bits.
This gives us 90 bits left in a UUID that we can devote to random data. 
If we expect only, say, 3 identifiers to be generated in a 1 second window, the probability of collision becomes approximately 

\\[ P(3, 2^{90}) \approx 2.42 \times 10^{-27} \\]

This is just about the same probability as we had without timestamps, and with timestamps we can sort our UUIDs.
If being able to sort UUIDs is valuable, we may choose the timestamp route.
The numbers worked out slightly differently for the project I worked on, with the probability of collisions with timestamps being a few orders of magnitude lower.
In this case deciding to use timestamps was a straightforward decision.

How should we decide that 3 identifiers per second is a good cutoff? If we assume that requests for identifiers are distributed according to a Poisson distribution, with a mean rate of 10,000,000 divided by the 3.1 billion seconds in a century, we can use the Poisson's cumulative distribution function to give a probability to this occurring. The probability of more than 3 timestamps per second is low enough that we expect it to never occur in a century. 


## Implementation

Whichever scheme we choose, with or without timestamps, needs an implementation. Generating the random data is easy enough, but massaging it into the binary format of a UUID used some skills that I haven't touched in a long while. [Bit masking][bit-masking] is fairly straight-forward, but I was tripped up for a while when I forgot to use an unsigned right-shift to access the data. A 128-bit UUID is generally represented as two 64-bit `Longs`. The JVM (this was implemented in Scala) lacks unsigned integer types, so some of the `Long` values will be interpreted as negative values in [two's complement][twos-complement] form, and a normal right-shift will fill values with `1` instead of `0`. For example, if we create the 32-bit `Int` that is all `1s` and right-shift it, we end up with all `1s`; in other words the same value.

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

The resulting library is an ideal use-case for [property-based testing][scalacheck], and we can even run simulations to test our assumptions.


## Conclusions

This is not the kind of work that is common for developers, and I think there is a natural tendency to wonder if this kind of analysis is necessary. I have two data points suggesting that it is. The first is the system this code replaced. I don't remember the details, but I do remember:

* The approximate probability of collisions was about 0.5, and collisions were observed in practice.
* The solution to collisions was to generate new identifiers until finding one that did not collide. This process had a race condition, and took time that increased with the number of identifiers in use.

When talking about this system with a developer on another team, they told me about another identifier generation scheme that also had problems. So it appears that a bit of design work goes a long way.

I think this case study is a great example of the value of learning computer science. It's common to read opinions that learning computer science is worthless. ([For example][cs-worthless]; there are plenty more.) There is nothing here that isn't covered in a good CS curriculum&mdash;basic probability and combinatorics, and binary representations and bit manipulation&mdash;and yet it seems in practice these skills are not common.

[uuid]: https://en.wikipedia.org/wiki/Universally_unique_identifier
[birthday-paradox]: https://en.wikipedia.org/wiki/Birthday_problem
[alpha]: https://www.wolframalpha.com/input?i2d=true&i=1+-+Power%5Be%2C-+Divide%5B10000000+*+%5C%2840%2910000000+-+1%5C%2841%29%2C2+*+Power%5B20%2C31%5D%5D%5D
[bit-masking]: https://en.wikipedia.org/wiki/Mask_(computing)
[twos-complement]: https://en.wikipedia.org/wiki/Two%27s_complement
[binary-literal]: https://docs.scala-lang.org/scala3/reference/other-new-features/binary-literals.html
[scalacheck]: https://scalacheck.org/
[cs-worthless]: https://www.reddit.com/r/csMajors/comments/nwpk78/cs_degrees_are_a_waste_of_time/
