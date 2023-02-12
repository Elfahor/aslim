val interpret_expr : Ast.t -> Globals.exprRet

exception Invalid_sequence
exception Type_error of string
exception Undeclared_identifier of string
exception Recursion_error of string
