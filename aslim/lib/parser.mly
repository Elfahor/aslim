%token <int> Int
%token <string> String
%token <string> FIdent
%token <string> VIdent
%token KwLet KwFun
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
  | KwLet VIdent expr { VarDecl($2, $3) }
  | KwFun FIdent params expr { FunDecl($2, $3, $4) }
  | VIdent { Ident $1 }
  | FIdent arguments { Application ($1, $2) }
  | LParen expr RParen expr { Seq ($2, $4) }

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
