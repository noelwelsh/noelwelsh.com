+++
title = "Functional Design: Principles"
draft = true
+++

I want to write a bit about designing software in a functional programming style. There are many places to learn the machinery of functional programming---composing first-class functions, using algebraic data types, and so on---but vastly fewer to learn how to put it all together in larger systems. This post, which may become a series, is step to rectifying that.

In this post I want to go over what I see as the core principles of functional design. We need principles to guide design; when we face a design decision our principles to help us choose between alternatives. In many ways principles codify "good taste", in the same way that graphic design principles such as contrast and hierarchy encode an aesthetic for visual design. One notable difference from design principles in other fields is that in functional programming we can formalize many of these concepts.


## The Core Principle

The principle that I think represents the core goal of functional programming is that it should be possible to understand what a program does before it is run. This may be a surprising statement---surely this is the case for all programs?---but in functional programming this is a primary concern and it effects all aspects of program and language design. For example, reflection or even modifying code at runtime is very common in other languages communities (for example, "monkey patching" in Ruby, dynamic code loading in Javascript, and the many uses and abuses of reflection in Java) but in functional programming it is strongly discouraged. 

In functional programming this concept is formalized as *local reasoning*. Local reasoning means that we can understand a piece of code purely by looking at that piece of code; no other bits of code can change what it does.

Substitution. 

Side effects.


## Composition

*Composition* 


## Types


## Caveats

Limits of the system

Limits of the model

Not all functional programmers


## Conclusions

Hypothesis
