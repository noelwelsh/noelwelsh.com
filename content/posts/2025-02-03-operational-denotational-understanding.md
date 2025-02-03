+++
title = "Operational and Denotational Strategies for Understanding Code"
+++

When understanding programming language features, and explaining them to others, I've found it useful to have two different kinds of explanations.
The first kind, which I call an *operational explanation*, explains a feature in terms of how the program executes.
The second kind, which I call a *denotational explanation*, explains features in terms of what they mean to the programmer[^terminology].
For myself, and those I teach, it's usually easier to start with an operational explanation. However, I find denotational explanations more useful in the long term.

<!-- more -->

Let's start with an example: the humble function. As a thought experiment, think about how you would explain functions to a new programmer.
I would probably say something like "a function allows us to reuse an expression in different contexts where parts of that expression can change"[^functions]. 
This is a very abstract definition, so I'd quickly follow up with an example and then walk through the process of evaluating functions: evaluating the parameters, substituting those values into the body of the function, and so on[^substitution]. The first explanation is a denotational one, whilst the second explanation is operational. 

Both explanations are fundamentally saying the same thing: a function allows us to generalize a set of related expressions by using function parameters to capture the parts that change. This is to be expected; they are explaining the same thing. 
However they have a different quality.
The operational explanation operates at a low level. It tells us what to do, step-by-step, to get the same result as the computer.
I find this type of explanation is easier for beginners to work with, as it gives them a process to follow.
However, operational explanations are cumbersome to work with in the long term.
We cannot laboriously perform substitution, for example, every time we encounter a function call.
This where denotational explanations are useful. 
They operate on a higher level, and so require fewer mental resources to work with.
With practice I find that people move from an operational to a denotational understanding of a concept.

Denotational and operational explanations are not only useful for basic concepts. Let's look at a more advanced example: type classes. When explaining type classes in Scala I start by describing how `given` values (implicit values in Scala 2) and `using` parameters (implicit parameters in Scala 2) work: if an `using` parameter is not explicitly provided the compiler will supply one if it can  find a `given` value of the correct type in the given scope. The details are fairly involved, so I refer you to [Functional Programming Strategies][fps] for the full explanation. Once this is understood, we can move on to the denotational explanation: a type class allows us to express constraints on a type parameter. That is a type parameter that is not just any type, but any type that also has an implementation of the required type class. Again, the denotational understanding is at a higher level. It's harder to understand when first encountering the concept, but once understood it makes reasoning about code easier than the operational understanding.

In summary, denotational explanations are higher level, more compact, and easier to reason with *once they are understood*. Understanding, however, is best scaffolded with operational explanations. I use these two types of explanations all the time when teaching or creating content, but also I find them useful when learning new concepts myself. Introspecting my own understanding to see if I have both an operational and denotational understanding helps me see where I need to fill in gaps. I hope you find it useful as well.

[^terminology]: The terms "denotational" and "operational" come from [denotational semantics][denotational-semantics] and [operational semantics][operational-semantics] respectively, which are two different ways of formally specifying the semantics of a programming language. The essence of what I'm doing is translating these concepts to a more informal approach for the working programmer. It's perhaps not surprising that these concepts are useful for informally explaining programming language semantics, but I do think it's interesting that they are.

[^functions]: It's surprisingly hard to come up with a concise and precise denotational definition of functions that is suitable for beginners. I looked at a few courses when writing this article and found a lot of imprecision. For example, [University of Washington's CSE160][uw] says a "[a] function packages up and names a computation", which leaves open what it means to package something up, and what a computation is. It then proceeds to an operational explanation. Princeton's [Introduction to Programming in Python][princeton] leads with an operational definition ("[a] function &hellip; allows us to transfer control back and forth between different pieces of code") and is rather imprecise with the denotational explanation that follows ("Functions are important because they allow us to clearly separate tasks within a program and because they provide a general mechanism that enables us to reuse code.") [DCIC][dcic] nails it, as you would expect. It starts with a denotational explanation that is grounded in an example ("Similar Flags") and then proceeds to an operational explanation ("How Functions Evaluate").


[^substitution]: A complete example of this substitution process is in [Creative Scala][function-substitution]. It's fairly involved so I've omitted the full details here.

[denotational-semantics]: https://en.wikipedia.org/wiki/Denotational_semantics
[operational-semantics]: https://en.wikipedia.org/wiki/Operational_semantics
[function-substitution]: https://www.creativescala.org/creative-scala/methods/semantics.html
[substitution]: https://www.creativescala.org/creative-scala/substitution/

[uw]: https://courses.cs.washington.edu/courses/cse160/21wi/lectures/04-functions-21wi.pdf
[princeton]: https://introcs.cs.princeton.edu/python/20functions/
[dcic]: https://dcic-world.org/2024-09-03/From_Repeated_Expressions_to_Functions.html

[fps]: https://scalawithcats.com/
