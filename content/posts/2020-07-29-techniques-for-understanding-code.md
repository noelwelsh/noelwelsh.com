+++
title = "Techniques for Understanding Code"
+++

Building an understanding of code is one of the main tasks in software development. Whenever we want to answer a question about code&mdash;what is this doing? why doesn't it work? how can we make it faster?&mdash;this is what we're doing. I have found it valuable to consciously surface the strategy I use to answer these questions, and have categorized my approaches into three groups:

1. reasoning about code;
2. inspecting running code; and
3. referring to an authoritative source.

In this post I will discuss these different ways of understanding code and their benefits and drawbacks.

<!-- more -->


## Three Ways to Understand Code

Let's start by describing the three methods for understanding code.

### Reasoning

Reasoning means applying logic to some model of a programming language's semantics. This sounds very formal, and that can be the case using say, an operational or denotational semantics. However most reasoning is informal. I'm sure the majority of programmers can reason about code (quick check: what does the program `1 + 1` evaluate to?) but would be hard pressed to specify the model and inference rules they use.

Reasoning takes place at many levels. For example, when I reason about code I might work at a low level that is easily reducible to a formal semantics. More often I work at a higher level, where I'm thinking about, say, transformations on algebraic data types instead of expressions and values.

Regardless of how it is done, reasoning requires a model and rules for inference.


### Observation

Another way we can understand code is by observing its behavior as it runs. There are many ways to do this. Just running the program and looking at its output is probably most common, but other methods include using a debugger, inspecting logs, or runnning tests.

### Appeal to Authority

A final way we can understand code is by turning to a trusted source. For most programmers this means the searching the Internet, perhaps using a site like Stack Overflow or a specialist forum or mailing list. It can also mean consulting a colleague or even, as a last resort, reading the fine manual.


## The Advantages of Reasoning

Of the three methods my preference is to use reasoning. Reasoning can make statements that hold for all possible program runs. Let's use the following code example to discuss this further. First the code is shown in Typescript.

```javascript
function shout(phrase: string): string {
    return `${phrase.toUpperCase()}!`
}
```

Now here it is using Scala.

```scala
def shout(phrase: String): String =
  s"${phrase.toUpperCase}!"
```

Finally an example of using it.

```scala
shout("Hello, reader")
// Returns HELLO, READER!
```

Here are some of the properties of this code:

- the string returned by `shout` will always end with an exclamation mark!
- the code cannot fail unless passed `null` (or `undefined` in the case of Typescript.)
- if the input is all in upper case the output will be one character longer.

There are other properties we could define but hopefully the above are sufficient to give you an idea of what I mean. We can tell these properties are true without running the code and they hold for all possible execution&mdash;an infinite number of cases.

Neither observation nor appealing to authority can prove statements about programs. Observation can only tell us about the properties of the program when run with the particular input it is given. If we see that the output of `shout("Hello, reader")` is `"HELLO, READER!"` then we might guess as to what `shout` is doing. More observations can increase our confidence. However we cannot ever be certain that we are correct by observation alone. Appealing to authority&mdash;perhaps by reading the documentation for the `shout` function&mdash;may describe what the function does but that description could be incorrect. The problem with trust is that it, well, relies on trust. Particularly when trusting randos on the Internet we must be cautious.

I find reasoning more efficient than other methods. If I have a good model of the domain I can reason my way out of most problems with just a little thinking. Observation requires I run a program, which usually takes more to setup, and consulting others requires I interrupt a colleague or trawl through hundreds of Internet search results.

Reasoning is also amenable to automation. The most accessible form of automated reasoning is probably type checking but linters and similar tools are other examples. Although there are systems that can construct tests they are not anywhere near as widely available as type systems. We might consider code reviews a kind of automated code review, but the feedback loop is much slower.


## The Limit of Reasoning

There are theoretical and practical limits to the power of reasoning.

