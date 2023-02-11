type value =
  | Int of int
  | Bool of bool
  | String of string
type exprRet =
  | Explicit of value
  | Unit
val interpret_expr : Ast.t -> exprRet

exception Invalid_sequence
exception Unit_assignment of string
exception Undeclared_identifier of string
