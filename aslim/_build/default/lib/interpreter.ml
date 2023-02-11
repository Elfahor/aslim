type value =
  | Int of int
  | String of string

type exprRet =
  | Explicit of value
  | Unit

type builtin = value list -> value

type identifier = string
module IdentMap = Map.Make (String)

type varTable = value IdentMap.t
type funTable = (Ast.t * identifier list) IdentMap.t

let builtins =
  [ 
    ("add", function
      | [Int x; Int y] -> Explicit (Int (x + y))
      | _ -> failwith "error: bad arg"
    )
  ] 
  |> List.to_seq
  |> IdentMap.of_seq

type context = { mutable vars: varTable; mutable funs: funTable }

let emptyContext = {vars = IdentMap.empty; funs = IdentMap.empty}

let assignment_error x =
  ["error:"; x; "assignment returned unit"] 
  |> String.concat " " 
  |> failwith

let rec interpret_expr_ctx (ast: Ast.t) (context : context) =
  match ast with
  | Ast.Int x -> Explicit (Int x)
  | Ast.String s -> Explicit (String s)
  | Ast.Ident v -> Explicit (IdentMap.find v context.vars)
  | Ast.VarDecl (x, e) ->
      let v = interpret_expr_ctx e context in
      (match v with 
      | Explicit v -> context.vars <- IdentMap.add x v context.vars
      | Unit -> assignment_error x);
      Unit
  | Ast.FunDecl (name, params, ret) -> 
      context.funs <- IdentMap.add name (ret, params) context.funs;
      Unit
  | Ast.Application (name, paramExprs) ->
      match IdentMap.find_opt name builtins with
      | None -> begin
        let f, parNames = IdentMap.find name context.funs in
        let parNames = List.to_seq parNames in
        let paramVals = List.map (fun e ->
          match interpret_expr_ctx e context with
          | Explicit v -> v
          | Unit -> assignment_error "duh")
        paramExprs |> List.to_seq in
        let ctxVars = IdentMap.add_seq (Seq.zip parNames paramVals) context.vars in
        interpret_expr_ctx f {vars = ctxVars; funs = context.funs}
        end
      | Some f -> f (
        List.map (fun e ->
          match interpret_expr_ctx e context with
          | Unit -> assignment_error "arg"
          | Explicit v -> v)
        paramExprs)

let interpret_expr ast = 
  interpret_expr_ctx ast emptyContext

