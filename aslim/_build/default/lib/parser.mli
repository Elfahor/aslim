type token =
  | Int of (int)
  | String of (string)
  | FIdent of (string)
  | VIdent of (string)
  | KwLet
  | KwFun
  | EOL
  | LParen
  | RParen

val main :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.t
