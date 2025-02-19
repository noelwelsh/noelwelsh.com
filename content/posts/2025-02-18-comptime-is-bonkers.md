+++
title = "Parametricity, or Comptime is Bonkers"
draft = true
+++

This blog post is a response to [Zig's Comptime is Bonkers Good][bonkers]. I don't want this post to be taken as a dunk on that post, but rather an attempt to add nuance to the conversation.

Take, for example, the following Zig function

```zig
fn mystery(comptime T: type, a: T)
```

and its equivalent in Rust

```rust
fn mystery<T>(a: T) -> T
```

This is the kind of information that our editor might show us when writing a call to one of these functions.
Does this information tell us anything about the implementation of the function `mystery`?
Concretely, can get reliably guess the output of the following code, first for Zig

```zig
try stdout.print("mystery(f64, 1.0) is {d}\n", .{mystery(f64, 1.0)});
try stdout.print("mystery(i32, 1) is {}\n", .{mystery(i32, 1)});
try stdout.print("mystery(bool, true) is {}\n", .{mystery(bool, true)});
```

and then for Rust

```rust
print!("mystery(1.0) is {}\n", mystery(1.0));
print!("mystery(i32, 1) is {}\n", mystery(1));
print!("mystery(bool, true) is {}\n", mystery(true));
```

Here's the actual output for the implementation I wrote. 
Again we'll start with the Zig code.
It does&hellip;something depending on the input.
If we call it with `f64` when get back the value we passed in.
With `i32` it adds `42` to the value.
With `bool` it negates the value.

```sh
mystery(f64, 1.0) is 1
mystery(i32, 1) is 43
mystery(bool, true) is false
```

In contrast, the Rust code always returns exactly the value it is passed.

```sh
mystery(1.0) is 1
mystery(i32, 1) is 1
mystery(bool, true) is true
```

Now the important bit: the Rust implementation is *not* just a choice I made. 
It is the *only* way I can implement this function given the type signature.
With that type signature the function *must* be the identity, and this is a consequence of parametricity.


## Parametricty

Ok, so what is parametricity? It's a property of functions with generic types, otherwise known as type parameters.
Parametricity says that inside the body of a function we cannot know anything about any type parameters except what is passed as a function parameter.
So in the function

```rust
fn mystery<T>(a: T) -> T
```

the only thing we know about `T` is that we have a value of that type.
In particular we don't know any functions we can call on `T` so we can do literally nothing with the value other than return it.
This is why there is only one implementation of `mystery`, the identity function that returns its input, in Rust or other languages that retain parametricity.

If a function wants to do something with a value of some generic type, what it does must be passed to the function.
Consider the following example.

```rust
fn mystery2<A, B>(a: A, f: fn(A) -> B) -> B
```

It has a parameter of type `A -> B` and a result of type `B`.
Parametricity tells us that the only we can create a value of type `B` is by applying `f` to `a`.
So once again parametricity tells us the implementation of the function.

```rust
fn mystery2<A, B>(a: A, f: fn(A) -> B) -> B {
  f(a)
}
```

Modularity.

Uniform behaviour.
```javascript
["Zachery", 1, {name: "Ziggy"}, "~Tilde~", "$bill"].toSorted()
// Array(5) [ "$bill", 1, "Zachery", {…}, "~Tilde~" ]
```
[bonkers]: https://www.scottredig.com/blog/bonkers_comptime/
[theorems-for-free]: https://dl.acm.org/doi/10.1145/99370.99404
