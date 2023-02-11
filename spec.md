# ASLIM ""specification""

An ASLIM program consists of expressions.

An expression can have two types: Unit and Explicit.
A Unit expression has side effects: for instance variable declaration.
An Explicit expression can be operated on in further transformations. It can be an
integer, a string or a boolean.

Legal expressions:
  * Variable names are of the form _[a-z A-Z]* (referred to as `<varident>`).
  * Function names are of the form [a-z A-Z]* (referred to as `<funident>`).
  * A variable is introduced as `let <varident> <expr>`.
  * A function is introduced as `fun <funident> <params> <expr>`
    where `<params>` means a whitespace separated `<varident>` list.
  * A function is applied to arguments as `<funident> <arguments>`
    where `<arguments>` means a whitespace separated `<expr>` list to be substitued.
    Evaluation is strict.

# Builtins

A few builtin functions are provided:
`add <int> <int>` returns $1 + $2.
`add <str> <str>` returns the concatenation of $1 and $2
