+++
title = "Strategies to go Beyond Design Patterns"
draft = true
+++

Design patterns are [originally defined as][dp]

> A design pattern consists of three essential parts:
>
> 1. An abstract description of a class or object collaboration and its structure. The description is abstract because it concerns abstract design, not a particular design.
> 2. The issue in system design addressed by the abstract structure. This determines the circumstances in which the design pattern is applicable.
> 3. The consequences of applying the abstract structure to a system's architecture. These determine if the pattern should be applied in view of other design constraints.

This definition explicitly couples design patterns to object-oriented programming, but we can regard that as an artifact of the milieu in which they were created and not an essential part of the definition. However the definition is clear that design patterns live above the code but still reference code level concepts. The definition also views design patterns as *static* artifacts. They (abstractly) discuss code but not the process of creating that code. These restrictions leave several shortcomings:

1. The interaction between language and design does not only go one way. Language feeds back into design, as the expressivity of a language directly determines what it can and cannot easily express and hence what is considered good design. In fact it is a common (though banal, in my opinion) criticism of design patterns that they catalogue limitations of typical object-oriented languages, and the pattern can be directly expressed in other languages. This misses the point that, even if a language directly expresses some concept the programmer still must realize that the language features can used in that way. I've worked with too many systems with large numbers of boolean flags, implemented in a language that supports algebraic data, to believe that the mere presence of a language feature will lead to it being used effectively.

2. Programming is a process, and there is structure in that process just like there is structure in the code that results from the process. Programmers in languages with modern type systems are used to "following the types", and students of functional programming will know that structural recursion and structural corecursion can be used to solve a large variety of problems. However these tools for writing coding are rarely explicitly discussed from the programmer's rather than theoretician's point of the view. In commercial software engineering there is similarly little discussion of the actual process of writing code, with the emphasis being on the processes around code, such as daily stand-ups and burn-down charts.

3. There are concepts that inform design but do not directly relate to code. Take, for example, composition. This is a driving principle behind functional programming, but it must always be mediated through other concepts. When choosing to make a system compositional we might decide to use another concept, a combinator library, to implement it. We then have at least two implementation pathways available: implementing it as data (otherwise known as a free structure, reification, or defunctionalization) or as codata (otherwise known as a Church encoding, or refunctionalization). So we see that composition by itself does not directly lead to code. It sits as a guiding principle that leads to other concepts that then lead to code.

As these examples illustrate, there is structure to design and implementation that extends above, into a purely conceptual level, and below, into pure code, what is considered a design pattern. It is useful to name and describe the elements of this structure, for the same reason it is useful to name and describe design patterns. Currently these elements are considered in separate fields. For example, structural recursion is generally talked about in programming language theory. This discussion focuses on formal models that are largely inaccessible to the working programmer. While it's important for theoretical work to advance using the tools of theory it is also important to bring this work into practice, which requires a discussion that is accessible to those in industry.

We have identified many elements of design that fall outside the scope of design patterns. We could extend the definition of design patterns to encompass these additional concepts, but design patterns are a well established field and changing the meaning would create confusion. Instead, I propse the name *strategies*, or *metacognitive programming strategies* if one needs extra formality, to cover this broader structure of design and implementation. This connects the work to other work in metacognitive strategies in psychology **more here**


## Structure of Strategies

All models are lies but some are useful.

Three level structure

Let's see a small example that illustrates this. Regular expressions. Composition. Combinator library. Reify. Structural recurison. Follow the types.



[dp]: https://courses.cs.duke.edu/cps108/spring02/readings/patterns-orig.pdf
