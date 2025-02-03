+++
title = "Resumable Parser Combinators"
draft = true
+++
# Resumable Parsing

Like many languages, Scala allows *string interpolation*: a string literal can contain placeholders that indicate where the value of an expression should be substituted into the string. For example, we can write

```scala
val name = "Noel"

val hi = s"Hello $name!"
```

and `hi` will have the value `"Hello Noel!"`.

Scala's string interpolation is extensible. The character in front of the interpolated string, `s` in the example above, determines how the string is processed. The details, which are not important here, are given in the [documentation for the `StringContext` API][StringContext].

Another unique property of Scala's string interpolation is that the interpolated result does not necessarily have to be a `String`. In fact interpolation can evaluate to any type. This means that string interpolation can be used to embed domain specific languages (DSLs) within Scala, with interpolation functioning as the interface between the DSL and the Scala host. Lisp programmers will recognize string interpolation as a form of quasi-quote.

This is fine in theory, but there is a problem: how do we parse our embedded DSL when the parsing may be interrupted at any time with an interpolated value? This would be straightforward if only strings could be supplied as interpolated values. In this setting we could simply render everything to a string and then parse the result. However a major advantage of creating a DSL is that we can pass structured data from the host language into the embedded language.

This is the problem I faced when created a [Markdown string interpolator][mads]. My goal is to render markdown to web pages, and values I interpolate will be interactive components. To achieve this I created a parser combinator library that allows parsing to be suspended and then resumed with values injected from outside. In this post I describe the design of the library.

**Overview here**


## Parser Combinators


## Design Overview

Let's start by describing, at a high level, the problem. We start by parsing a `String`. Our parser will, if successful, produce a value of some type `A`. At certain points the parser may be suspended. At suspension the parser will have produced an intermediate value of type `S`. Additional values of type `S` may be injected into the suspended parse. A suspended parser may be resumed with additional `String` input and will continue parsing.

This gives the following types and operations.

```scala
trait Parser[S, A]:
  def parse(input: String): Result[S, A]

trait Result[S, A]:
  def inject(value: S): Result[S, A]
  def resume(input: String): Result[S, A]
```

Design decisions:

- Type of injection
- Where can suspend
- Can't carry state across suspend / resume

## Parser and Result

Large parts of the libary are standard, and based on [Cats Parse][cats-parse]. The `Parser` type is a fairly standard parser combinator library, supporting the usual applicative and monad combinators as well as parsing specific methods. The `Result` type consists of:

- `Epsilon`, indicating parsing failed without consuming any input;
- `Committed`, indicating parsing failed after consuming input; and
- `Success`, indicating a successful parse.

We differentiate between parsers that can successfully consume no input and those that must consume at least one character of input to succeed.

There is an additional case on `Result` that is key to supporting resumable parsing. A parser can return `Continue` to indicate it successfully parsed all its input and can continue parsing if more input becomes available. The parser that returns `Continue` does not decide, however, the interpretation of `Continue`. A `Continue` can become a success or a failure depending on context, and the programmer must provide an interpretation. The available choices, which are methods on `Parser`, are:

- `advance`, indicating that control should move to the next parser
- `unsuspendable`, indicating that this parser;
- `resume`; and
- `resumeWith`

A few small examples with help motivate these. Imagine parsing a Markdown header. A typical example is

```
## Parser and Result
```


The (simplified) grammar for a header is

```
heading space title
```

where `heading` is between 1 and 6 `#` characters, `space` is one or more whitespace characters, and `title` is zero or more characters until the end of the line.

## Continue 



[StringContext]: https://dotty.epfl.ch/api/scala/StringContext.html
[Mads]: https://github.com/noelwelsh/mads
[cats-parse]: https://github.com/typelevel/cats-parse
[commonmark]: https://commonmark.org/
