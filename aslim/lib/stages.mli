val interpret_file : in_channel -> unit
val interpret_single_expr : string -> Globals.exprRet
val build_ast_of_lexbuf : Lexing.lexbuf -> Ast.t
