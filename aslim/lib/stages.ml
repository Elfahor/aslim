let build_ast_of_lexbuf lexbuf =
  Parser.main (Epl_lexer.epl_token) lexbuf

let interpret_single_expr (code: string) =
  try Lexing.from_string code
  |> build_ast_of_lexbuf
  |> Interpreter.interpret_expr 
  with
  | Epl_lexer.Invalid_token ->
      print_endline "Invalid token."; 
      Globals.Unit
  | Parsing.Parse_error -> 
      print_endline "Ill-formed expression."; 
      Globals.Unit

let interpret_file (file: in_channel) =
  try Lexing.from_channel file
  |> build_ast_of_lexbuf
  |> Interpreter.interpret_expr
  |> ignore
  with
  | Epl_lexer.Invalid_token ->
      print_endline "Invalid token. Aborting"; 
  | Parsing.Parse_error -> 
      print_endline "Ill-formed expression. Aborting"; 
