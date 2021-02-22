---
title: Scala with Cats 2
---

[Scala with Cats 2][scalawithcats] is underway, with a fancy new website. Go and join the mailing list linked from the [site][scalawithcats] if you want to keep up with the latest developments.

<!-- more -->

Dave and I fairly regularly get emails about Scala with Cats (if you have ever emailed us---thanks, it's great to hear from readers!) Two questions come up time and again: "when will the book be updated to Cats 2?", and "when will printed versions be available?" We're happy to say the answer to both is: soon! We have started working on updating the book. In fact the current version of the book, which is linked from the web site, is built against Cats 2 (although it does not discuss new concepts like the `Parallel` type class). [This issue][170] tracks our progress on the update.

Our goals for the update are fairly modest, or, as I like to call them, achievable. We are definitely going to include discussion of `Parallel`, which is one of the main new additions in Cats 2 that completely changes how, for example, error handling is done. We might include some discussion of [Cats Effects][cats-effect]. I think Cats Effect is a very important library, but it's also a big library so I'm not sure we'll have time to write up exhaustive coverage. There will also be many small changes but the previous two points are the big changes we have planned.

Once again, if you're interested in following our progress please sign up to the mailing list linked from the [Scala with Cats site][scalawithcats]. 

[scalawithcats]: https://scalawithcats.com/
[170]: https://github.com/scalawithcats/scala-with-cats/issues/170
[cats-effect]: https://typelevel.org/cats-effect/
