# ASLIM
A Shitty Language I Made

This is a simple programming language I made to learn about parsing, interpretation, and (eventually, I haven't got into that yet) compilation.

It currently has a simple REPL and is able to interpret files (usually with the .asli extension)

Example session:
```
> let _x 5
> fun incr _a (add _a 1)
> incr _x
int: 6
> 
```
You might also want to check out the [example](example.asli)

The language [specification](spec.md) is available.

# Usage
Build dependencies:
  * A reasonably up-to-date OCaml tool chain
  * The [dune](https://dune.build/) build system
  * GNU Make

```
git clone https://github.com/Elfahor/aslim.git
cd aslim
make
```
Output will be placed in `build`.

Interpret a file:
```
aslim myfile.asli
```
Start an interactive session:
```
aslim -i
```
