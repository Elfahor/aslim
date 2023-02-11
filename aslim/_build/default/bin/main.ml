let replMode () =
  while true do
    print_string "> ";
    let input = read_line () in
    let res = try 
      Aslim.Stages.interpret_single_expr input
      with Parsing.Parse_error -> 
        print_endline "Ill formed expression"; Aslim.Interpreter.Unit
    in match res with
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
      Unit (fun () -> replMode ()), 
      "Start an interactive session (REPL)";
  ]
  (fun x -> ignore x)
  (Sys.argv |> Array.to_list |> String.concat " ")
  
