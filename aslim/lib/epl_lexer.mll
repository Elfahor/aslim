{
  open Parser
  exception Invalid_token
}
rule epl_token = parse
  | [' ' '\t'] { epl_token lexbuf }
  | ['\n'] { epl_token lexbuf }
  | eof { EOL }
  | "let" { KwLet }
  | "fun" { KwFun }
  | "if" { KwIf }
  | '-'?['0'-'9']+ as word { Int(int_of_string word) }
  | '-'?['0'-'9']* '.' ['0'-'9']+  as word { Float(float_of_string word)}
  | '"' ([^ '\n' '"']* as word) '"' { String(word) }
  | '$'(['a'-'z' 'A'-'Z']* as word) { VIdent(word) }
  | ['a'-'z' 'A'-'Z']+ as word { FIdent(word) }
  | '(' { LParen }
  | ')' { RParen }
  | ';' { Sep }
  | '#' [^ '\n']* {epl_token lexbuf}
  | _ { raise Invalid_token }

