%token <int> Int
%token <float> Float
%token <string> String
%token <string> FIdent
%token <string> VIdent
%token KwLet KwFun KwIf
%token EOL
%token LParen RParen Sep
%start main
%type <Ast.t> main

%%

main: expr EOL { $1 }

expr:
  | LParen expr RParen  { $2 }
  | Int { Int ($startpos, $1) }
  | String { String ($startpos, $1) }
  | Float { Float ($startpos, $1) }
  | KwIf LParen expr RParen LParen expr RParen LParen expr RParen { If ($startpos, $3, $6, $9) }
  | KwLet VIdent expr { VarDecl ($startpos, $2, $3) }
  | KwFun FIdent params expr { FunDecl ($startpos, $2, $3, $4) }
  | VIdent { Ident ($startpos, $1) }
  | FIdent arguments { Application ($startpos, $1, $2) }
  | LParen seq RParen { Seq ($startpos, $2) }

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
  | expr { [$1] }
  | expr Sep seq { $1 :: $3 }
