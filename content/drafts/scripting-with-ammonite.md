# Scripting with Ammonite

## Installation

`brew install ammonite-repl`

## Scripting

Ammonite can watch files. This is amazing. (Different workflows.)

`amm --watch <file.sc>`


Imports

```scala
$file.<dir>.<FileName> // file name without .sc extension
$ivy.`org::library:version` // Maven Central dependency
```


## Paths

`wd/<segement>/<segment>` where `<segment>` is a `String`


## File Manipulation

`mv`, `rm!`, `cp` etc.

No globbing.


## Subprocesses

Just use `scala.sys.process._`. The functions? syntax? that Ammonite provides (% and %%) is poorly documented.
