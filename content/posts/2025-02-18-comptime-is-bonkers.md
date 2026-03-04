+++
title = "Parametricity, or Comptime is Bonkers"
draft = true
+++

Here's a puzzle. Without looking at the body, what does this [Rust][rust] function do? 

```rust
fn mystery<T>(a: T) -> T
```

If you know a little type theory, you might already see it: this function must return `a`. Not by convention, nor by style guide: the type system makes any other implementation impossible. There is nothing else you can do with a value of an unknown type except give it back.

This property—that a type signature can determine an implementation—is called *parametricity*, and it's one of the most underappreciated ideas in
 programming language design. It's also exactly what [Zig's][zig] [comptime][comptime] gives up.

A [recent post][bonkers] made the case that comptime is "bonkers good", and I don't want to argue against that. Comptime is genuinely powerful. But power has a shape, and understanding what parametricity is—and what we lose without it—makes for a much richer picture of what Zig is doing and why it's an interesting design choice.

Let's consider the Zig equivalent to the Rust function signature above. The `comptime` keyword marks `T` as a compile time parameter—meaning the function body can inspect it, branch on it, and behave completely differently depending on which type it receives.

Consider this Zig function signature:

```zig
fn mystery(comptime T: type, a: T) T
```

Can you tell what this does from the signature alone?

Here's the output from the implementation I wrote:

```sh
mystery(f64, 1.0) is 1
mystery(i32, 1) is 43
mystery(bool, true) is false
```

If the results surprised you, welcome to comptime. The function returns the value unchanged for floats, adds 42 for integers, and negates booleans. Nothing in the signature tells you this—and nothing can, because comptime puts no constraint on what the body is allowed to do.


## Parametricity

Ok, so what exactly is parametricity? It's a property of functions with generic types, also known as type parameters. It says that inside the body of such a function we cannot know anything about a type parameter beyond what is passed as a function argument.

In the Rust function

```rust
fn mystery<T>(a: T) -> T
```

we don't know the size of `T`, can't call any methods on it, can't compare it to anything. All we can do is return it—which is why the identity
function is the only possible implementation.

If a function needs to do something with a generic value, whatever it does must itself be passed as an argument. Take this example:

```rust
fn mystery2<A, B>(a: A, f: fn(A) -> B) -> B
```

We have a value of type `A` and need to produce a value of type `B`. The only source of `B` values available is `f`. So again there is exactly one implementation:

```rust
fn mystery2<A, B>(a: A, f: fn(A) -> B) -> B {
  f(a)
}
```

Parametricity is a form of modularity. Modularity is usually described as a property between components: one module hides its implementation from
another, exposing only an interface. Parametricity works the same way, but within a single function. At the definition site the function body is
isolated from any knowledge of what concrete type `T` will be. It can only work with the interface it is presented, which is exactly the parameters to the function. At the call site the caller knows exactly what type they're passing, but cannot see past the function signature to the implementation.

Parametricity is the dual of abstraction. Abstraction hides unnecessary details from the caller—we use a function without needing to know how it
works. Parametricity hides unnecessary details from the implementer—we write a function without being able to know what types it will be called
with. Both are the same idea at work: managing which knowledge is available where, so that reasoning stays tractable.

One consequence of this is that parametric functions have uniform behaviour. If the body can't branch on the type, it can't behave differently per
type. We can learn a parametric function once and trust that knowledge everywhere we use it.


## The Cost of Understanding Code

Studies ([for][prog-comp] [example][40-years]) consistently find that developers spend around half their time simply reading and comprehending code—not writing it nor debugging it, but just understanding what existing code does. That's a striking figure and anything that reduces comprehension cost has an outsized effect on productivity.

Parametricity directly attacks this cost. When a function is parametric its type signature is not just a hint about the implementation, but a language-enforced constraint on what the function can possibly do. We don't need to read the body, check the tests, or trust that the name is accurate, to understand properties of the function. The types are a proof, which gives [theorems for free][theorems-for-free][^reynolds].

