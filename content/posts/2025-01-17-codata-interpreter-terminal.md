+++
title = "Designing a DSL for Terminal Interaction"
+++

This is a case study of building a DSL for terminal interaction. We're using the terminal as motivation: terminal based programs are a good choice for developer oriented tools and recently there has been a resurgence of interest in toolkits for [terminal user interfaces][tui][^tuis]. In terms of programming techniques, the focus is on codata interpreters, and monads as a form of composition. 

<!-- more -->

This post is a draft of material that will be in [Functional Programming Strategies][fps], and I'm assuming some familiarity with codata, interpreters, monads, and so on. If you're not familiar with these terms you can find detailed explanations in [the book][fps]. However, here's a quick explainer:

* Codata is fancy programming language theory speak for "object oriented". If you've ever programmed against an interface you'll find this fairly straightforward.
* Interpreters come about because we want a separation between description and action, which in turn makes it easier to reason about effectful code. 
In addition to the book, I've [blogged about this before.][direct-style]
* Monads come about when we want to create a structure that represents doing a bunch of things in a defined sequence.

Alright, enough background. Let's get into it!


## The Terminal

The modern terminal is an accretion of features that started with the [VT-100][vt-100] in 1978 and continues [to this day][kitty-kp].
Most terminal features are accessed by reading and writing [ANSI escape codes][ansi-escape-code].
There are lots of them, and they aren't all well documented. 
In this case study we'll work just with codes that change the text style.
This allows us to produce interesting output with a minimum of unnecessary complexity.
If comprehensiveness is your interest, I've been working on a [library][terminus] that extends these ideas.

The code below all uses Scala 3. It is written so you can paste it into a file and run it with any recent version of Scala with just `scala <filename>`.
The examples should work with any terminal from the last 40 odd years.
If you're on Windows you can use Windows Terminal, [WSL][wsl], or another terminal that runs on Windows such as [WezTerm][wezterm].


## Color Codes

To start we will write some color codes straight to the terminal.
This will introduce us to mucking around with the terminal, and show some of the problems with using ANSI escape codes directly.

```scala
val csiString = "\u001b["

def printRed(): Unit =
  print(csiString)
  print("31")
  print("m")

def printReset(): Unit =
  print(csiString)
  print("0")
  print("m")

@main def go(): Unit =
  print("Normal text, ")
  printRed()
  print("now red text, ")
  printReset()
  println("and now back to normal.")
```

Try running the above code (e.g. save it to a file `ColorCodes.scala` and run `scala ColorCodes.scala`.) 
You should see text in the normal style for your terminal, followed by text colored red, and then some more text in the normal style.
The change in color is controlled by sending the [escape codes][ansi-escape-code] to the terminal.
These are strings starting with `ESC` (which is the character `'\u001b'`) followed by `'['`.
This is the value in `csiString` (where CSI stands for Control Sequence Introducer).
The CSI is followed by a number indicating the text style to use, and ended with a `"m"`
The string `"\u001b[31m"` tells the terminal to set the text foreground color to red, and the 
string `"\u001b[0m"` tells the terminal to reset all text styling to the default.


## The Trouble with Escape Codes

Escape codes are simple for the terminal to process, but lack useful structure when generating them.
The code above shows one potential problem: we must remember to reset the color when we finish a run of text. This problem is no different to that of remembering to free memory once it has been allocated, and the long history of memory safety problems in C programs show us that we cannot expect to do this reliably. Luckily, we're unlikely to crash our program if we forget an escape code.

To solve this problem we might decide to write functions like `printRed` below, which prints a colored string and resets the styling afterwards.

```scala
val csiString = "\u001b["
val redCode = s"${csiString}31m"
val resetCode = s"${csiString}0m"

def printRed(output: String): Unit =
  print(redCode)
  print(output)
  print(resetCode)

@main def go(): Unit =
  print("Normal text, ")
  printRed("now red text, ")
  println("and now back to normal.")
```

Changing color is the not the only way that we can style terminal output. We can also, for example, turn text bold. Continuing the above design gives us the following.

