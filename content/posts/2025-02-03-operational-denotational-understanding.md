+++
title = "Operational and Denotational Strategies for Understanding Code"
draft = true
+++

When understanding programming language features, and explaining them to others, I've found it useful to have two different kinds of explanations[^terminology].
The first kind, which I call an *operational explanation*, explains a feature in terms of how the program executes.
The second kind, which I call a *denotational explanation*, explains features in terms of what they mean to the programmer.
For myself, and those I teach, it's usually easier to start with an operational explanation. However, with experience people tend to transition to more abstract denotational explanations.

Let's start with an example: the humble function. As a thought experiment, think about how you would explain what 

When explaining to a beginner how a function works I'd walk them through the process of evaluating the arguments, substituting those values into the body of the function, and then replacing the function call with the result the body evaluates to.
For a more involved example 

Both explanations are fundamentally the same, because they are explanations of the same thing. 
However they have a different quality.
The operational explanation operates at a low level. It tells us what to do, step-by-step, to get the same result as the computer.
The denotational explanation operates at a higher level. It tells us what a function is.


[^terminology]: The terms "operational" and "denotational" come from [denotational semantics][denotational-semantics] and [operational semantics][operational-semantics] respectively, which are two different ways that the semantics of a programming language can be formally specified. The essence of what I'm doing here is translating these concepts to a more informal approach geared towards the working programmer. It's perhaps not surprising that these concepts are useful for informally explaining programming language semantics, but I do think it's interesting.

[denotational-semantics]: https://en.wikipedia.org/wiki/Denotational_semantics
[operational-semantics]: https://en.wikipedia.org/wiki/Operational_semantics
[function-substitution]: https://www.creativescala.org/creative-scala/methods/semantics.html
