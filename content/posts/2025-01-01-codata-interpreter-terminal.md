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
  println("and now back to normal")
```

Try running the above code (e.g. save it to a file `ColorCodes.scala` and run `scala ColorCodes.scala`.) 
You should see text in the normal style for your terminal, followed by text colored red, and then some more text in the normal style.
The change is color is controlled by sending [escape codes][ansi-escape-code] to the terminal.
These are just strings starting with `ESC` (which is the character `'\u001b'`) and then `'['`.
This is the value in `csiString` (where CSI stands for Control Sequence Introducer).
The string `"\u001b[31m"` tells the terminal to set the text foreground color to red, and the 
string `"\u001b[0m"` tells the terminal to reset all text styling to the default.


## Building an Interpreter


[fps]: https://scalawithcats.com/
[direct-style]: https://noelwelsh.com/posts/direct-style/
[vt-100]: https://en.wikipedia.org/wiki/VT100
[kitty-kp]: https://sw.kovidgoyal.net/kitty/keyboard-protocol/
[ansi-escape-code]: https://en.wikipedia.org/wiki/ANSI_escape_code
[terminus]: https://github.com/creativescala/terminus/
[wsl]: https://learn.microsoft.com/en-us/windows/wsl/about
[wezterm]: https://wezfurlong.org/wezterm/index.html
