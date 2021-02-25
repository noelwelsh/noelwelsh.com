+++
title = "The Uses of Finite State Machines"
+++

Finite state machines (FSMs) are an extremely useful abstraction, that don't get the attention they deserve within the industry programming world. 

Discuss why they are useful using examples from job scheduling user interface design, and creative coding.


## The Computer Sciencist's View

If you studied computer science you probably met finite state machines within a "Theory of Computation" class. Mine was taught by a very nice guy with a very monotone voice. 

The computer scientist needs a formal definition to make formal statements about the properties of finite state machines. For example, ...

The result of this need for precision is a zoo of closely related models. Common models include deterministic finite state machines, non-deterministic finite state machines, Moore machines, Mealy machines, finite state transducers, and Markov chains.

The working programmer is unlikely to using formal methods and therefore doesn't need these fine distinctions. This allows a lot of simplification.


## The Programmer's View

From the working programmer's point of view we can say a finite state machine is something where we clearly 

- messages or actions that trigger processing
- state we need to compute response 

State can be structured.

- update state in response to action

Usually we'll have some output in addition to updated state.

`(S, I) => (S, O)`

Precise details don't matter. It's the conceptual clarity that is important. 

Being clear about: the state; how transitions between states happen.


## Job Scheduling

Example

- waiting, enqueued, running, cancelled, failed, complete


## User Interface


## Art

Casey Reas
