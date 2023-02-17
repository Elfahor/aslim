val interpret_expr : Ast.t -> Globals.exprRet

type identifier = string
type stack_trace = identifier list
exception Type_error of stack_trace
exception Invalid_sequence of stack_trace
exception Undeclared_identifier of stack_trace
exception Arity_error of stack_trace
exception Recursion_error of stack_trace
exception User_exn of string * stack_trace
