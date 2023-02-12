open Globals

type builtin = value list -> exprRet
type identifier = string
module IdentMap = Map.Make (String)
type funParams = identifier list
type funDecl = Ast.t * funParams
type varTable = value IdentMap.t
type funTable = funDecl IdentMap.t
type context = { mutable vars: varTable; mutable funs: funTable; mutable recDepth: int }

exception Type_error of string
(* let assignment_error (x : identifier) = *)
(*   ["error:"; x; "assignment returned unit"]  *)
(*   |> String.concat " "  *)
(*   |> fun s -> raise (Type_error s) *)

exception Invalid_sequence
exception Undeclared_identifier of identifier
exception Arity_error of identifier
exception Recursion_error of identifier

(* builtin functions *)
let (builtins : builtin IdentMap.t) =
  [ 
    ("add", function
      | [Int x; Int y] -> Explicit (Int (x + y))
      | [String s1; String s2] -> Explicit (String (s1 ^ s2))
      | [Float x; Float y] -> Explicit (Float (x +. y))
      | [List l1; List l2] -> Explicit (List (l1 @ l2))
      | [Int x; Float y] -> Explicit (Float (float_of_int x +. y))
      | [Float x; Int y] -> Explicit (Float (x +. float_of_int y))
      | [_; _] -> raise (Type_error "add")
      | _ -> raise (Arity_error "add")
    );
    ("print", fun p -> 
      let rec print_sl (params : value list) =
        match params with
        | [] -> print_endline ""
        | h::t ->
            Utils.print_poly h;
            print_sl t;
      in print_sl p; Unit
    );
    ("cmp", function
      | [Int x; Int y] -> Explicit (Int (compare x y))
      | [String s1; String s2] -> Explicit(Int (compare s1 s2))
      | [Bool b1; Bool b2] -> Explicit (Int (compare b1 b2))
      | [_; _] -> raise (Type_error "cmp")
      | _ -> raise (Arity_error "cmp")
    );
    ("ignore", fun x -> ignore x; Unit);
    ("eq", fun p ->
      let rec all_eq x = function
      | [] -> true
      | h::t -> h = x && all_eq x t in
      let rec eq_all = function
      | [] -> false
      | h::t -> all_eq h t
      in Explicit (Bool (eq_all p))
    );
    ("li", fun p -> Explicit (List p));
    ("cons", function
      | [x; List l] -> Explicit (List (x::l))
      | [_; _] -> raise (Type_error "cons")
      | _ -> raise (Arity_error "cons")
    );
    ("hd", function
      | [List []] -> raise (Invalid_argument "hd on empty list")
      | [List (h::t)] -> Explicit h
      | [_] -> raise (Type_error "hd")
      | _ -> raise (Arity_error "hd")
    );
    ("tl", function
      | [List []] -> raise (Invalid_argument "tl on empty list")
      | [List (h::t)] -> Explicit (List t)
      | [_] -> raise (Type_error "tl")
      | _ -> raise (Arity_error "tl")
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

let (emptyContext : context) = {vars = consts; funs = IdentMap.empty; recDepth = 0}

(* declare a variable *)
let rec declareVar (name : identifier) (value : Ast.t) (context : context) : exprRet =
  let v = interpret_expr_ctx value context in
  (match v with 
  | Explicit v -> context.vars <- IdentMap.add name v context.vars
  | Unit -> raise (Type_error ("Unit assignment of " ^ name)));
  Unit

(* declare a function *)
and declareFun (name : identifier) (params : funParams) (body : Ast.t) (context : context) : exprRet =
  context.funs <- IdentMap.add name (body, params) context.funs;
  Unit

(* apply a function *)
and applyFun (name : identifier) (paramExprs : Ast.t list) (context : context) : exprRet =
  if context.recDepth >= 1000
  then raise (Recursion_error name)
  else
  match IdentMap.find_opt name builtins with
  (* if it isn't a builtin *)
  | None -> begin
    let f, parNames = begin 
      match IdentMap.find_opt name context.funs with
      | None -> raise (Undeclared_identifier name)
      | Some x -> x
    end in
    let parNames = List.to_seq parNames in
    (* evaluate each param (strict)*)
    let paramVals = List.map (fun e ->
      match interpret_expr_ctx e context with
      | Explicit v -> v
    (*TODO Better error msg *)
      | Unit -> raise (Type_error ("Unit assignment of <argname> in " ^ name ^ "call")))
    paramExprs |> List.to_seq in
    let ctxVars = IdentMap.add_seq (Seq.zip parNames paramVals) context.vars in
    interpret_expr_ctx f {vars = ctxVars; funs = context.funs; recDepth = context.recDepth + 1}
    end
  (* if it is builtin *)
  | Some f -> f (
    List.map (fun e ->
      match interpret_expr_ctx e context with
      | Unit -> raise (Type_error ("Unit assignment of <arg in " ^ name ^ "call"))
      | Explicit v -> v)
    paramExprs)

and conditionnal (cond : Ast.t) (thenExpr : Ast.t) (elseExpr : Ast.t) context =
  match interpret_expr_ctx cond context with
  | Explicit (Bool s) ->
      if s
      then interpret_expr_ctx thenExpr context
      else interpret_expr_ctx elseExpr context
  | _ -> raise (Type_error "Condition did not evaluate to true")

and interpret_expr_ctx (ast: Ast.t) (context : context) : exprRet =
  match ast with
  | Ast.Seq l -> let rec aux l =
    begin match l with
    | [] -> raise Invalid_sequence
    | [e] -> interpret_expr_ctx e context
    | e1::t -> begin
      match interpret_expr_ctx e1 context with
      | Unit -> aux t
      | Explicit _ -> raise Invalid_sequence
      end 
    end 
    in aux l
  | Ast.Int x -> Explicit (Int x)
  | Ast.String s -> Explicit (String s)
  | Ast.Float f -> Explicit (Float f)
  | Ast.Ident v -> Explicit ( 
    match IdentMap.find_opt v context.vars with
    | None -> raise (Undeclared_identifier v)
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
  interpret_expr_ctx ast emptyContext

