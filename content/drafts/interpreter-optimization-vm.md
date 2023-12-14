# Optimizing Interpreters for a Virtual Machine

<One para introduction here>

Programmers love implementing programming languages, though they often don't realize it. Domain specific languages arise any time there is a distinction between the description of what should happen and that description being carried out. Something as common place as a request matching library, which almost every web framework includes, is a little DSL. DSLs are particularly common in the world of functional programming, because they are the means for handling effects while keeping desirable code properties of composition and reasoning. Examples include [Cats Effect](https://typelevel.org/cats-effect/) and my own [Doodle](https://www.creativescala.org/doodle/).

Programming languages come in two halves: the language itself which describes the actions that should occur, and the implementation that carries out those actions. The implementation of a DSL is usually an interpreter. Interpreters are orders of magnitude less effort to implement than compilers, but performance can be an issue. There are well established techniques for optimizing interpreters, but the majority of the work focuses on interpreters implemented in C or assembly targeting a physical CPU. Optimizing an interpreter running on a virtual machine with a JIT compiler, which is the case for many languages, is a different matter. Here we must target not the underlying CPU or the virtual machine, but the JIT compiler as the path to the highest performance.

Given their importance in functional programming, I'm including a section on implementing interpreters in the second edition of [my book, Scala with Cats](https://www.scalawithcats.com/). For this I wanted to show the effect of different optimizations on a stack based virtual machine, the most common path to implementing a reasonably performant interpreter. I found the results very surprising. Most optimizations had negligible effect on their own. The combination of several optimizations had a noticeable performance improvement. One optimization made a 60'000 times (yes, that is not a typo) improvement. 

Etc.


## Virtual Machines and Their Implementation

The standard pathway to a fast interpreter is to compile from an abstract syntax tree (an algebraic data type, in functional programmer speak) to a linear sequence of instructions for some virtual machine. These instructions are often called bytecode, though they don't necessarily take up a single byte. (Metacompilation systems, like [GraalVM](https://www.graalvm.org/), [may be changing this equation](https://stefan-marr.de/2023/10/ast-vs-bytecode-interpreters/), but they are not widely deployed at present.)

There are two primary dimensions that characterise virtual machines: whether they communicate values using a stack or registers, and the dispatch mechanism they use to find the code implementing a given instruction.

Stack machines are the most common form of virtual machine. If we consider the code that implements each instruction as a function, then in a stack machine these functions communicate via a stack: parameters are received on a stack and results are returned on the same stack. An instruction to add two integers would therefore pop two values from the stack, add them, and push the result back. Stack machines are simple to implement, but as this short example illustrates there can be considerable inefficiencies in moving values to and from the stack.

Switch dispatch is the simplest form of dispatch. This is named after the C language feature used to implement it, but it actually has two components: a loop and a switch. The equivalent in most functional languages is a tail recursive loop and a pattern match over the instructions respectively. Thus we can see that instructions are (at least conceptually) an algebraic data type. The alternatives to switch dispatch (direct threading, indirect threading, and so on) are in my mind best explained 

In functional programming we know that functions are the dual of data: what we represent as data we can also represent


## Optimizations

### Reducing Dispatch

Do more per dispatch: superinstructions.

Do dispatch faster: church encoding and tail calls.


### Reducing Memory Traffic

Stack caching.


### Inlining: The Mother of All Optimization

