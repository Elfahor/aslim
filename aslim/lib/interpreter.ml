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

(* most basic error kind *)
exception Unit_assignment of string
let assignment_error (x : identifier) =
  ["error:"; x; "assignment returned unit"] 
  |> String.concat " " 
  |> fun s -> raise (Unit_assignment s)

exception Invalid_sequence
exception Undeclared_identifier of string

(* builtin functions *)
let (builtins : builtin IdentMap.t) =
  [ 
    ("add", function
      | [Int x; Int y] -> Explicit (Int (x + y))
      | [String s1; String s2] -> Explicit (String (s1 ^ s2))
      | _ -> assignment_error "add"
    );
  ] 
  |> List.to_seq
  |> IdentMap.of_seq

let (emptyContext : context) = {vars = IdentMap.empty; funs = IdentMap.empty}

(* declare a variable *)
let rec declareVar (name : identifier) (value : Ast.t) (context : context) : exprRet =
  let v = interpret_expr_ctx value context in
  (match v with 
  | Explicit v -> context.vars <- IdentMap.add name v context.vars
  | Unit -> assignment_error name);
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
      | Unit -> assignment_error name)
    paramExprs |> List.to_seq in
    let ctxVars = IdentMap.add_seq (Seq.zip parNames paramVals) context.vars in
    interpret_expr_ctx f {vars = ctxVars; funs = context.funs}
    end
  (* if it is builtin *)
  | Some f -> f (
    List.map (fun e ->
      match interpret_expr_ctx e context with
      | Unit -> assignment_error name
      | Explicit v -> v)
    paramExprs)

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

(* top level interpretation starting from an emptyContext *)
let interpret_expr (ast : Ast.t) : exprRet = 
  interpret_expr_ctx ast emptyContext

