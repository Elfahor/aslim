# ASLIM
A Shitty Language I Made

This is a toy programming language I made to learn about parsing, interpretation, and (eventually, I haven't got into that yet) compilation.

It currently has a simple REPL and is able to interpret files (usually with the .asli extension)

Example session:
```
> let $x 5
> fun incr $a (add $a 1)
> incr $x
int: 6
> 
```
You might also want to check out the [examples](examples/)

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
