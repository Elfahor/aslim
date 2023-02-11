let build_ast_of_lexbuf lexbuf =
  Parser.main (Epl_lexer.epl_token) lexbuf;;

let interpret_single_expr (code: string) =
  Lexing.from_string code
  |> build_ast_of_lexbuf
  |> Interpreter.interpret_expr 

let interpret_file (file: in_channel) =
  Lexing.from_channel file
  |> build_ast_of_lexbuf
  |> Interpreter.interpret_expr
  |> ignore
