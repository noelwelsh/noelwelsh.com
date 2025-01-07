+++
title = "Designing a DSL for Terminal Interaction"
draft = true
+++

This article is about designing a DSL for terminal interaction. The terminal itself is easy to work with, for the most part, though more accreted than designed.

Terminal GUIs are good tools for developer oriented tools.

For me it was interesting to learn about the details.

I also wanted a compelling example of a codata interpreter for [the book][fps].

There are two parts to this: codata and interpreters. Let's quickly sketch each.
Codata is fancy programming language theory speak for "object oriented". 
There is more [in the book][fps] but if you've ever programmed against an interface you'll find this fairly straightforward.
Interpreters come about because we want a separation between description and action, which in turn makes it easier to reason about effectful code. 
I've [blogged about this][direct-style] or there's more [in the book][fps].


## The Terminal

The terminal is an accretion of features that got going with the [VT-100][vt-100] in 1978 and continues [to this day][kitty-kp].
Most terminal features are accessed by reading and writing [ANSI escape codes][ansi-escape-code].
There are lots of them, and they aren't all well documented, but we'll keep it simple as we're aiming for an illustrative example not a comprehensive solution.
Concretely, we'll just work with the ANSI color codes, which produce interesting output and are well documented.
If comprehensiveness is your interest, I've been working on a [library][terminus] that extends these ideas.

The code below all uses Scala 3, and is written in such a way you can cut and paste it into a file and run it directly with any recent version of Scala with just `scala <filename>`.
The examples should work with any terminal from the last 40 odd years.
If you're on Windows you can use [WSL][wsl] or a terminal that runs on Windows such as [WezTerm][wezterm].


## Color Codes

To start we will write some color codes directly to the terminal.
This will get us started with mucking around the terminal and show some of the problems with using ANSI escape codes directly.

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
The change is color is controlled by sending [escape codes][ansi-escape-code] to the terminal.
These are just strings starting with `ESC` (which is the character `'\u001b'`) and then `'['`.
This is the value in `csiString` (where CSI stands for Control Sequence Introducer).
The string `"\u001b[31m"` tells the terminal to set the text foreground color to red, and the 
string `"\u001b[0m"` tells the terminal to reset all text styling to the default.


## The Trouble with Escape Codes

The design of escape codes makes them very simple to work with for the terminal that is reading them, but it doesn't make them very simple to work with in larger applications that are generating them. The code above shows one potential problem: we must remember to reset the color when we finish a run of text. This problem is no different to that of remembering to free memory once it has been allocated, and the long history of memory safety problems in C programs show us that we cannot expect to do this reliably. We shouldn't expect to do any better with escape codes.

To solve this problem we might decide to write functions like `printRed` below, which prints a colored string.

```scala
val csiString = "\u001b["
val redCode = s"${csiString}31m"
val resetCode = s"${csiString}0m"

def printRed(output: String): Unit = {
  print(redCode)
  print(output)
  print(resetCode)
}

@main def go(): Unit =
  print("Normal text, ")
  printRed("now red text, ")
  println("and now back to normal.")
```

This is better, but it is not compositional. Changing color is the not the only way that we can style output on the terminal. We can also, for example, turn text bold. If we continue the above design we get code like the following.

```scala
val csiString = "\u001b["
val redCode = s"${csiString}31m"
val resetCode = s"${csiString}0m"
val boldOnCode = s"${csiString}1m"
val boldOffCode = s"${csiString}22m"

def printRed(output: String): Unit = {
  print(redCode)
  print(output)
  print(resetCode)
}

def printBold(output: String): Unit = {
  print(boldOnCode)
  print(output)
  print(boldOffCode)
}

@main def go(): Unit =
  print("Normal text, ")
  printRed("now red text, ")
  printBold("and now bold.\n")
```

This works, but what if we want text that is *both* red and bold? We cannot express this with our current design.


## Programs and Interpreters

To solve our problem above we need `printRed` and `printBold` to accept not a `String` to print but a program to run. 
We assume this program is going to do something with the terminal, but we don't need to know what.
All we need is a way to run these programs.
Then we send the appropriate codes before we run the program and after it has finished running.

How should we represent a program?
Avid readers of [Functional Programming Strategies][fps] will know there are two basic choices: data and codata.
We will choose codata, and in particular the simplest form of codata which is just a function.
In the code below we use the type `Program[A]`, which is a function `() => A`.
We this choice, the interpreter, which is the thing that runs programs, is just function application.
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
  () => scala.Console.print(output)

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



## Building an Interpreter


[fps]: https://scalawithcats.com/
[direct-style]: https://noelwelsh.com/posts/direct-style/
[vt-100]: https://en.wikipedia.org/wiki/VT100
[kitty-kp]: https://sw.kovidgoyal.net/kitty/keyboard-protocol/
[ansi-escape-code]: https://en.wikipedia.org/wiki/ANSI_escape_code
[terminus]: https://github.com/creativescala/terminus/
[wsl]: https://learn.microsoft.com/en-us/windows/wsl/about
[wezterm]: https://wezfurlong.org/wezterm/index.html
