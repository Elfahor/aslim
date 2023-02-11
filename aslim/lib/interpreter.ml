type value =
  | Int of int
  | Bool of bool
  | String of string
type exprRet =
  | Explicit of value
  | Unit
type builtin = value list -> exprRet
type identifier = string
module IdentMap = Map.Make (String)
type funParams = identifier list
type funDecl = Ast.t * funParams
type varTable = value IdentMap.t
type funTable = funDecl IdentMap.t
type context = { mutable vars: varTable; mutable funs: funTable }

exception Type_error of string
(* let assignment_error (x : identifier) = *)
(*   ["error:"; x; "assignment returned unit"]  *)
(*   |> String.concat " "  *)
(*   |> fun s -> raise (Type_error s) *)

exception Invalid_sequence
exception Undeclared_identifier of identifier
exception Arity_error of identifier

(* builtin functions *)
let (builtins : builtin IdentMap.t) =
  [ 
    ("add", function
      | [Int x; Int y] -> Explicit (Int (x + y))
      | [String s1; String s2] -> Explicit (String (s1 ^ s2))
      | [_; _] -> raise (Type_error "add")
      | _ -> raise (Arity_error "add")
    );
    ("print", fun p -> 
      let print_bool b =
        if b then print_string "true"
        else print_string "false"
      in let print_poly x = 
        match x with
        | Int a -> print_int a
        | String s -> print_string s
        | Bool b -> print_bool b
      in let rec print_sl params =
        match params with
        | [] -> print_endline ""
        | h::t ->
            print_poly h;
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
    )
  ] 
  |> List.to_seq
  |> IdentMap.of_seq

let (emptyContext : context) = {vars = IdentMap.empty; funs = IdentMap.empty}

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
    interpret_expr_ctx f {vars = ctxVars; funs = context.funs}
    end
  (* if it is builtin *)
  | Some f -> f (
    List.map (fun e ->
      match interpret_expr_ctx e context with
      | Unit -> raise (Type_error ("Unit assignment of <arg in " ^ name ^ "call"))
      | Explicit v -> v)
    paramExprs)

and conditionnal cond thenExpr elseExpr context =
  match interpret_expr_ctx cond context with
  | Explicit (Bool s) ->
      if s
      then interpret_expr_ctx thenExpr context
      else interpret_expr_ctx elseExpr context
  | _ -> raise (Type_error "Condition did not evaluate to true")

and interpret_expr_ctx (ast: Ast.t) (context : context) : exprRet =
  match ast with
  | Ast.Seq (e1, e2) -> begin
    match interpret_expr_ctx e1 context with
    | Unit -> interpret_expr_ctx e2 context
    | Explicit _ -> raise Invalid_sequence
    end
  | Ast.Int x -> Explicit (Int x)
  | Ast.String s -> Explicit (String s)
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

