# Optimizing Interpreters for a Virtual Machine

<One para introduction here>

Programmers love implementing programming languages, though they often don't realize it. Domain specific languages arise any time there is a distinction between the description of what should happen and that description being carried out. Something as common place as a request matching library, which almost every web framework includes, is a little DSL. DSLs are particularly common in the world of functional programming, because they are the means for handling effects while keeping desirable code properties of composition and reasoning. Examples include [Cats Effect](https://typelevel.org/cats-effect/) and my own [Doodle](https://www.creativescala.org/doodle/).

Programming languages come in two halves: the language itself which describes the actions that should occur, and the implementation that carries out those actions. The implementation of a DSL is usually an interpreter. Interpreters are orders of magnitude less effort to implement than compilers, but performance can be an issue. There are well established techniques for optimizing interpreters, but the majority of the work focuses on interpreters implemented in C or assembly targeting a physical CPU. Optimizing an interpreter running on a virtual machine with a JIT compiler, which is the case for many languages, is a different matter. Here we must target not the underlying CPU or the virtual machine, but the JIT compiler as the path to the highest performance.

Given their importance in functional programming, I'm including a section on implementing interpreters in the second edition of [my book, Scala with Cats](https://www.scalawithcats.com/). For this I wanted to show the effect of different optimizations on a stack based virtual machine, the most common path to implementing a reasonably performant interpreter. I found the results very surprising. Most optimizations had negligible effect on their own. The combination of several optimizations had a noticeable performance improvement. One optimization made a 60'000 times (yes, that is not a typo) improvement. 

Etc.


## Virtual Machines and Their Implementation

The standard pathway to a fast interpreter is to compile from an abstract syntax tree (an algebraic data type, in functional programmer speak) to a linear sequence of instructions for some virtual machine. These instructions are often called bytecode, though they don't necessarily take up a single byte. (Metacompilation systems, like [GraalVM](https://www.graalvm.org/), [may be changing this equation](https://stefan-marr.de/2023/10/ast-vs-bytecode-interpreters/), but they are not widely deployed at present.)

There are two primary dimensions that characterise virtual machines: whether they communicate values on a stack or in registers, and the dispatch mechanism they use to select the code implementing a given instruction.

Stack machines are much more common than register machines. If we consider the code that implements each instruction as a function, then in a stack machine these functions communicate via a stack: parameters are received on a stack and results are returned on the same stack. An instruction to add two integers would therefore pop two values from the stack, add them, and push the result back. Stack machines are simple to implement, but as this short example illustrates there can be considerable inefficiencies in moving values to and from the stack.

Switch dispatch is the most common form of dispatch. This is named after the C language feature used to implement it, but it actually has three components: a loop containing an instruction fetch followed by a switch to select the code to run for the instruction. In a functional language the loop and instruction fetch are the same but the switch would usually be implemented by a pattern match over the instructions respectively. More abstractly, instructions are an algebraic data type and switch dispatch is a structurally recursive loop. 

The usual presentation of alternatives to switch dispatch (direct threading, indirect threading, and so on) in my opinion confuse the code level realization and the conceptual level. For example, discussion of direct threading often talks about labels-as-values, a GCC extension, whereas the core concepts are first class functions and tail calls. Rather than describe all these different dispatch methods I'll sketch out the design space at the conceptual level. There are two concepts we need: the duality between data and functions (or codata, if we're feeling fancy), and the semantics of tail calls versus normal calls. 

Duality between data and functions means that anything we do with data we can instead do with a function. The function simply does whatever it is we wanted to do with the data. So instead of storing instructions as bytecode, we can store them as the function that carries out the operation associated with the bytecode. This avoids the switch part of switch dispatch. 

A normal call alllocates a stack frame, whereas a tail call does not. As tail calls do not consume stack space we can have an indefinite sequence of tail calls, without any returns, and still not overflow the stack. Normal calls must regularly return however, and so an indefinite sequence of normal calls requires an outer loop known as a trampoline, to which the calls return.

With these concepts in mind we can now sketch out the design space of dispatch alternatives. 

## Optimizations

### Reducing Dispatch

Do more per dispatch: superinstructions.

Do dispatch faster: church encoding and tail calls.


### Reducing Memory Traffic

Stack caching.


### Inlining: The Mother of All Optimization

