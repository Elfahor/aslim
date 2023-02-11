let build_ast_of_lexbuf lexbuf =
  Parser.main (Epl_lexer.epl_token) lexbuf;;

let build_ast_of_string str =
  build_ast_of_lexbuf (Lexing.from_string str);;

let interpret_single_expr (code: string) =
  Interpreter.interpret_expr (build_ast_of_string code)
