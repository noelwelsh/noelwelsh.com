+++
title = "Scala with Cats, Creative Scala, and Scala 3"
+++

I'm rewriting my books to include new material and target Scala 3. I'm opening [sponsors][sponsor] so you can encourage me to finish faster.

<!-- more -->

## The Books

I have written three books on Scala:

1. [Creative Scala](https://creativescala.org/creative-scala), which is aimed at people completely new to programming;
2. [Essential Scala](https://underscore.io/books/essential-scala/), which is aimed at professional developers who are new to Scala; and
3. [Scala with Cats](https://www.scalawithcats.com/), which is about building systems using Cats.

The plan is to end up with two *vastly better* books using Scala 3. 
For now I'm using "Creative Scala" and "Scala with Cats" as the names for these books, but that might change as the books near completion.

As before, my books will focus on core concepts that apply well beyond Scala and steer clear of language minutae.

Here's a summary of what I'm planning to put into each book, and the rationale behind my choices.


### Creative Scala


The next version of Creative Scala will amalgamate and improve on the material in both Creative Scala and Essential Scala. So what's wrong with the existing books? The biggest problem with the current version of Creative Scala is that it's unfinished. Anyone who has read the book knows it falls apart towards the end. There are also issues with the presentation in some sections. Essential Scala is reasonably solid in the material it covers, but lacks good case studies that show the concepts in context. Finally, both books need to be updated to Scala 3.

Amalgamating the two books means they have to serve two different audiences: the would be programmer without a STEM background that Creative Scala has targeted, and the programmer without Scala or FP knowledge that Essential Scala addresses. I hope I can meet the needs of both by focusing on the first. So let me talk a bit about what I see as the needs of the non-STEM would be programmer, and then why I think existing programmers will still benefit from this new book.

My working hypothesis is that would be programmers would already be programmers if they liked building shopping carts or solving maths problems. That's why Creative Scala will first focus on making things that are beautiful and investigating social issues, to provide content that is motivating to non-programmers, before tackling more traditional topics. The material most relevant to existing programmers will be in these later parts, so this audience will only need to quickly skim the introductory material. 

More concretely, the book will consist of four parts. Each part will culminate in a larger project.

The first part will cover installation and tool use, a basic "notional machine" (the substitution model of evaluation), and some core programming techniques. The examples in this part all focus on two-dimensional graphics. This part of the book is mostly complete; [this chapter](http://www.creativescala.org/creative-scala/polygons/index.html) is a good example of the material.

The second part will look at defining basic data types and manipulating collections of data. I intend to use data sets that address broad social issues, such as child mortality and income inequality, to make the material relatable to a wide audience. 

The third part marks the shift to more traditional material. Here the focus will be on web development as a vehicle to work more with data types, see friends like `map` and `flatMap` in a different context, start to talk about state, and introduce type classes.

The fourth and final part will implement a simple language, a classic case study dating back at least as far as [SICP][sicp]. The intention is to show readers that programming languages are not magic, and to reinforce the programming language theory concepts that I'm sneaking into the rest of the book. 

Finally, Creative Scala will be a web first book. I am using animations, and will use other interactive elements in the future, that printed formats like PDF do not support.


### Scala with Cats

Scala with Cats is aimed at experienced Scala developers who want to take the next step to building really usable libraries and other infrastructure in Scala.

There are a few problems with the current version:

- An exclusive focus on core type class abstractions (monoid, monad, and friends) and their usage via Cats. Although I think this material is important, my experience building software over the years with Scala has taught me that type classes are only a small part of the puzzle. 

- The existing case studies kinda suck. They just don't have enough interesting detail.

- Scala 3 has happened, which changes a lot of language features used in the book.

The next version of Scala with Cats will be in organized into three parts. 
The first part will cover the interpreter pattern and it's various implementation techniques in Scala. This is, in my opinion, the most important topic in all of functional programming so it deserves to be in the book.
The second part will retain the existing material on type classes, improved and updated for Scala 3 and recent changes to Cats.
It will all be wrapped up in some chunky case studies, an example of which is [this parser combinator case study](https://www.creativescala.org/case-study-parser/).

Scala with Cats will remain a print first book, meaning the PDF output will be the primary target.


## Video

The kids these days do like them some video. I think video is a pretty bad medium for learning in general, but there are some cases where it is really shines. Demonstrating tool use and development process is one example. As such, I have a vague plan to make some videos once the text is complete. Now get off my lawn.


## Cool Story, Bro

Talk is cheap. When is it going to be ready?

New material for Creative Scala is [already online](https://creativescala.org/creative-scala), though there is a lot of mess to clean up. For the last few months I've been working solely on Creative Scala. I'm now decreasing my time on Creative Scala and starting work on Scala with Cats.


## Fat Stacks

I've setup [Github sponsors][sponsor] to attempt to collect some money for these efforts. Writing books takes a lot of time, which could be spent on client work. If these books are valuable to you, please consider sponsoring.


[sicp]: https://mitp-content-server.mit.edu/books/content/sectbyfn/books_pres_0/6515/sicp.zip/index.html
[sponsor]: https://github.com/sponsors/creativescala
