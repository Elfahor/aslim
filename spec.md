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
  * `add <int> <int>` returns $1 + $2.
    `add <str> <str>` returns the concatenation of $1 and $2.
  * `cmp <expr> <expr>` compares $1 and $2, which can be of any type,
    except Unit. It returns:
      * -1 if $1 < $2
      * 0 if $1 = $2
      * 1 if $1 > $2
  * `print <expr>` prints its argument.
  * `eq <expr> <expr>` returns true if $1 = $2
  * `ignore <expr>` does nothing and returns Unit.

# Control flow

Expressions can be written sequentially like so:
```
(<expr>) <expr>
```
The parentheses are MANDATORY.

An `if` expression is provided:
```
if (<expr>) (<expr>) (<expr>)
```
It returns $2 if $1 evaluates to true, $3 otherwise. Again,
parentheses are mandatory.
Evaluation is lazy, which is why this is provided as a
keyword and not as a language builtin.
