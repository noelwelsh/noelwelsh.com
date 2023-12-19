# Understanding Virtual Machine Dispatch 

For the next edition of [Scala with Cats](https://www.scalawithcats.com/) I'm writing a section on implementing interpreters.
In my research I ended up going fairly deep down the rabbit hole of optimizations, in which virtual machine dispatch is a major area. There are many different approaches to dispatch, and I struggled to relate them until I realized they were all variations on a basic structure that resulted from applying the principle of duality. Duality is one of the major themes of the book, so I was happy to make this discovery, and, since I haven't found in mentioned anywhere else but it isn't really appropriate for the book, decided to write it up here.

I'm going to first describe duality, then give context on interpreters and virtual machines, before moving on to the application of duality in virtual machine dispatch.


## Duality

Duality means we can make a direct correspondence between one structure and another structure. 
There are many dualities in programming, which allows us to see different code structures as alternative implementations of some underlying concept. For example, function calls are dual to function returns. If we have a function that returns a value, like `f` in

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

You may recognize this second style as programming with callbacks, and if you're a programming language theory person you recognize it as continuation passing style.

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

There is another duality that I want to discuss as we'll make use of it later: that between data and functions. Wherever we have data, we can replace it with a function that does whatever it is we want to do with that data.
For example, imagine choosing a contact to message from a list of contacts on your mobile phone. Instead of representing each contact as data containing a name, phone number, and so on, we can represent them as the action that initiates a message with them. We can extend this further to say the duality is between describing something in terms of what it is and in terms of what we can do with it. Describing what something is gives us data, while describing what we can do with it gives us functions or objects. Again, this doesn't mean that the two approaches are identical. They can achieve the same goal, but do it in different ways and have different properties.


## Bytecode Interpreters and Virtual Machines

There are two common ways to implement an interpreter: by directly interpreting an abstract syntax tree, known as a tree-walking interpreter, or by compiling the abstract syntax tree to a linear sequence of instructions and then interpreting these instructions. This is known as a bytecode interpreters as the instruction often, but not always, take up a single byte. The instructions describe actions of some virtual machine. There are two common types of virtual machine: register machines and stack machines, of which stack machines are the most common. If we consider the code that implements each instruction as a function, in a stack machine these functions receive parameters from and return results to a stack. An instruction to add two integers would therefore pop two values from the stack, add them, and push the result back. Stack machines are simple to implement, but as this short example illustrates there can be considerable inefficiencies in moving values to and from the stack.

Imagine we're implementing an interpreter for simple arithmetic. 
Our language consists of literals, addition, subtraction, multiplication, and division.
In Scala we might define stack machine bytecode as 

```scala
enum ByteCode {
  case Lit(value: Double)
  case Add
  case Sub
  case Mul
  case Div
}
```

Notice that the majority of operations have no parameters: these values come from the stack. In a register machine, the operations would have to specify registers where they find their parameters and the register where they store results.


## Interpreter Dispatch

The core of a bytecode interpreter is instruction dispatch: choosing the action to take given an instruction. Instruction dispatch has three components:

1. instruction fetch, which chooses the instruction to execute;
2. the actual dispatch, the chooses the action to take given the instruction that has been fetched; and
3. some kind of loop to continue the above two processes until the end of the program, if any, is reached.

Switch dispatch is the most common form of dispatch. This is named after the C language `switch` statement used to implement the dispatch component. Instruction fetch is often just an array reference, and the loop is usually an infinite `which` or `for` loop. In a functional language the loop would usually be a tail recursive function and  the switch would usually be implemented by a pattern match over the instructions. More abstractly, instructions are an algebraic data type and switch dispatch is a structurally recursive loop. 

Here's a complete interpreter in Scala illustrating switch dispatch.

```scala
// The stack
val stack: Array[Double] = ???

// The program, a sequence of instructions
val instructions: Array[ByteCode] = ???

// sp is the *stack pointer*
// Its value is the index of the first free location in the stack
//
// ip is the *instruction pointer*
// Its value is the index of the current instruction in instructions
def dispatch(sp: Int, ip: Int): Unit = {
  // This simple language has no control flow, so we stop when
  // we reach the end of the instructions
  if ip == instructions.size then stack(sp - 1)
  else 
    // Fetch instruction
    val ins = instructions(ip)
    // Dispatch
    ins match {
      case Op.Lit(value) =>
        stack(sp) = value
        loop(sp + 1, ip + 1)
      case Op.Add =>
        val a = stack(sp - 1)
        val b = stack(sp - 2)
        stack(sp - 2) = (a + b)
        loop(sp - 1, ip + 1)
      case Op.Sub =>
        val a = stack(sp - 1)
        val b = stack(sp - 2)
        stack(sp - 2) = (a - b)
        loop(sp - 1, ip + 1)
      case Op.Mul =>
        val a = stack(sp - 1)
        val b = stack(sp - 2)
        stack(sp - 2) = (a * b)
        loop(sp - 1, ip + 1)
      case Op.Div =>
        val a = stack(sp - 1)
        val b = stack(sp - 2)
        stack(sp - 2) = (a / b)
        loop(sp - 1, ip + 1)
    }
}
```


## Dispatch Through the Lens of Duality

The usual presentation of alternatives to switch dispatch (direct threading, indirect threading, and so on) in my opinion confuses the code level realization and the conceptual level. For example, discussion of direct threading often talks about labels-as-values, a GCC extension. The differences between dispatch methods only became clear to me when I saw them as different realizations of the three components making up dispatch that utilized the dualities I've described earlier.

Starting with switch dispatch described above, let's replace the bytecode instructions with functions that carry out the instructions, using the duality between data and functions. This gives us code like the following (where I'm leaving out bits that unchanged from the previous code.).

