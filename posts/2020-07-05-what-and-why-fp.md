---
title: What Functional Programming Is, What it Isn't, and Why it Matters
---

The programming world is moving towards functional programming (FP). More developers are using languages with an explicit bias towards FP, such as Scala and Haskell, and we're also seeing object-oriented (OO) languages and their communities adopt FP features and practices. A striking example of the latter is the rise of Typescript and React in the Javascript community. So what is FP and what does it mean to write code in a functional style? It's common to view functional programming in terms of language features, such as first class functions, or to define it as a programming style using immutable data and pure functions (function which always return the same output from the same input). This was my view when I first started down the FP route, but I now think differently. I now believe the true goals of FP are enabling local reasoning and compositional software and other features are in service of this goal. In this post I attempt to explain what these goals are, and why they are valuable.

<!--more-->

## What Functional Programming Is

My beliefs about functional programming can be summarized as: functional programming is a hypothesis that programs that enable local reasoning and composition will be easier to create and maintain. This naturally raises the question: what are local reasoning and composition? Let's address each in turn.

Local reasoning means we can understand pieces of code in isolation. When we see the expression `1 + 1` we know what it means regardless of the weather, the database, or the current status of our Kubernetes cluster. None of these external events can change it. This is a trivial and slightly silly example, but it illustrates a point. A goal of functional programming is to extend this ability across our code base. 

Writing code that allows local reasoning means not using techinques that may be common in other settings. For example, shared mutable state is out because relying on shared state means that other code can change what our code does. It means not using global mutable configuration, as found in many graphics libraries, as any random code can change that configuration. Adapting code to enable local reasoning can mean quite a sweeping change, but if we work in a language that embraces functional programming this style of programming is the default.

We care about local reasoning because when our code base enables local reasoning allows our ability to understand that code scales with the size of the code base. We can understand module A and module B in isolation, and our understanding does not change when we bring them together in the same program. This is because if both A and B allow local reasoning there is no way that B (or any other code) can change our understanding of A, and vice versa. If we don't have local reasoning every new line of code can force us to revisit the rest of the code base to understand what has changed. This means it becomes exponentially harder to understand code as it grows in size as the number of interactions (and hence possible behaviours) grows exponentially. We can say that local reasoning allows compositional reasoning, and this gets us to the next point.

Composition means we can build complex things out of smaller things. Numbers are compositional. We can take any number and add one, giving us a new number. Lego is also compositional. We compose Lego by sticking it together. In the particular sense we're using composition we also mean that the original elements we compose don't change in any way when they are composed. This is how local reasoning is compositional. Our understanding of modules A calling module B is just our understanding of A, our understanding of B, and whatever calls A makes to B.

Both numbers and Lego have an interesting property in common: the operations that we can use to combine them (for example, addition, substraction, and so on for numbers; for Lego the operation is "sticking bricks together") give us back the same kind of thing. A number multiplied by a number is a number. Two bits of Lego stuck together is still Lego. This property is called closure: when you combine things you end up with the same kind of thing. Closure means you can apply the combining operations (sometimes called combinators) an arbitrary number of times. No matter how many times you add one to a number you still have a number and can still add or subtract or multiply or...you get the idea.

Closure makes efficient use of knowledge. If we understand module A, and the combinators that A provides are closed, we can build very complex structures using A without having to learn new concepts! This is also one reason functional programmers tend to like abstractions such a monads (beyond liking fancy words): they allow us to use one mental model in lots of different contexts.

Types are not strictly part of functional programming but statically typed FP is the most popular form of FP, and I think is sufficiently important to warrant a mention. Types express properties of programs, and the type checker automatically ensures that these properties hold. But types are not just for the compiler. Types act as an aid to understanding code. They can tell us, for example, what a function accepts and what it returns, that is a value is optional, or that an error might have occured. In this sense types are another tool for local reasoning.

Modern type systems support a style of programming that, in my experience, is impossible without a type checker. It also pushes programs towards particular designs, as to work effectively with the type checker requires designing code in a way the type checker can understand. As variants of these type systems come to other languages they naturally tend to shift programmers in those languages towards a FP style of coding.


## What Functional Programming Isn't

In my view functional programming is not about immutability, or keeping to "the substitution model of evaluation". These are only tools in service of the goals of enabling local reasoning and composition, but they are not the goals themselves. Code that is immutable always allows local reasoning, for example, but it is not necessary to avoid mutation to still have local reasoning. Here is an example of summing a collection of numbers. First we have the code in Typescript:

```javascript
function sum(numbers: Array<number>): number {
    let total = 0.0;
    numbers.forEach(x => total = total + x);
    return total;
}
```

