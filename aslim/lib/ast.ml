type loc = Lexing.position
type t =
  | Seq of loc * t list
  | Int of loc * int
  | String of loc * string
  | Float of loc * float
  | Ident of loc * string
  | VarDecl of loc * string * t
  | FunDecl of loc * string * string list * t
  | Application of loc * string * t list
  | If of loc * t * t * t