```scala
val instructions: Array[Op] = ???

var sp: Int = 0

// An operation is a function () => Unit
sealed abstract class Op extends Function0[Unit]
final case class Lit(value: Double) extends Op {
  def apply(): Int = {
    stack(sp) = value
    sp = sp + 1
  }
}
case object Add extends Op {
  def apply(): Int = {
    val a = stack(sp - 1)
    val b = stack(sp - 2)
    stack(sp - 2) = (a + b)
    sp = sp - 1
  }
}
case object Sub extends Op {
  def apply(): Int = {
    val a = stack(sp - 1)
    val b = stack(sp - 2)
    stack(sp - 2) = (a - b)
    sp = sp - 1
  }

}
case object Mul extends Op {
  def apply(): Int = {
    val a = stack(sp - 1)
    val b = stack(sp - 2)
    stack(sp - 2) = (a * b)
    sp = sp - 1
  }
}
case object Div extends Op {
  def apply(): Int = {
    val a = stack(sp - 1)
    val b = stack(sp - 2)
    stack(sp - 2) = (a / b)
    sp = sp - 1
  }
}

def dispatch(ip: Int): Unit = {
  if ip == instructions.size then stack(sp - 1)
  else 
    // Fetch instruction
    val ins = instructions(ip)
    // Dispatch
    ins()
    // Loop
    loop(ip + 1)
}
```

This is known as subroutine threading in the literature.

Now we will utilize the duality between calls and returns to replace the returns in the instruction functions with (tail) calls to the next instruction. This moves the instruction fetch and dispatch into the instructions, giving us what is known as direct threading. Now the loop is implicit, spread throughout the instruction as a sequence of tail calss. This gives us the following code (where I'm again just showing the important bits.)

```scala
val instructions: Array[Op] = ???

var sp: Int = 0
var ip: Int = 0

// An operation is a function () => Unit
sealed abstract class Op extends Function0[Unit]
final case class Lit(value: Double) extends Op {
  def apply(): Int = {
    stack(sp) = value
    sp = sp + 1
    ip = ip + 1
    if ip == instructions.size then stack(sp - 1)
    else tailcall instructions(ip)()
  }
}
case object Add extends Op {
  def apply(): Int = {
    val a = stack(sp - 1)
    val b = stack(sp - 2)
    stack(sp - 2) = (a + b)
    sp = sp - 1
    ip = ip + 1
    if ip == instructions.size then stack(sp - 1)
    else tailcall instructions(ip)()
  }
}
case object Sub extends Op {
  def apply(): Int = {
    val a = stack(sp - 1)
    val b = stack(sp - 2)
    stack(sp - 2) = (a - b)
    sp = sp - 1
    ip = ip + 1
    if ip == instructions.size then stack(sp - 1)
    else tailcall instructions(ip)()
  }

}
case object Mul extends Op {
  def apply(): Int = {
    val a = stack(sp - 1)
    val b = stack(sp - 2)
    stack(sp - 2) = (a * b)
    sp = sp - 1
    ip = ip + 1
    if ip == instructions.size then stack(sp - 1)
    else tailcall instructions(ip)()
  }
}
case object Div extends Op {
  def apply(): Int = {
    val a = stack(sp - 1)
    val b = stack(sp - 2)
    stack(sp - 2) = (a / b)
    sp = sp - 1
    ip = ip + 1
    if ip == instructions.size then stack(sp - 1)
    else tailcall instructions(ip)()
  }
}
```

There is one variant left, which is to keep the instructions as bytecode data but use tail calls in instruction dispatch. This gives us indirect threaded dispatch.

```scala
val instructions: Array[ByteCode] = ???

var sp: Int = 0
var ip: Int = 0

def lit(value: Double): Int = {
  stack(sp) = value
  sp = sp + 1
  ip = ip + 1
  if ip == instructions.size then stack(sp - 1)
  else tailcall dispatch(instruction(ip))
}

def add(): Int = {
  val a = stack(sp - 1)
  val b = stack(sp - 2)
  stack(sp - 2) = (a + b)
  sp = sp - 1
  ip = ip + 1
  if ip == instructions.size then stack(sp - 1)
  else tailcall dispatch(instruction(ip))
}

def sub(): Int = {
  val a = stack(sp - 1)
  val b = stack(sp - 2)
  stack(sp - 2) = (a - b)
  sp = sp - 1
  ip = ip + 1
  if ip == instructions.size then stack(sp - 1)
  else tailcall dispatch(instruction(ip))
}

def mul(): Int = {
  val a = stack(sp - 1)
  val b = stack(sp - 2)
  stack(sp - 2) = (a * b)
  sp = sp - 1
  ip = ip + 1
  if ip == instructions.size then stack(sp - 1)
  else tailcall dispatch(instruction(ip))
}

def div(): Int = {
  val a = stack(sp - 1)
  val b = stack(sp - 2)
  stack(sp - 2) = (a / b)
  sp = sp - 1
  ip = ip + 1
  if ip == instructions.size then stack(sp - 1)
  else tailcall dispatch(instruction(ip))
}

def dispatch(instruction: ByteCode): Unit = {
  instruction match {
    case Op.Lit(value) =>
      tailcall lit(value)
    case Op.Add =>
      tailcall add()
    case Op.Sub =>
      tailcall sub()
    case Op.Mul =>
      tailcall mul()
    case Op.Div =>
      tailcall div()
  }
}
```

We've seen the four main variants of dispatch can all be explained from considering dualities between data and functions for instructions and calls and returns for looping:

- data / call and return: switch dispatch
- data / tail call: indirect threaded dispatch
- function / call and return: subroutine dispatch
- function / tail call: direct threaded dispatch