[^reynolds]: Phil Wadler's [Theorems for Free][theorems-for-free] paper is probably the best known in the programming language theory, but parametricity was introduced much earlier, in John Reynolds' 1983 paper [Types, abstraction and parametric polymorphism][reynolds].

This compounds through a codebase. Once we understand what map does—applies a function to every element of a collection—we understand it for
  `Iterator`, for `Option`, for `Result`, for any type at all. The knowledge transfers because the behaviour is uniform. We learn it once.

The failure mode when this breaks is instructive. JavaScript's `Array.toSorted()`, called without a comparator, converts everything to strings before sorting. It's consistent, but not uniform—it requires special-case knowledge to predict.

```javascript
["Zachery", 1, {name: "Ziggy"}, "~Tilde~", "$bill"].toSorted()
// Array(5) [ "$bill", 1, "Zachery", {…}, "~Tilde~" ]
```

The integer `1` lands between `"$bill"` and `"Zachery"` because `"1"` sorts there lexicographically. Nothing in the function signature suggests this behaviour. That's the comprehension tax that parametricity eliminates—not just on the first reading, but every time we encounter code we haven't seen before. The same logic applies to any reader working under context constraints. The more we can infer from a type signature alone, the less we need to expand and read. Parametric types are a compact, verifiable representation of behaviour, which is useful whether the reader is a person doing code review or a tool with a limited window into our codebase.

This might prompt a question: what if we genuinely need different behaviour per type? Modern parametric languages[^java] have a solution to this, which we'll turn to now.

[^java]: Some older languages, such as Java, do not have a solution to this problem, but even Java [has plans to add a solution][growing-java].


## Choices at Compile Time

Consider a set data structure. A set of unsigned integers can be compactly represented as a bitset while other types need a different representation; perhaps a hash table or a balanced tree. A parametric function does not have the information to make this choice, while comptime punctures the modularity barrier, allowing compile time dispatch on type.

Parametric languages address this by allowing functions to take additional parameters that add information known at compile time. This is the essence of Haskell's type classes, Rust's traits, and Scala's implicits. In such a language we can define different representations associated with types: a bitset representation for unsigned integers, and some other representation for other types. This solves the problem of allowing different behaviour per type—so-called ad hoc polymorphism—while maintaining parametricity: this additional information is still conceptually a function parameter and present in the function signature. 

In Rust, our set example might have a signature like

```rust
fn empty_set<T: SetRepresentation>() -> Set<T>
```

where the `SetRepresentation` trait holds the information needed to construct the data structure. The trait appears in the signature, so parametricity is preserved: callers can still reason from the type alone.


## Conclusions

Comptime gives genuine power. The ability to specialise behaviour on types at compile time is useful, and Zig's staging story—running arbitrary code at compile time—is an underappreciated idea that most languages handle poorly. I don't want to dismiss that.

However, for the specific problem of generic programming the trade-off doesn't hold up. The alternative—type classes, as in Haskell, or traits, as in Rust—gives ad hoc polymorphism (functions that behave differently depending on the type) while preserving parametricity. We get specialisation where we ask for it, and reasoning guarantees everywhere else. It's extensible, too: anyone can add a new type to an existing type class. Zig's comptime dispatch is not.

The deeper issue is that comptime conflates two things: staging (running code at compile time) and generic programming (writing code that works over many types). These are different problems with different best solutions. Staging really does benefit from comptime-style power. Generic programming really does benefit from parametricity. Using one mechanism for both means accepting a worse answer to one of them.

So yes—comptime is bonkers. But not entirely in the good way.


[rust]: https://rust-lang.org/
[bonkers]: https://www.scottredig.com/blog/bonkers_comptime/
[theorems-for-free]: https://dl.acm.org/doi/10.1145/99370.99404
[zig]: https://ziglang.org/
[comptime]: https://ziglang.org/documentation/0.15.2/#comptime
[prog-comp]: https://baolingfeng.github.io/papers/tsecomprehension.pdf
[40-years]: https://dl.acm.org/doi/10.1145/3626522
[reynolds]: https://people.mpi-sws.org/~dreyer/tor/papers/reynolds.pdf
[growing-java]: https://www.youtube.com/watch?v=Gz7Or9C0TpM
