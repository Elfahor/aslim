type t =
  | Seq of t list
  | Int of int
  | String of string
  | Float of float
  | Ident of string
  | VarDecl of string * t
  | FunDecl of string * string list * t
  | Application of string * t list
  | If of t * t * t
  
