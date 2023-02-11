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

open Parsing;;
let _ = parse_error;;
let yytransl_const = [|
  261 (* KwLet *);
  262 (* KwFun *);
  263 (* EOL *);
  264 (* LParen *);
  265 (* RParen *);
    0|]

let yytransl_block = [|
  257 (* Int *);
  258 (* String *);
  259 (* FIdent *);
  260 (* VIdent *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
\004\000\004\000\005\000\003\000\003\000\006\000\000\000"

let yylen = "\002\000\
\002\000\003\000\001\000\001\000\003\000\004\000\001\000\002\000\
\001\000\002\000\001\000\001\000\002\000\001\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\003\000\004\000\000\000\007\000\000\000\000\000\
\000\000\015\000\000\000\011\000\008\000\000\000\000\000\000\000\
\000\000\001\000\010\000\005\000\014\000\000\000\000\000\002\000\
\006\000\013\000"

let yydgoto = "\002\000\
\010\000\012\000\022\000\013\000\014\000\023\000"

let yysindex = "\009\000\
\001\255\000\000\000\000\000\000\001\255\000\000\253\254\014\255\
\001\255\000\000\012\255\000\000\000\000\001\255\001\255\019\255\
\015\255\000\000\000\000\000\000\000\000\001\255\019\255\000\000\
\000\000\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\013\255\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\010\255\000\000\
\000\000\000\000"

let yygindex = "\000\000\
\000\000\255\255\002\000\012\000\000\000\000\000"

let yytablesize = 26
let yytable = "\011\000\
\015\000\003\000\004\000\005\000\006\000\007\000\008\000\017\000\
\009\000\001\000\012\000\012\000\012\000\020\000\012\000\012\000\
\016\000\012\000\018\000\009\000\025\000\009\000\021\000\024\000\
\026\000\019\000"

let yycheck = "\001\000\
\004\001\001\001\002\001\003\001\004\001\005\001\006\001\009\000\
\008\001\001\000\001\001\002\001\003\001\015\000\005\001\006\001\
\003\001\008\001\007\001\007\001\022\000\009\001\004\001\009\001\
\023\000\014\000"

let yynames_const = "\
  KwLet\000\
  KwFun\000\
  EOL\000\
  LParen\000\
  RParen\000\
  "

let yynames_block = "\
  Int\000\
  String\000\
  FIdent\000\
  VIdent\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 14 "lib/parser.mly"
               ( _1 )
# 97 "lib/parser.ml"
               : Ast.t))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 17 "lib/parser.mly"
                        ( _2 )
# 104 "lib/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 18 "lib/parser.mly"
        ( Int _1 )
# 111 "lib/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 19 "lib/parser.mly"
           ( String _1 )
# 118 "lib/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 20 "lib/parser.mly"
                      ( VarDecl(_2, _3) )
# 126 "lib/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'params) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 21 "lib/parser.mly"
                             ( FunDecl(_2, _3, _4) )
# 135 "lib/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 22 "lib/parser.mly"
           ( Ident _1 )
# 142 "lib/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'arguments) in
    Obj.repr(
# 23 "lib/parser.mly"
                     ( Application (_1, _2) )
# 150 "lib/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'argument) in
    Obj.repr(
# 26 "lib/parser.mly"
             ( [_1] )
# 157 "lib/parser.ml"
               : 'arguments))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'argument) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'arguments) in
    Obj.repr(
# 27 "lib/parser.mly"
                       ( _1 :: _2 )
# 165 "lib/parser.ml"
               : 'arguments))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 29 "lib/parser.mly"
         ( _1 )
# 172 "lib/parser.ml"
               : 'argument))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'param) in
    Obj.repr(
# 32 "lib/parser.mly"
          ( [_1] )
# 179 "lib/parser.ml"
               : 'params))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'param) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'params) in
    Obj.repr(
# 33 "lib/parser.mly"
                 ( _1 :: _2 )
# 187 "lib/parser.ml"
               : 'params))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 35 "lib/parser.mly"
           ( _1 )
# 194 "lib/parser.ml"
               : 'param))
(* Entry main *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let main (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Ast.t)
