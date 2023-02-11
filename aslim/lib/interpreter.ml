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

(* builtin functions *)
let (builtins : builtin IdentMap.t) =
  [ 
    ("add", function
      | [Int x; Int y] -> Explicit (Int (x + y))
      | _ -> failwith "error: bad arg"
    );
  ] 
  |> List.to_seq
  |> IdentMap.of_seq

let emptyContext = {vars = IdentMap.empty; funs = IdentMap.empty}

let assignment_error x =
  ["error:"; x; "assignment returned unit"] 
  |> String.concat " " 
  |> failwith

(* declare a variable *)
let rec declareVar name value context =
  let v = interpret_expr_ctx value context in
  (match v with 
  | Explicit v -> context.vars <- IdentMap.add name v context.vars
  | Unit -> assignment_error name);
  Unit

(* declare a function *)
and declareFun name params ret context =
  context.funs <- IdentMap.add name (ret, params) context.funs;
  Unit

(* apply a function *)
and applyFun name paramExprs context =
  match IdentMap.find_opt name builtins with
  (* if it isn't a builtin *)
  | None -> begin
    let f, parNames = IdentMap.find name context.funs in
    let parNames = List.to_seq parNames in
    (* evaluate each param (strict)*)
    let paramVals = List.map (fun e ->
      match interpret_expr_ctx e context with
      | Explicit v -> v
      | Unit -> assignment_error "duh")
    paramExprs |> List.to_seq in
    let ctxVars = IdentMap.add_seq (Seq.zip parNames paramVals) context.vars in
    interpret_expr_ctx f {vars = ctxVars; funs = context.funs}
    end
  (* if it is builtin *)
  | Some f -> f (
    List.map (fun e ->
      match interpret_expr_ctx e context with
      | Unit -> assignment_error "arg"
      | Explicit v -> v)
    paramExprs)

and interpret_expr_ctx (ast: Ast.t) (context : context) =
  match ast with
  | Ast.Int x -> Explicit (Int x)
  | Ast.String s -> Explicit (String s)
  | Ast.Ident v -> Explicit (IdentMap.find v context.vars)
  | Ast.VarDecl (x, e) ->
      declareVar x e context
  | Ast.FunDecl (name, params, ret) -> 
      declareFun name params ret context
  | Ast.Application (name, paramExprs) ->
      applyFun name paramExprs context

let interpret_expr ast = 
  interpret_expr_ctx ast emptyContext

