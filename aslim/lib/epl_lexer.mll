{
  open Parser
}
rule epl_token = parse
  | [' ' '\t'] { epl_token lexbuf }
  | eof { EOL }
  | ['\n'] { EOL }
  | "let" { KwLet }
  | "fun" { KwFun }
  | ['0'-'9']* as word { Int(int_of_string word) }
  | '"'(['a'-'z' 'A'-'Z']* as word)'"' { String(word) }
  | '_'(['a'-'z' 'A'-'Z']* as word) { VIdent(word) }
  | ['a'-'z' 'A'-'Z']* as word { FIdent(word) }
  | '(' { LParen }
  | ')' { RParen }

