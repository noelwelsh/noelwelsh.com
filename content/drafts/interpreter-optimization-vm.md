# Optimizing Interpreters for a Virtual Machine

I've recently been exploring implementation strategies and performance of interpreters in Scala. **TODO**

Domain specific languages (DSLs) are ubiquitous in programming.
Custom programming languages arise any time there is a distinction between the description of what should happen and that description being carried out. 
Something as common as a request matching library, which almost every web framework includes, is a little DSL. 
DSLs are particularly common in the world of functional programming, because they are the means for handling effects while keeping desirable code properties of composition and reasoning. 
Examples include [Cats Effect](https://typelevel.org/cats-effect/) and my own [Doodle](https://www.creativescala.org/doodle/).

Programming languages come in two halves: the language itself which describes the actions that should occur, and the implementation that carries out those actions. The implementation of a DSL is usually an interpreter. Interpreters are orders of magnitude less effort to implement than compilers, but performance can be an issue. There are well established techniques for optimizing interpreters, but the majority of the work focuses on interpreters implemented in C or assembly targeting a physical CPU. Optimizing an interpreter running on a virtual machine with a JIT compiler, which is the case for many languages, is a different matter. Here we must target not the underlying CPU or the virtual machine, but the JIT compiler as the path to the highest performance.

Given their importance in functional programming, I'm including a section on implementing interpreters in the second edition of [my book, Scala with Cats](https://www.scalawithcats.com/). For this I wanted to show the effect of different optimizations on a stack based virtual machine, the most common path to implementing a reasonably performant interpreter. I found the results very surprising. Most optimizations had negligible effect on their own. The combination of several optimizations had a noticeable performance improvement. One optimization made a 60'000 times (yes, that is not a typo) improvement. 

**TODO** Describe optimizations from a programming language theory point of view.

**TODO** Investigate performance when compiling for a VM that includes a JIT compiler.


## Virtual Machines and Their Implementation

The standard pathway to a fast interpreter is to compile from an abstract syntax tree (an algebraic data type, in functional programmer speak) to a linear sequence of instructions for some virtual machine. These instructions are often called bytecode, though they don't necessarily take up a single byte. (Metacompilation systems, like [GraalVM](https://www.graalvm.org/), [may be changing this equation](https://stefan-marr.de/2023/10/ast-vs-bytecode-interpreters/), but they are not widely deployed at present.)

There are two primary dimensions to virtual machines: how they communicate values between operations, and the dispatch mechanism used to select the code implementing a given instruction.

A stack is most common mechanism to communicate values. If we consider the code that implements each instruction as a function, in a stack machine these functions receive parameters from and return results to a stack. An instruction to add two integers would therefore pop two values from the stack, add them, and push the result back. Stack machines are simple to implement, but as this short example illustrates there can be considerable inefficiencies in moving values to and from the stack.

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

Notice that the majority of operations have no parameters: these values come from the stack. In a register machine, the most common alternative to a stack machine, operations would have to specify registers where they find their parameters and the register where they store results.

The other part of an interpreter is dispatch: choosing the action to take given an instruction.
Switch dispatch is the most common form of dispatch. This is named after the C language feature used to implement it, but it actually has three components: a loop containing an instruction fetch followed by a switch to select the code to run for the instruction. In a functional language the loop and instruction fetch are the same but the switch would usually be implemented by a pattern match over the instructions respectively. More abstractly, instructions are an algebraic data type and switch dispatch is a structurally recursive loop. 

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

The usual presentation of alternatives to switch dispatch (direct threading, indirect threading, and so on) in my opinion confuses the code level realization and the conceptual level. For example, discussion of direct threading often talks about labels-as-values, a GCC extension, whereas the core concepts are first class functions and tail calls. Rather than describe all these different dispatch methods I'll sketch out the design space using concepts from programming language theory. There are two concepts we need: the duality between data and functions (or codata, if we're feeling fancy), and the differences between tail calls versus normal calls. 

The duality between data and functions means that we can replace data with functions. The function simply does whatever it is we wanted to do with the data. In our example, instead of storing instructions as bytecode we can store them as the function that carries out the operation associated with the bytecode. This avoids the switch part of switch dispatch. 

A normal call allocates a stack frame, whereas a tail call does not. As tail calls do not consume stack space we can have an indefinite sequence of tail calls, without any returns, and still not overflow the stack. Normal calls must regularly return, so an indefinite sequence of normal calls requires an outer loop known as a trampoline, to which the calls return.

With these concepts in mind we can now sketch out the design space of dispatch alternatives. Remember there are three components: the loop, the instruction fetch, and actual dispatch. In switch dispatch we have an outer loop containing the fetch and the dispatch. Now if 1) replace bytecode with functions, and 2) end every function with an instruction fetch and a tail call to that instruction, we have what is know as direct threading. Here's the sketch in code, where I'm using the imaginary `tailcall` keyword to explicitly indicate tail calls.

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

Two points to note here. The `Lit` operation needs some data, so were actually storing closures (or their equivalent, objects) as our instructions. We might layout data differently if we have access to raw memory, but the concept is the same. If you're a programming language theory person you might squint a bit and see that direct threaded dispatch is in fact a variation of continuation passing style.

If we don't have full tail calls, we can implement direct threading with a trampoline. This gives us what is known as subroutine threading. The code looks like

```scala
val instructions: Array[Op] = ???

var sp: Int = 0
var ip: Int = 0

// An operation is a function () => Unit
sealed abstract class Op extends Function0[Unit]
final case class Lit(value: Double) extends Op {
  def apply(): Unit = {
    stack(sp) = value
    sp = sp + 1
    ip = ip + 1
  }
}
case object Add extends Op {
  def apply(): Unit = {
    val a = stack(sp - 1)
    val b = stack(sp - 2)
    stack(sp - 2) = (a + b)
    sp = sp - 1
    ip = ip + 1
  }
}
// and so on ...

// This is the trampoline
def dispatch(): Int =
 if ip == instructions.size then stack(sp - 1)
 else 
   // Call instruction
   instructions(ip)()
   // Loop around the trampoline when the instruction returns
   // Scala doesn't have full tail calls but does have self tail calls
   dispatch()
```

If we want to keep representing our instructions as byte code, because they might be smaller than pointers to functions, put still use tail calls, then every function ends not with a simple fetch and tail call but a fetch, switch, and tail call. This is indirect-threaded dispatch.




## Optimizations

Now that we've seen the fundamental components of a stack based virtual machine, lets briefly talk about some optimizations.
There are two broad categories: those that aim to do more work per dispatch, and those that aim to reduce the inefficiencies of a stack machine.

### Reducing Dispatch

Do more per dispatch: superinstructions.



### Reducing Memory Traffic

Stack caching.


### Inlining: The Mother of All Optimization

