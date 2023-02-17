open Globals

type identifier = string
module IdentMap = Map.Make (String)
type funParams = identifier list
type funDecl = Ast.t * funParams
type varTable = value IdentMap.t
type funTable = funDecl IdentMap.t
type stack_trace = identifier list
type builtin = (stack_trace * value list) -> exprRet
type context = { 
  mutable vars: varTable;
  mutable funs: funTable;
  mutable rec_depth: int;
  mutable stack_trace: stack_trace
}

exception Type_error of stack_trace
exception Invalid_sequence of stack_trace
exception Undeclared_identifier of stack_trace
exception Arity_error of stack_trace
exception Recursion_error of stack_trace
exception User_exn of string * stack_trace

(* builtin functions *)
let (builtins : builtin IdentMap.t) =
  [ 
    ("add", fun (s, p) -> match p with
      | [Int x; Int y] -> Explicit (Int (x + y))
      | [String s1; String s2] -> Explicit (String (s1 ^ s2))
      | [Float x; Float y] -> Explicit (Float (x +. y))
      | [List l1; List l2] -> Explicit (List (l1 @ l2))
      | [Int x; Float y] -> Explicit (Float (float_of_int x +. y))
      | [Float x; Int y] -> Explicit (Float (x +. float_of_int y))
      | [_; _] -> raise (Type_error s)
      | _ -> raise (Arity_error s)
    );
    ("print", fun (s,p) -> 
      let rec print_sl (params : value list) =
        match params with
        | [] -> print_endline ""
        | h::t ->
            Utils.print_poly h;
            print_sl t;
      in print_sl p; Unit
    );
    ("cmp", fun (s, p) -> match p with
      | [Int x; Int y] -> Explicit (Int (compare x y))
      | [String s1; String s2] -> Explicit(Int (compare s1 s2))
      | [Bool b1; Bool b2] -> Explicit (Int (compare b1 b2))
      | [_; _] -> raise (Type_error s)
      | _ -> raise (Arity_error s)
    );
    ("ignore", fun x -> ignore x; Unit);
    ("eq", fun (s,p) ->
      let rec all_eq x = function
      | [] -> true
      | h::t -> h = x && all_eq x t in
      let rec eq_all = function
      | [] -> false
      | h::t -> all_eq h t
      in Explicit (Bool (eq_all p))
    );
    ("li", fun (s,p) -> Explicit (List p));
    ("cons", fun (s, p) -> match p with
      | [x; List l] -> Explicit (List (x::l))
      | [_; _] -> raise (Type_error s)
      | _ -> raise (Arity_error s)
    );
    ("hd", fun (s, p) -> match p with
      | [List []] -> raise (Invalid_argument "hd on empty list")
      | [List (h::t)] -> Explicit h
      | [_] -> raise (Type_error s)
      | _ -> raise (Arity_error s)
    );
    ("tl", fun (s, p) -> match p with
      | [List []] -> raise (Invalid_argument "tl on empty list")
      | [List (h::t)] -> Explicit (List t)
      | [_] -> raise (Type_error s)
      | _ -> raise (Arity_error s)
    );
    ("exn", fun (s, p) -> match p with
      | [String s2] -> raise (User_exn (s2, s))
      | [_] -> raise (Type_error s)
      | _ -> raise (Arity_error s)
    )
  ] 
  |> List.to_seq
  |> IdentMap.of_seq

let (consts : value IdentMap.t) =
  [ "nil",   List []
  ; "true",  Bool true
  ; "false", Bool false]
  |> List.to_seq
  |> IdentMap.of_seq

let (emptyContext : context) = {vars = consts; funs = IdentMap.empty; rec_depth = 0; stack_trace = []}

(* declare a variable *)
let rec declareVar (name : identifier) (value : Ast.t) (context : context) : exprRet =
  let v = interpret_expr_ctx value context in
  (match v with 
  | Explicit v -> context.vars <- IdentMap.add name v context.vars
  | Unit -> raise (Type_error context.stack_trace));
  Unit

