# ASLIM ""specification""

An ASLIM program consists of expressions.

An expression can have two types: Unit and Explicit.
A Unit expression has side effects: for instance variable declaration.
An Explicit expression can be operated on in further transformations. It can be an
integer, a float, a string or a boolean.

It is also possible to handle linked lists, which are immutable.

Legal expressions:
  * Variable names are of the form $[a-z A-Z]* (referred to as `<varident>`).
  * Function names are of the form [a-z A-Z]* (referred to as `<funident>`).
  * A variable is introduced as `let <varident> <expr>`.
  * A function is introduced as `fun <funident> <params> <expr>`
    where `<params>` means a whitespace separated `<varident>` list.
  * A function is applied to arguments as `<funident> <arguments>`
    where `<arguments>` means a whitespace separated `<expr>` list to be substitued.
    Evaluation is strict.

# Builtins

A few builtin functions are provided:
  * `add <int> <int>` returns $1 + $2. It also works for strings and lists.
  * `cmp <expr> <expr>` compares $1 and $2, which can be of any type,
    except Unit. It returns:
      * -1 if $1 < $2
      * 0 if $1 = $2
      * 1 if $1 > $2
  * `eq`, `le`, `ge`, `lt`, `gt` are used for comparison.
  * `ignore <expr>` does nothing and returns Unit.
  * `print <expr>` prints its argument.
  * `input <params>`returns a string taken from stdin. The argument is not used.
    Ideally it should take Unit, or be a special sort of variable. But the current
    implementation does not permit that and it would need to be added as a keyword, 
    which I don't want.
  * `li <params>` returns a linked list composed of the whitespace sperated parameters.
  * `cons <expr> <expr>` returns a new list consisting of $1 prepended to $2.
  * And others. This is not kept in sync with the actual code.
    Best is to check [the interpreter's code](/aslim/lib/interpreter.ml#L26)

# Control flow

Expressions can be written sequentially like so:
```
(<expr>;<expr>;...)
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
