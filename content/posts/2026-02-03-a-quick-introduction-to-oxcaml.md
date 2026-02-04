+++
title = "A Quick Introduction to OxCaml"
+++

Over the Christmas holidays I decided to learn more about [OxCaml][oxcaml], [Jane Street's][jane-street] systems programming variant of the [OCaml][ocaml] programming language. In this post I give an overview of OxCaml, describe how to get started using it, and discuss a simple example that shows the performance benefits from using one of its basic feature: unboxed types.

<!-- more -->

## What is OxCaml?

OxCaml is a set of extensions to OCaml, so we must first talk a little bit about OCaml. OCaml is a statically typed, strict functional programming language. It shares many features with Scala and Rust; they all have first-class functions, algebraic data types, pattern matching, and expressive type systems, for example. OCaml, like Scala but unlike Rust, has a garbage collector. Rust's lack of a garbage collector is one reason it is often touted as suitable for systems programming.

OxCaml adds many new features to OCaml, but the most interesting, in my opinion, are those giving control over memory allocation and memory layout, and concurrency free of data races. These are important for performance optimization and when interfacing to hardware, two traditional areas for systems programming. In this post I'll focus on just one feature, unboxed types, which already shows why OxCaml is intriguing. If time allows, future posts will explore other areas.

These features wouldn't be very interesting if they weren't also safe. OxCaml, for example, won't let you stack allocate a value if that value could escape the region in which it is defined, preventing use-after-free bugs. It does this by extending OCaml's type system in two directions, with: *modes*, which are attributes associated with types, but not types themselves, and *kinds*, which are ways of classifying types. Modes establish contexts permit or forbid certain operations. For example, the `once` mode, which only applies to function types, allows a function to be called only a single time. The `local` mode, which can apply to any type, prevents any reference escaping the region in which it is defined, and thus allows stack allocation. Kinds represent information that is used to control memory layout, for example in unboxed types. 

If you know Rust you'll see that these features are very similar at the high-level to what Rust offers. However, the ergonomics of OxCaml are quite different. OxCaml takes an opt-in approach to its systems programming features. If, say, we don't care about memory allocation, we can leave it all to the garbage collector. This makes it straightforward to write code that isn't performance sensitive, while giving us the ability to get into the details where it is important. In Rust we always have to concern ourselves with ownership and the like, whether it's important or not. I therefore think OxCaml is important tool, both for practical programming now, and for guiding the future evolution of programming.


## Getting Started with OxCaml

Installing OxCaml is straightforward. Follow [the instructions](https://ocaml.org/install) for OCaml, and then [the instructions](https://oxcaml.org/get-oxcaml/) for OxCaml. It will take a little while, but worked without issue for me on both MacOS and Linux. For OCaml and tooling questions (e.g. working with Dune), your LLM of choice will usually be able to guide you. 

Unfortunately, I found that OxCaml is too new for LLMs, and the OxCaml documentation is both sparse and, where it exists, out-of-date. The most comprehensive and update-to-date resource that I have found is [Anil Madhavapeddy's Claude skills][claude-skills]. That the documentation for AI is better than the documentation for humans is truly a sign of the times!


## Unboxed Types in Practice

In starting my OxCaml adventure, I wanted an example that both very simple and demonstrated the utility of OxCaml. An arithmetic interpreter was the simplest example I could come up with. This represents arithmetic expressions as an algebraic data type (or abstract syntax tree), and defines the standard interpreter for them using structural recursion. (All this terminology is explained in [my book][fps], if you're not familiar with it.) In OCaml code, the expression data structure is

```ocaml
type expr =
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Literal of float
```

while the interpreter is

```ocaml
let rec eval (e : expr) : float =
  match e with
  | Add (l, r) ->
      eval l +. eval r
  | Sub (l, r) ->
      eval l -. eval r
  | Mul (l, r) ->
      eval l *. eval r
  | Div (l, r) ->
      eval l /. eval r
  | Literal l ->
      l
```

This is a great candidate for using [unboxed types](https://oxcaml.org/documentation/unboxed-types/01-intro/), specifically unboxed floats. I'll first give the code and benchmark results, and then talk about boxed and unboxed types and why we'd want them.

Here's the unboxed interpreter.

```ocaml
open Float_u

let rec eval_unboxed (e : expr) : float# =
  match e with
  | Add (l, r) ->
      eval_unboxed l + eval_unboxed r
  | Sub (l, r) ->
      eval_unboxed l - eval_unboxed r
  | Mul (l, r) ->
      eval_unboxed l * eval_unboxed r
  | Div (l, r) ->
      eval_unboxed l / eval_unboxed r
  | Literal l ->
      of_float l

let eval (e : expr) : float = to_float (eval_unboxed e)
```

The changes to note are:

- we replace the `float` type with `float#`, its unboxed equivalent;
- we use operations in `Float_u` to work on unboxed floats; and
- we converted from between unboxed floats and boxed floats with `Float_u.of_float` and `Float_u.to_float` respectively.

Also note this a place where the OxCaml documents lie. They [claim](https://oxcaml.org/documentation/unboxed-types/01-intro/) the operations for unboxed types are in the `janestreet_shims` library, but as some point I guess they migrated into the standard library. If you want to use OxCaml right now, you'll have to be prepared to dig around the [code](https://github.com/oxcaml/oxcaml/blob/main/otherlibs/stdlib_upstream_compatible/float_u.mli) and figure some things out yourself.

For benchmarking I created an expression that calculates the 20th Fibonacci number using the naive recursive method. This *isn't* good way to calculate Fibonacci numbers, but it *is* a reasonable test for the interpreter as it produces a big expression tree and involves a lot of arithmetic. Here are the results on my desktop:

```
┌────────────────┬──────────┬──────────┬──────────┬────────────┬────────────┐
│ Name           │ Prom/Run │ mjWd/Run │ Time/Run │    mWd/Run │ Percentage │
├────────────────┼──────────┼──────────┼──────────┼────────────┼────────────┤
│ fib 20         │    0.43w │    0.43w │ 138.17us │ 21_893.00w │    100.00% │
│ unboxed fib 20 │          │          │  94.04us │      5.00w │     68.07% │
└────────────────┴──────────┴──────────┴──────────┴────────────┴────────────┘
```

Results in `mjWd` and `mWd` are not some [crazy American units](https://en.wikipedia.org/wiki/United_States_customary_units), but measurements of memory allocation in terms of words, i.e. 64 bits. `mjWd/Run` is millions of words allocated on the major heap per run, and `mWd/Run` is millions of words allocated per run. It's clear that the boxed version produces a lot of allocation, while the unboxed version does almost no allocation. The unboxed version also runs substantially faster. To understand how these results come about we need to understand unboxed values. Let's turn to that now.


### Boxed and Unboxed Values

There are two main ways to represent a value in OCaml: a *boxed value*, which is a heap-allocated block represented by a pointer, and an *unboxed value*, which is represented directly without heap allocation.

Here's a simple example. The OCaml code

```ocaml
let f = 3.14
```

declares a normal (that is, boxed) float with the following representation:

```
f
│
▼
Heap
┌───────────────────────────────┐
│ header: size=1, tag=Double    │
├───────────────────────────────┤
│ 3.14 (IEEE 754 double)        │
└───────────────────────────────┘
```

`f` itself is a reference to a heap allocated block. That block consists of a header telling the garbage collector we allocated one block to hold a double precision float, and then the float itself.

In contrast, an unboxed float such as

```ocaml
let f = 3.14#
```

has the representation

```
f
┌───────────────────────────────┐
│ 3.14 (IEEE 754 double)        │
└───────────────────────────────┘
```

That is, `f` is represented directly as the floating point value, with no heap allocation and no pointer indirection.

Using boxed values incurs several costs: allocating memory on the heap, the extra space required for the heap block (such as headers), an extra level of indirection when accessing the value, and the cost of garbage-collecting the allocated block. When we understand this, the performance difference between the boxed and unboxed code is obvious.

If unboxed values are so good, why don't we use them everywhere? There are several good reasons. We often write functions that are polymorphic,  meaning they work uniformly over values of many different types. For example, the `identity` function
  
```ocaml
let identity a = a
```

works with values of any type. The compiler needs to transform this to actual machine code. This is simple when all values have a uniform representation, which is the case in OCaml where all values are represented by a single machine word. The compiler knows that all values can be represented as references, and all references have the same size (usually 64 bits.) Therefore it can compile `identity` to a single machine code function that will work with all values. However, this is no longer the case if we also allow unboxed values. Now `identity` might be called with values of different sizes and representations&mdash;some fitting into a single word and others requiring multiple words. We have to produce a different version of `identity` for each concrete representation it is called with. This approach is known as *monomorphization*, and while it makes code faster it both slows down compilation and prevents separate compilation. Unboxed values also increase the complexity of the runtime system; there are more kinds of values that the garbage collector must understand, which increases implementation complexity and maintenance cost. It also makes the language more complex. We must have ways to specify unboxed values and carefully define how unboxed and boxed values interact.


## Conclusions

OxCaml still feels rough around the edges but there is lots of good stuff packed in there. I think it represents an exciting project bringing research developments into practical programming. I'll definitely be playing with it more, and encourage you to do the same. If you want to experiment with my code, you can fit it [on Github][oxcaml-experiments].


[oxcaml]: https://oxcaml.org/
[jane-street]: https://www.janestreet.com/
[ocaml]: https://ocaml.org/
[claude-skills]: https://github.com/avsm/ocaml-claude-marketplace/blob/main/plugins/ocaml-dev/skills/oxcaml
[fps]: https://functionalprogrammingstrategies.com/
[oxcaml-experiments]: https://github.com/noelwelsh/oxcaml-experiments
