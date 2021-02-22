# Programming Strategies: the Meta-game of Programming

Programming can be a very structured activity, but is not always presented or practiced as such. 

When I was taught to program---and I hope things have changed since---we weren't taught to program at all. What we were taught was the semantics of the languages constructs of the chosen language. Absent was any process for choosing between these constructs to solve our programming problems. Programming seemed like a game of lucky dip: we had a "bag of syntax" and if we were lucky the language construct we pulled out actually helped us. Most often it didn't and there was no real way to tell what would and wouldn't help beyond trial and error. What we needed, and didn't have, was structure. In particular we needed a structured process to take us from problem to solution.

C was the first language I used at University. In C there is very little structure. A great example is the mess that is IO in C and Unix. Unix pretends everything is file, but not all "files" support the same operations. A socket, for example, doesn't support repositioning by `fseek` and friends. The IO functions are also wildly inconsistent in how they operate. For example, the [read] function returns -1 on success while [fclose] returns 0. The true structure of the program---say, what was a socket versus what was a file on disk---wasn't apparent in the program and every single function would just work in its own unique way.

Java added more structure. For example, there is a standard way to handle exceptions (exceptions). But still not much structure. Jini. ATG Dynamo.

Processes. XP. Unit testing.

Why do we care about structure? Structure makes things predictable and repeatable and optimizable. Life is short.

Lots of people look at process. Process is good.

Later, as a professional programmer working with Java, I had a similar experience. For example, one project used a very early release of [Jini][jini]. In Jini it was standard practice to use null as a meaningful value. So at any point a method could accept or return null, and you just had to be familiar with each method to understand if this indicated something had gone wrong or not.

As a new programmer I just accepted that software was arbitrary. Each function would work in its own arbitrary way

Structure in software and structure in process.

It's only relatively recently, as I've specialized in functional programming (FP) and gained experience teaching FP, that I've realized that the majority of programming can and should be performed with systematic and repeatable processes.

In this post I want to explain what I mean by systematic and repeatable processes for programming, which I call *programming strategies*, and convince you that they are powerful and useful.


## Programming Strategies

Progress is the imposition of structure.

I've defined a programming strategy as a systematic and repeatable process for solving some programming problem. Let's dig into this in some more depth. A programming strategy is an algorithm to solve some programming task. It should:

- be applied in the same way each time it is used, and hence be *systematic*; and
- produce the same result every time it is used, and hence be *repeatable*.

Programming consists of many tasks. Discussing architecture with colleagues, participating in code reviews, debugging code, and monitoring running code are examples of tasks that most programmers will regularly participate in. Producing code is what most think of as the primary task in programming, and what the strategies I discuss here address, but I don't want to give the idea that this is the only application of strategies. I give some references to other word later in this post.

If programming strategies are algorithms we might naturally think to express them in code. We can, but I find that a formal presentation is more hinderance than help. Our goal here is to produce code, and most languages don't have particularly good support for code generation so it would require a lot of infrastructure to write a programming strategy in this way. Instead of code we could use some kind of mathematical notation, which might be more compact but is generally less accessible. I'll use prose, with the understanding that I what I say can be formalized if we're prepared to but in the effort. Indeed, the strategies I'm considering have been formalized as all I'm doing, essentially, is restating results from the programming language theory literature in a more accessible form.


## Structural Recursion: An Example Strategy

Blah blah blah. Example here.

- Programming can be systematic
- Most of this stuff already exists
- This is useful. Meta cognition. Production lines.
- It's a two way street. You gotta design things to be systematic to allow systematic use 


Metacognitive strategies are extremely powerful. Programming, and functional programming in particular, is a subject ripe for metacognitive strategies but rarely presented that way. 


## Metacognition

Metacognition means thinking about thinking. That is, being aware of how we are approaching problems, understanding the range of problem-solving strategies that are available to us, and consciously choosing strategies to tackle a problem.

Metacognition has been extensively studies in the field of education, and is recognized as one of the most effective approaches to learning and problem solving. 

Evidence:

one of the three key findings of this work is the effectiveness of a “‘metacognitive’ approach to instruction
https://www.desu.edu/sites/flagship/files/document/16/how_people_learn_book.pdf


## Metacognitive Strategies in Programming

Like all other disciplines, programming is ripe with metacognitive strategies. However we don't pay much attention

Metacognitive strategies:

- design patterns; and
- 


## Related Work


[read]: https://linux.die.net/man/2/read
[fclose]: https://linux.die.net/man/3/fclose
[jini]: https://en.wikipedia.org/wiki/Jini
