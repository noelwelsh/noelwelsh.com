+++
title = "Programming Strategies: the Meta-game of Programming"
+++

This is a book on functional programming, seen through a Scala lens. If you understand a lot of the mechanics of Scala, but feel there is something missing in your undrestanding of how to use the language effectively then this book might be for you. It covers the usual functional programming abstractions like monads and monoids, but more than that it tries to teach you how to think and program like a functional programmer. It's a book as much about process as it is about the code that results from process, and in particular it focuses on what I can metacognitive programming strategies.

I would guess most programmers would struggle to describe the process they use to write code. I expect some might mention "test driven development" and perhaps "pair programming", but I wouldn't expect much more from the general programming population. Both the above techniques come from eXtreme Programming, which dates to the late 90s, and you would hope our field had added new knowledge in that time. But it's not really the fault of the developers---most of them haven't been taught any explicit process. For all that talk of process in industry, and all the effort spent on programming education in more recent times, the actual programming---the bit that produces the code that is the whole point of the endeavour---is still largely treated as magic. It doesn't have to be that way.

Functional programmers love fancy words for simple ideas, so it's no surprise I'm drawn to metacognitive programming strategies. Let's unpack that phrase to see what it means. Metacognition means thinking about thinking. A lot of research has shown the benefits of metacognition in learning, and that it is an important part of developing expertise. Metacognition is not just one thing---it's not sufficient to just tell someone to think about their thinking. Rather we should expect metacognition to be a collection of different strategies, some of which are general and some of which are domain specific. From this we get the idea of metacognitive programming strategies---explicitly naming and describing different strategies that proficient programmers use. 

I believe metacognitive programming strategies are useful for both beginners and experts. For beginners we can make programming a more systematic and repeatable process. Producing code no longer requires magic, but rather in the majority of cases the application of some well defined steps. For experts, the benefit is exactly the same. At least that is my experience (and I believe I've been programming long enough to call myself an expert.) By having an explicit process I can run it exactly the same way every day, which makes my code simpler to write and read, and saves my brain cycles for more important problems. In some ways this is an attempt to bring to programming the benefit that process and standardization has brought to manufacturing, particularly the "Toyota Way". In Toyota's process individuals are expected to think about how their work is done and how it can be improved. This is, in effect, metacognition for assembly lines. This is only possible if the actual work itself does not require their full attention. The dramatic improvements in productivity and quality in car manufacturing that Toyota pioneered speak to the effectiveness of this approach. Software development is more varied than car manufacturing but we should still expect some benefit, particularly given the primitive state of our current industry.

The question then becomes: what metacognitive strategies can programmers use? I believe that functional programming (FP) is particularly well suited to answer this question. A major theme in functional programming research is finding and naming useful code structures. This is useful as once we have discovered a useful abstraction we can get the programmer to ask themselves "would this abstraction solve this problem?" This is essentially what the design patterns community did, also back in the nineties, but their is an important difference. The academic FP community strongly values formal models, which means that the building blocks of FP have a precision that design patterns lack. However there is more to process than categorizing the output. There is also the actual process of how the code comes to be. Code doesn't usually spring fully formed from our keyboard, and in the iterative refinement of code we also find structure. Here the academic FP community has less to say, but is a strong folklore of techniques such as "type driven development"

Over the last ten or so years of programming and teaching programming I've collected a wide range of strategies. Some come from others (for example, [How to Design Programs](http://htdp.org/) remains very influential for me) and some I've found myself. Ultimately I don't think I've anything here is new; rather my contribution is in collecting and presenting these strategies as one coherent whole.

It is, I promise you, a simple idea: there is structure to how we think about programming, and we can find and study that structure. This is a good thing. 

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
