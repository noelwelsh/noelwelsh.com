# Tagless Final for Humans

Tagless final can be either an amazing tool that allows for incredibly expressive code, or a colossal pain in the butt. So how do we make it more the former and less the latter? In this talk I'll describe when tagless final is appropriate, and Scala programming techniques that can make the notational overhead disappear.

Tagless Final is a common in the Scala world, but does it really justify the resulting code complexity? I've spent a decade writing a library using tagless final, so I can't claim I don't like the technique. At the same time I've worked on many codes bases where I felt it added a lot of complexity for little value.

In this talk I'll look at the different uses to which tagless final is put to, and see what we can learn about when it is useful and when it just gets in the way. Then, when we decide it is useful, I'll show how we can use subtyping, extension methods, and path-dependent types to allow the end user to write tagless final code that feels a natural as writing code without it, and won't have people shouting "What the F[_]?!" 



# Routing Http Requests with Scala 3

HTTP request routing libraries---code that chooses which function to execute based on an HTTP request---are an interesting case study in software design. I'll this talk I'll discuss the design of such a library, showing the tradeoffs made in service of different goals, and how Scala 3 language features can be leveraged for better designs.

Request routing is the problem of choosing a function to invoke based on a HTTP request. All but the simplest web frameworks include routing, but that doesn't mean that routing isn't an interesting problem. I set out to design a request routing library that was all of:

- compositional;
- type safe;
- reversible, meaning clients can be constructed from a route; and
- a delight to use, with great error messages.

Doing requires some interesting design decisions. We'll discuss FP versus OO representations,
finite state machine builders (which are a lot simpler than this name implies!), using Scala 3's tuple types for greater type safety and convenience, and designing for dot-driven development. Along the way I'll discuss other routing libraries that made different decisions, to help illustrate the design space and the tradeoffs that can be made.

Did I succeed? Well, you can decide. Either way, I think the journey is interesting and you should learn something you can apply to your own coding.
