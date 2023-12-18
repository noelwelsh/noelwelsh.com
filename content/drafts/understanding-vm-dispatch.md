# Understanding Virtual Machine Dispatch 


Duality means the properties of one structure can be directly translated to another structure. 
There are many dualities in programming, which allows us to see different code structures as alternative implementations of some underlying concept. For example, function calls are dual to function returns. If we have a function that returns a value

```scala
val f: Int => Int = x => x + 40

val a = f(2)
val b = a * 2
```

we can, instead of returning that value, pass it to another function that does what we wanted to do with the value that was returned.

```scala
val f: (Int, Int => Int) => Int =
  (x, k) => k(x + 40)
  

val b = f(2, a => a * 2)
```

Call backs / continuation passing style.

Duality doesn't mean two things are identical. Although the two examples above compute the same result they differ in other ways. The obvious difference is that in the second example the function `f` has two parameters. There is another difference. Function calls consume a stack frame, which a subsequent return frees. If we replace returns with calls we'll never free any stack frames and so eventually run out. This leads us to tail calls.

A tail call is function call that doesn't consume a stack frame. Tail calls can only be made if a function call is in tail position. A function call is in tail position if the result of the call is immediately returned. So the call to `f` below is in tail position.

```scala
def f(x: Int): Int = x * 2

def g(x: Int): Int = f(x + 42)
```

However the call to `h` below is not, because the result is used in the subsequent addition.

```scala
def h(x: Int): Int = x / 2

def g(x: Int): Int = h(x) + 4
```

Tail calls will be important is what comes later. To make them explicit I'll going to use a `tailcall` keyword to explicitly indicate them. So I'll write

```scala
def g(x: Int): Int = tailcall f(x + 42)
```

to explicitly indicate that `f` is being called using a tail call.
