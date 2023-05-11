#+++
title = "An Update on my Books"
draft = true
+++

<!-- more -->

# The Books

I have written three books:

1. [Creative Scala](https://creativescala.org/creative-scala), which is aimed at people completely new to programming;
2. [Essential Scala](https://underscore.io/books/essential-scala/), which is aimed at professional developers who are new to Scala; and
3. [Scala with Cats](https://www.scalawithcats.com/), which is about building systems using Cats.

The plan is to end up with two vastly better books using Scala 3. 
For now I'm using "Creative Scala" and "Scala with Cats" as the names for these books, but that might change as the books near completion.
Here's a summary of what I'm planning to put into each, and the rationale behind the choices.

Core, reusable concepts, not language minutae. You can do a lot of dumb shit in Scala, but I've never understood why people want to do that.


## Creative Scala

Before writing a book it's good to be clear on why that book should exist. In the next version of Creative Scala I want to amalgamate and improve on the existing material in both Creative Scala and Essential Scala. The biggest problem with version one of Creative Scala is that it's unfinished. Anyone who has read the book knows it falls apart towards the end. There are also issues with the presentation in some sections. Essential Scala is reasonably solid in the material it covers, but lacks any good case studies that show the concepts in context. Finally, both books need to be updated to Scala 3.

Amalgamating the two books means they have to serve two different audiences: the would be programmer without a STEM background that Creative Scala has targetted; and the programmer without Scala or FP knowledge that Essential Scala has targetted. I hope I can meet the needs of both by focusing on the first. So let me talk a bit about what I see as the needs of the non-STEM would be programmer, and then why I think existing programmers will still benefit from this material.

Problems with current versions.

Aimed at students who aren't traditional CS students. Examples that have social relevance, not heavily mathematical.

Also programmers; hope they'll enjoy these examples. Need less motivation.

Goal to teach programming model and functional patterns. Programming can be systematic and repeatable.

The plan has the book consisting of four parts, with each part culminating in a reasonably sized project.

The first part contains introductory material aimed at those with no programming experience. This covers installation, tool use, a basic model of computing (the substitution model of evaluation), structural recursion over the natural numbers, and function composition. The examples in this part all focus on so-called creative computing, which in our case means two-dimensional graphics. Accessibility, diversity. This part of the book is mostly complete. [This chapter](http://www.creativescala.org/creative-scala/polygons/index.html) is a good example of the material.

The second part will look at defining basic data types, and manipulating collections of data, through the lens of data science.

Third part web development. 

Fourth part language implementation.

Web first


## Scala with Cats

Scala with Cats is aimed at experienced Scala developers who want to take the next step to building really usable libraries and other infrastructure in Scala.

The plan for the next version is to address the issues I've seen in the current version:

- The current version focuses on core type class abstractions (monoid, monad, and friends) and their usage via Cats. Although I think this is important, my experience building software over the years with Scala has taught me that type classes are only a small part of the puzzle. 

- The existing case studies kinda suck. They just don't have enough interesting detail.

- Scala 3 has happened.

The next version of Scala with Cats will be in roughly two parts. The first part will cover the interpreter pattern and it's various implementation techniques in Scala. This is, in my opinion, the most important topic in all of functional programming. If you understand this you'll understand how to build libraries that developers love to use, how to integrate functional and object-oriented programming, and, frankly, almost everything that is important in Scala.

The second part will retain the existing material on type classes, updated for Scala 3 and Cats 2.

Parser combinator case study.


# Video


# Cool Story, Bro

Anyone can write grand plans; talk is cheap. When are you going to be able to read new material? 

New material for Creative Scala is [already online](https://creativescala.org/creative-scala), though some of it is a bit of a mess. For the last few months I've been working on Creative Scala. 


# Fat Stacks