Here's the same function in Scala:

```scala
def sum(numbers: List[Int]): Int = {
  var total = 0.0
  numbers.foreach(x => total = total + x)
  total
}
```

In both implementations we mutate `total`. This is ok though! We cannot tell from the outside that this is done, and therefore all users of `sum` can still use local reasoning. Inside `sum` we have to be careful when we reason about `total` but this block of code is small enough that it shouldn't cause any problems.

In this case we can reason about our code despite the mutation, but neither the Typescript nor the Scala compiler can determine that this is ok. Both languages allow mutation but it's up to us to not use it inappropriately. A more expressive type system, perhaps with features like Rust's, would be able to tell that `sum` and other more complex examples don't allow mutation to be observed by other parts of the system[^linear]. Another approach, which is the one taken by Haskell, is to disallow all mutation and thus guarantee it cannot cause problems.

In my opinion immutability has become associated with functional programming because immutability guarantees local reasoning and composition, and until recently we didn't have the language tools to automatically distinguish safe uses of mutation from those that would cause problems. Restricting ourselves to immutability is the easiest way to ensure the desirable properties of functional programming, but as languages evolve this might come to be regarded as a historical artifact.


## The Power of Reasoning

Reasoning is extremely powerful. When we reason about code we can prove statements about our code without running it. For example, we can say "this code always evaluates to 2", or perhaps more usefully something like "this code will never fail", and we can be certain this is always true within the limits of the logical model we use to reason. (We'll talk more about limits in the next section.) This is not something unique to programming; it's just an application of logic. It's what allows mathematicians to prove that the angles inside a triangle always add up 180 degrees, for example. 

We can reason in a formal way. This is what the type checker does, and it has the advantages of doing it every time code changes and (hopefully!) being more accurate than a human. Most of us also reason informally about programs. For example, when trying to optimize code I may use an informal model of execution time to come up with possible optimizations. My informal model is definitely not completely accurate, and might even be inconsistent in places, but it works well enough for my uses.

Another way we can understand programs is by running them and seeing what happens. This is useful, but it only tells us what happens in that particular instance. If a program works now, with some particular choice of input, does that mean it will continue to work with different input? We can't say with certainity, but we can build more confidence by looking at more cases.


## Limits of Reasoning

There are theoretical and practical limits to the power of reasoning.

[The halting problem][halting] demonstrates fundamental limits to the power of reasoning. There are some properties that we simply cannot prove for all programs. (The [incompleteness theorems][incompleteness] express the same idea from a mathematical perspective.) However this is not usually what causes problems in practice. In my (admittedly limited) experience, for the working programmer the limits more often come from the cost involved in formalizing statements of interest, reasoning across system boundaries, and issues with assumptions built into models. Let's address each of these in turn.

The first issue is perhaps the most important: proving properties programs is often just too expensive. Type systems are the most accessible form of formal reasoning in programming, but their expressivity is limited to fairly simple (though still very useful!) statements about programs. Some type systems allow complex statements to be formalized but it usually becomes very hard to do this. There are other tools for formal reasoning, such as [TLA][tla] and [Agda][adga]. To use these tools requires expertise that most programmers do not have.

System boundaries also limit what we can reason about. We can only formally reason up to the boundaries of our system. When we interact with the outside world all bets are off. I imagine many developers have had the experience of interacting with a web service that doesn't adhere to its own specification. It doesn't matter what the documentation says, and it doesn't matter how we represent remote systems with types in our code; if the real world is different we must adapt. The only way we can reliably determine a remote system's behavior is by interacting with it and seeing what happens.

Finally, all formal models are built on assumptions. For example, when we say that the program `1 + 1` always evaluates to `2` we are making assumptions such as: arithmetic won't overflow, we aren't going to run into [CPU bugs][fdiv], and we don't have to worry about [cosmic rays][cosmic-rays]. Usually this is fine, but there are occasions where it is not. It is up to us to decide when our assumptions should be challenged.

The upshot is that we have to use a combination of techniques. Sometimes we can reason formally, and that is very powerful. Sometimes we reason informally, and sometimes we just have to see what actually happens when our code runs. Given how powerful formal reasoning is, we should aim to extend its reach wherever it is feasible to do so. However we should also recognize when it is too difficult or not appropriate to use formal reasoning and then rely on other methods.


## Implications

There are two impliciations of functional programming's focus on reasoning that I want to briefly discuss.

Firstly, FP values static understanding of code---that is, understanding code before it runs---over dynamic understanding and this has many effects on the culture of FP. Much more effort is given to, say, type systems (which improve static understanding) than debuggers (which improve dynamic understanding). People working on FP are more likely to come from a maths or logic background then say design or human factors. This is reflected in wonderful compilers that emit cryptic error messages, and, unfortunately, sometimes less regard given to community issues than is ideal. It does seem that the FP communities I know of are becoming more aware of these issues.

The other implication is that FP is more valuable in the large. For a small system it is possible to keep all the details in our head. It's when a program becomes too large for anyone to understand all of it that local reasoning really shows its value. This is not to say that FP should not be used for small projects, but rather that if you are, say, switching from an imperative style of programming you shouldn't expect to see the benefit when working on toy projects.


## The Evidence for Functional Programming

I've made arguments in favour of functional programming and I admit I am biased---I do believe it is a better way to develop code than imperative programming. However, is there any evidence to back up my claim? There has not been much research on the effectiveness of functional programming, but there has been a reasonable amount done on static typing. I feel static typing, particularly using modern type systems, serves as a good proxy for functional programming so let's look at the evidence there.

In the corners of the Internet I frequent the common refrain is that [static typing has neglible effect on productivity][empirical-pl-luu]. I decided to look into this and was surprised that the majority of the results I found support the claim that static typing increases productivity. For example, the literature review in [this dissertation][merlin] (section 2.3, p16--19) shows a majority of results in favour of static typing, in particular the most recent studies. However the majority of these studies are very small and use relatively inexperienced developers---which is noted in the review by Dan Luu that I linked. My belief is that functional programming comes into its own on larger systems. Furthermore, programming languages, like all tools, require proficiency to use effectively. I'm not convinced very junior developers have sufficient skill to demonstrate a significant difference between languages.

To me the most useful evidence of the effectiveness of functional programming is that industry is adopting functional programming en masse. Consider, say, the widespread and growing adoption of Typescript and React. If we are to argue that FP as embodied by Typescript or React has no value we are also arguing that the thousands of Javascript developers who have switched to using them are deluded. At some point this argument becomes untenable.

This doesn't mean we'll all be using Haskell in five years. More likely we'll see something like the shift to object-oriented programming of the nineties: Smalltalk was the paradigmatic example of OO, but it was more familiar languages like C++ and Java that brought OO to the mainstream. In the case of FP this problems means languages like Scala, Swift, and Kotlin, and mainstream languages like Javascript and Java continuing to adopt more FP features.


## Final Words

I've given my opinion on functional programming---that the real goals are local reasoning and composition, and programming practices like immutability are in service of these. Other people may disagree with this definition, and that's ok. Words are defined by the community that uses them, and meanings change over time. 

Finally, I want to briefly discuss the value of precision in FP. FP is based on a number of formal models (for example, the lambda calculus), which allow formal reasoning about properties of programs. What is remarkable to me is that these same models allows systematic construction of code. For example, if we start with a description of data we can derive from this description both the implementation of that data and the implementation of generic transformations on that data. This makes programming much easier and makes the code much more consistent than in my experience with OO. In a future article I'll talk about this.


[incompleteness]: https://en.wikipedia.org/wiki/G%C3%B6del%27s_incompleteness_theorems
[halting]: https://en.wikipedia.org/wiki/Halting_problem
[tla]: https://en.wikipedia.org/wiki/TLA%2B
[cosmic-rays]: https://en.wikipedia.org/wiki/Soft_error#Cosmic_rays_creating_energetic_neutrons_and_protons
[fdiv]: https://en.wikipedia.org/wiki/Pentium_FDIV_bug
[escape]: https://en.wikipedia.org/wiki/Escape_analysis
[substructural]: https://en.wikipedia.org/wiki/Substructural_type_system
[empirical-pl-luu]: https://danluu.com/empirical-pl/
[merlin]: https://web.cs.unlv.edu/stefika/documents/MerlinDissertation.pdf
[maintainability]: https://www.researchgate.net/publication/259634489_An_empirical_study_on_the_impact_of_static_typing_on_software_maintainability
[enforce]: https://ieeexplore.ieee.org/document/7503719
[code-completion]: https://dl.acm.org/doi/abs/10.1145/2936313.2816720
[sorbet]: https://sorbet.org/

[^linear]: The example I gave is fairly simple. A compiler that used [escape analysis][escape] could recognize that no reference to `total` is possible outside `sum` and hence `sum` is pure (or referentially transparent). Escape analysis is a well studied technique. In the general case the problem is a lot harder. We'd often like to know that a value is only referenced once at various points in our program, and hence we can mutate that value without changes being observable in other parts of the program. This might be used, for example, to pass an accumulator through various processing stages. To do this requires a programming language with what is called a [substructural type system][substructural]. Rust has such a system, with affine types. Linear types are in development for Haskell.