```scala
val csiString = "\u001b["
val redCode = s"${csiString}31m"
val resetCode = s"${csiString}0m"
val boldOnCode = s"${csiString}1m"
val boldOffCode = s"${csiString}22m"

def printRed(output: String): Unit =
  print(redCode)
  print(output)
  print(resetCode)

def printBold(output: String): Unit =
  print(boldOnCode)
  print(output)
  print(boldOffCode)

@main def go(): Unit =
  print("Normal text, ")
  printRed("now red text, ")
  printBold("and now bold.\n")
```

This works, but what if we want text that is *both* red and bold? We cannot express this with our current design, without creating methods for every possible combination of styles. Concretely this means methods like

```scala
def printRedAndBold(output: String): Unit =
  print(redCode)
  print(boldOnCode)
  print(output)
  print(resetCode)
```


This is not feasible to implement for all possible combinations of styles. The root problem is that our design is not compositional: there is no way to build a combination of styles from smaller pieces.


## Programs and Interpreters

To solve our problem above we need `printRed` and `printBold` to accept not a `String` to print but a program to run. 
We don't need to know what these programs do; we just need a way to run them.
Then we set the style before we run the program and reset it after it has finished running.

How should we represent a program?
Avid readers of [Functional Programming Strategies][fps] will know there are two basic choices: data and codata.
We will choose codata and in particular functions, the simplest form of codata.
In the code below we use the type `Program[A]`, which is a function `() => A`.
With this choice the interpreter, which is the thing that runs programs, is just function application.
To make it clearer when we are running programs we have a method `run` that does just that.


```scala
type Program[A] = () => A

val csiString = "\u001b["
val redCode = s"${csiString}31m"
val resetCode = s"${csiString}0m"
val boldOnCode = s"${csiString}1m"
val boldOffCode = s"${csiString}22m"

def run[A](program: Program[A]): A = program()

def print(output: String): Program[Unit] =
  () => Console.print(output)

def printRed[A](output: Program[A]): Program[A] =
  () => {
    run(print(redCode))
    val result = run(output)
    run(print(resetCode))
    
    result
  }


def printBold[A](output: Program[A]): Program[A] = 
  () => {
    run(print(boldOnCode))
    val result = run(output)
    run(print(boldOffCode))
    
    result
  }


@main def go(): Unit =
  run(() => {
    run(print("Normal text, "))
    run(printRed(print("now red text, ")))
    run(printBold(print("and now bold ")))
    run(printBold(printRed(print("and now bold and red.\n"))))
  })
```

This works, for the example we have chosen, but there are two issues: composition and ergonomics.
That have a problem with composition is perhaps surprising, as that's the problem we set out to solve.
We have made the system compositional in some aspects, but there are still others that do not work correctly.
For example, take the following code:

```scala
run(printBold(() => {
  run(print("This should be bold, "))
  run(printBold(print("as should this ")))
  run(print("and this.\n"))
}))
```

We would expect output like 

**This should be bold, as should that and this**

but we get 

**This should be bold, as should this** and this. 

The inner call to `printBold` resets the bold styling when it finishes, which means the surrounding call to `printBold` does not have effect on latter statements.

The issue with ergonomics is that this code is tedious and error-prone to write. We have to pepper calls to `run` everywhere, and even in these small examples I found myself making mistakes. This is actually another failing of composition, because we don't have methods to combine together programs. For example, we don't have methods to say that the program above is the sequential composition of three sub-programs.

We can solve the first problem by keeping track of the state of the terminal. If `printBold` is called within a state that is already printing bold it should do nothing. This means the type of programs changes from `() => A` to `Terminal => A`, where `Terminal` holds the current state of the terminal.

To solve the second problem we're looking for a way to sequentially compose programs. Remember programs have type `Terminal => A` and pass around the state in `Terminal`. When you hear the phrase "sequentially compose", or see that type, your monad sense might start tingling. You are correct: this is an instance of the state monad. 

If we're using [Cats][cats] we can define

```scala
import cats.data.State
type Program[A] = State[Terminal, A]
```

assuming some suitable definition of `Terminal`. Let's use this definition for now, and focus on defining `Terminal`.