(* declare a function *)
and declareFun (name : identifier) (params : funParams) (body : Ast.t) (context : context) : exprRet =
  context.funs <- IdentMap.add name (body, params) context.funs;
  Unit

(* apply a function *)
and applyFun (name : identifier) (paramExprs : Ast.t list) (context : context) : exprRet =
  if context.rec_depth >= 1000
  then raise (Recursion_error context.stack_trace)
  else
  match IdentMap.find_opt name builtins with
  (* if it isn't a builtin *)
  | None -> begin
    let f, parNames = begin 
      match IdentMap.find_opt name context.funs with
      | None -> raise (Undeclared_identifier context.stack_trace)
      | Some x -> x
    end in
    let parNames = List.to_seq parNames in
    (* evaluate each param (strict)*)
    let paramVals = List.map (fun e ->
      match interpret_expr_ctx e context with
      | Explicit v -> v
    (*TODO Better error msg *)
      | Unit -> raise (Type_error (context.stack_trace)))
    paramExprs |> List.to_seq in
    let ctxVars = IdentMap.add_seq (Seq.zip parNames paramVals) context.vars in
    interpret_expr_ctx f {
      vars = ctxVars;
      funs = context.funs;
      rec_depth = context.rec_depth + 1;
      stack_trace = name::context.stack_trace
    }
    end
  (* if it is builtin *)
  | Some f -> f (context.stack_trace, (
    List.map (fun e ->
      match interpret_expr_ctx e context with
      | Unit -> raise (Type_error context.stack_trace)
      | Explicit v -> v)
    paramExprs))

and conditionnal (cond : Ast.t) (thenExpr : Ast.t) (elseExpr : Ast.t) context =
  match interpret_expr_ctx cond context with
  | Explicit (Bool s) ->
      if s
      then interpret_expr_ctx thenExpr context
      else interpret_expr_ctx elseExpr context
  | _ -> raise (Type_error context.stack_trace)

and interpret_expr_ctx (ast: Ast.t) (context : context) : exprRet =
   match ast with
  | Ast.Seq l -> let rec aux l =
    begin match l with
    | [] -> raise (Invalid_sequence context.stack_trace)
    | [e] -> interpret_expr_ctx e context
    | e1::t -> begin
      match interpret_expr_ctx e1 context with
      | Unit -> aux t
      | Explicit _ -> raise (Invalid_sequence context.stack_trace)
      end 
    end 
    in aux l
  | Ast.Int x -> Explicit (Int x)
  | Ast.String s -> Explicit (String s)
  | Ast.Float f -> Explicit (Float f)
  | Ast.Ident v -> Explicit ( 
    match IdentMap.find_opt v context.vars with
    | None -> raise (Undeclared_identifier context.stack_trace)
    | Some x -> x)
  | Ast.VarDecl (x, e) ->
      declareVar x e context
  | Ast.FunDecl (name, params, ret) -> 
      declareFun name params ret context
  | Ast.Application (name, paramExprs) ->
      applyFun name paramExprs context
  | Ast.If (cond, thenExpr, elseExpr) ->
    conditionnal cond thenExpr elseExpr context
  

(* top level interpretation starting from an emptyContext *)
let interpret_expr (ast : Ast.t) : exprRet = 
  try interpret_expr_ctx ast emptyContext
  with 
  | Invalid_sequence s ->
      print_endline "Invalid sequence"; 
      Utils.print_stack_trace s;
      Globals.Unit
  | Type_error s ->
      print_endline ("Type error: "); 
      Utils.print_stack_trace s;
      Globals.Unit
  | Recursion_error s ->
      print_endline ("Recursion error:");
      Utils.print_stack_trace s;
      Unit
  | Undeclared_identifier s ->
      print_endline ("Undeclared identifier:");
      Utils.print_stack_trace s;
      Unit
  | User_exn (message, s) ->
      Printf.printf "Exception: %s\n" message;
      Utils.print_stack_trace s;
      Unit
