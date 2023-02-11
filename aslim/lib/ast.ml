type t =
  | Int of int
  | String of string
  | Ident of string
  | VarDecl of string * t
  | FunDecl of string * string list * t
  | Application of string * t list
  