`Terminal` has two pieces of state: the current bold setting and the current color. (The real terminal has much more state, but these are representative and modelling additional state doesn't introduce any new concepts.) The bold setting can be simply a toggle that is either on or off, but when we come to implementation it will be easier to work with a counter that records the depth of the nesting. The current color must be a stack. We can nest color changes, and the color should change back to the surrounding color when a nested level exits. Concretely, we should be able to write code like

```scala
printBlue(.... printRed(...) ...)
```

and have output in blue or red as we would expect.

Given this we can define `Terminal` as

```scala
final case class Terminal(bold: Int, color: List[String]) {
  def boldOn: Terminal = this.copy(bold = bold + 1)
  def boldOff: Terminal = this.copy(bold = bold - 1)
  def pushColor(c: String): Terminal = this.copy(color = c :: color)
  // Only call this when we know there is at least one color on the stack
  def popColor: Terminal = this.copy(color = color.tail)
  def peekColor: Option[String] = this.color.headOption
}
```

where we use `List` to represent the stack of color codes. (We could also use a mutable stack, as working with the state monad ensures the state will be threaded through our program.) We've also defined some convenience methods to make working with the state easier.

With this in place we can write the rest of the code, which is shown below. Compared to the previous code I've shortened a few method names and abstracted the escape codes.

Once we have defined the structure of `Terminal`, the majority of the rest of the code is dealing with manipulating the `Terminal` state. Most of the methods on `Program` have a common structure that specifies a state change before and after the main program runs. Notice we don't need to implement combinators like `flatMap` because we get them from the `State` monad. This is one of the big benefits of reusing abstractions like monads: we get a full library of methods without doing additional work.

Remember this code can be directly executed by `scala`. Just copy it into a file (e.g. `Terminal.scala`) and run `scala Terminal.scala`. 

```scala
//> using dep org.typelevel::cats-core:2.12.0

import cats.data.State
import cats.syntax.all.*

object AnsiCodes {
  val csiString: String = "\u001b["

  def csi(arg: String, terminator: String): String =
    s"${csiString}${arg}${terminator}"

  // SGR stands for Select Graphic Rendition. 
  // All the codes that change formatting are SGR codes.
  def sgr(arg: String): String =
    csi(arg, "m")

  val reset: String = sgr("0")
  val boldOn: String = sgr("1")
  val boldOff: String = sgr("22")
  val red: String = sgr("31")
  val blue: String = sgr("34")
}

final case class Terminal(bold: Int, color: List[String]) {
  def boldOn: Terminal = this.copy(bold = bold + 1)
  def boldOff: Terminal = this.copy(bold = bold - 1)
  def pushColor(c: String): Terminal = this.copy(color = c :: color)
  // Only call this when we know there is at least one color on the stack
  def popColor: Terminal = this.copy(color = color.tail)
  def peekColor: Option[String] = this.color.headOption
}
object Terminal {
  val empty: Terminal = Terminal(0, List.empty)
}

type Program[A] = State[Terminal, A]
object Program {
  def print(output: String): Program[Unit] =
    State[Terminal, Unit](terminal => (terminal, Console.print(output)))

  def bold[A](program: Program[A]): Program[A] =
    for {
      _ <- State.modify[Terminal] { terminal =>
        if terminal.bold == 0 then Console.print(AnsiCodes.boldOn)
        terminal.boldOn
      }
      a <- program
      _ <- State.modify[Terminal] { terminal =>
        val newTerminal = terminal.boldOff
        if terminal.bold == 0 then Console.print(AnsiCodes.boldOff)
        newTerminal
      }
    } yield a

  // Helper to construct methods that deal with color
  def withColor[A](code: String)(program: Program[A]): Program[A] =
    for {
      _ <- State.modify[Terminal] { terminal =>
        Console.print(code)
        terminal.pushColor(code)
      }
      a <- program
      _ <- State.modify[Terminal] { terminal =>
        val newTerminal = terminal.popColor
        newTerminal.peekColor match {
          case None    => Console.print(AnsiCodes.reset)
          case Some(c) => Console.print(c)
        }
        newTerminal
      }
    } yield a

  def red[A](program: Program[A]): Program[A] =
    withColor(AnsiCodes.red)(program)

  def blue[A](program: Program[A]): Program[A] =
    withColor(AnsiCodes.blue)(program)

  def run[A](program: Program[A]): A =
    program.runA(Terminal.empty).value
}

@main def go(): Unit = {
  val program =
    Program.blue(
      Program.print("This is blue ") >>
        Program.red(Program.print("and this is red ")) >>
        Program.bold(Program.print("and this is blue and bold "))
    ) >>
      Program.print("and this is back to normal.\n")

  Program.run(program)
}

```


## Codata and Extensibility

At the start of this case study we made a seemingly arbitrary choice to use a codata interpreter. Let's now explore this choice and it's implications.

We described codata as programming to an interface. The interface for functions is essentially one method: the ability to apply them. This corresponds to the single interpretation we have for `Program`: run it and carry out the effects therein. If we wanted to have multiple interpretations (such as logging the `Terminal` state or saving the output to a buffer) we would need to have a richer interface. In Scala this would be a `trait` or `class` with more than one public method.

Keen reads of [Functional Programming Strategies][fps] will recall that data makes it easy to add new interpreters but hard to add new operations, while codata makes it easy to add new operations but hard to add new interpreters. We see that in action here. For example, it's trivial to add a new color combinator by defining a method like that below.

```scala
def green[A](program: Program[A]): Program[A] =
  withColor(AnsiCodes.sgr("32"))(program)
```

However, changing `Program` to something that allows more interpretations requires changing all of the existing code.

Another advantage of codata is that we can mix in arbitrary other Scala code. For example, we can use `map` like shown below.

```scala
Program.print("Hello").map(_ => 42)
```

Using the native representation of programs (i.e. functions) gives us the entire language for free. In a data representation we have to reify every kind of expression we wish to support. There is a downside to this as well: we get Scala semantics whether we like them or not. A codata representation would not appropriate if we wanted to make an exotic language that worked in a different way.

We could factor the interpreter in different ways, and it would still be a codata interpreter. For example, we could put a method to write to the terminal on the `Terminal` type. This would give us a bit more flexibility as changing the implementation of `Termainal` could, say, write to a network socket or a terminal embedded in a browser. We still have the limitation that we cannot create truly different interpretations, such as serializing programs to disk, with the codata approach.


## Composition and Reasoning

[I've argued before][fp] that the core of functional programming is reasoning and composition. Both of these are central to this case study. We've explicitly designed the DSL for ease of reasoning. Indeed that's the whole point of creating a DSL instead of just spitting control codes at the terminal. An example is how we paid attention to making sure nested calls work as we'd expect. Composition comes in at two levels. Our design is compositional, as mentioned above. Our implementation is also compositional: a `Program` is a the composition of the state monad and the functions inside the state monad. The state monad provides the sequential flow of the `Terminal` state, and the functions provide the domain specific actions.


## Conclusions

We've built what we set out to do: a DSL for terminal interaction. It is composable, meaning we can build larger programs out of smaller ones, and we gave it reasonable semantics, allowing stacked styles with effect that matches the program's nesting. We could do this fairly simply by composing a few building blocks: the state monad, functions, and a bit of domain specific knowledge about escape codes.

Take a look at [Terminus][terminus] if want you see these ideas in a larger system. Terminus is written in [direct-style][direct-style].  Conceptually it is the same as the case study. Implementationally, instead of using a monad to specify the control-flow we just use the Scala's control-flow. The characteristics of contextual functions allow us to pass around state without the programmer having to do it explicitly.

[^tuis]: If you're interested in [TUI][tui] libraries you might like to look at [ratatui](https://github.com/ratatui/ratatui) (GOAT tier project name, BTW) for Rust, [brick](https://github.com/jtdaugherty/brick) for Haskell, or [Textual](https://textual.textualize.io/) for Python.

[fps]: https://scalawithcats.com/
[direct-style]: @/posts/2024-04-24-direct-style.md
[vt-100]: https://en.wikipedia.org/wiki/VT100
[kitty-kp]: https://sw.kovidgoyal.net/kitty/keyboard-protocol/
[ansi-escape-code]: https://en.wikipedia.org/wiki/ANSI_escape_code
[terminus]: https://www.creativescala.org/terminus/
[wsl]: https://learn.microsoft.com/en-us/windows/wsl/about
[wezterm]: https://wezfurlong.org/wezterm/index.html
[cats]: https://typelevel.org/cats/
[tui]: https://en.wikipedia.org/wiki/Text-based_user_interface
[fp]: @/posts/2020-07-05-what-and-why-fp.md
