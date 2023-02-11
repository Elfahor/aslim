let replMode =
  while true do
    print_string "> ";
    match (
      read_line ()
      |> Aslim.Stages.interpret_single_expr)
    with
    | Aslim.Interpreter.Unit ->
        ()
    | Aslim.Interpreter.Explicit v ->
      begin match v with
      | String s -> Printf.printf "str: %s\n" s
      | Int n -> Printf.printf "int: %d\n" n
      end
  done

let () = Arg.parse [
    "-i", 
      Unit (fun () -> replMode), 
      "Start an interactive session (REPL)"
  ]
  (fun x -> ignore x)
  (Sys.argv |> Array.to_list |> String.concat " ")
  
