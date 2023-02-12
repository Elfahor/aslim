%token <int> Int
%token <float> Float
%token <string> String
%token <string> FIdent
%token <string> VIdent
%token KwLet KwFun KwIf
%token EOL
%token LParen RParen
%left FIdent
%start main
%type <Ast.t> main

%%

main: expr EOL { $1 }

expr:
  | LParen expr RParen  { $2 }
  | Int { Int $1 }
  | String { String $1 }
  | Float { Float $1 }
  | KwIf LParen expr RParen LParen expr RParen LParen expr RParen { If($3, $6, $9) }
  | KwLet VIdent expr { VarDecl($2, $3) }
  | KwFun FIdent params expr { FunDecl($2, $3, $4) }
  | VIdent { Ident $1 }
  | FIdent arguments { Application ($1, $2) }
  | seq { Seq ($1) }

arguments:
  | argument { [$1] }
  | argument arguments { $1 :: $2 }
argument:
  | expr { $1 }

params:
  | param { [$1] }
  | param params { $1 :: $2 }
param:
  | VIdent { $1 }

seq:
  | LParen expr RParen { [$2] }
  | LParen expr RParen seq { $2 :: $4 }