[The halting problem][halting] demonstrates fundamental limits to the power of reasoning. There are some properties that we simply cannot prove for all programs. (The [incompleteness theorems][incompleteness] express the same idea from a mathematical perspective.) However this is not usually what causes problems in practice. In my (admittedly limited) experience, for the working programmer the limits more often come from the cost of reasoning, reasoning across system boundaries, and issues with assumptions built into models. Let's address each of these in turn.

The first issue is perhaps the most important: reasoning can be just too expensive. The cost is usually that of learning. Most reasoning we do is informal, and the cost here is in acquiring a reliable mental model. All of us have limits on what we have time to learn and must choose to specialise to an extent. When reasoning formally we may already have a model but even then most of us do not have expertise to use a formal model efficiently. Some systems are too complex to reasonably build a model for. Attempting to build a cycle accurate CPU model, for example, is likely to be wasted effort. It's much simpler to measure actual program performance.

System boundaries also limit our ability to reason. We can only formally reason up to the boundaries of our system; when we interact with the outside world all bets are off. I imagine many developers have had the experience of interacting with a web service that doesn't adhere to its own specification. It doesn't matter what the documentation says, and it doesn't matter how we represent remote systems with types in our code; if the real world is different we must adapt. The only way we can reliably determine a remote system's behavior is by interacting with it and seeing what happens.

Finally, all formal models are built on assumptions. For example, when we say that the program `1 + 1` always evaluates to `2` we are making assumptions such as: arithmetic won't overflow, we aren't going to run into [CPU bugs][fdiv], and we don't have to worry about [cosmic rays][cosmic-rays]. Usually this is fine, but there are occasions where it is not. It is up to us to decide when our assumptions should be challenged.


## Combining Reasoning, Observation, and Trust

I've presented reasoning, observation, and appeal to authority as alternatives but the truth is that they are complimentary. For example, we can take observations as a starting point for reasoning, and usually when debugging this is what we do. We can use reasoning to suggest optimizations that we then confirm with actual performance measurements. We implicitly rely on trust even in formal reasoning: trust that the model we work with is correct, the tools we are using are free from bugs, and those who taught us to reason did a good job. In my experience the skill is in realising which combination of techniques is appropriate in a given situation. Let me give two examples.

I don't fully understand the Scala [sbt] build tool. When I do have to work with sbt I know I'm going to have to rely on reading documentation and trial and error&mdash;which is to say appeal to authority and observation. If my goal is to work with a plugin I'll usually rely on that plugin's documentation. If I'm working with something core to sbt I'll go straight to the sbt documentation. I won't usually search the web as a first choice because I don't find it particularly reliable. One non-goal is developing a complete mental model of sbt. I don't mind if this happens but I don't have to modify my builds often enough that I think this worthwhile. Hence my reading is usually very task oriented&mdash;how do I do this?&mdash;versus understanding why things work the way they do.

In contrast I've recently been learning React and Typescript (hence the Typescript examples in recent posts.) Here my goal is to build a mental model. To this end I have read through most of the documentation with a focus on conceptual material. When I encounter a surprise when programming I actively try to inspect my mental model to see how it should be revised. This slows me down to start with but the time I spend learning is paid back every time I use the model I've learned.

Finally, I've noticed that some programmers have an over reliance on a particular technique for understanding, usually searching the web. I think it is important to build reliable mental models in our core skills, so if you are the type of person who jumps onto Google whenever you encounter a problem try instead to reason about it first, and then think how you need to adjust your mental model so you understand the cause of the error. I believe it will make you a better programmer in the long run.


[halting]: https://en.wikipedia.org/wiki/Halting_problem
[incompleteness]: https://en.wikipedia.org/wiki/G%C3%B6del%27s_incompleteness_theorems

[cosmic-rays]: https://en.wikipedia.org/wiki/Soft_error#Cosmic_rays_creating_energetic_neutrons_and_protons
[fdiv]: https://en.wikipedia.org/wiki/Pentium_FDIV_bug

[sbt]: https://www.scala-sbt.org/
