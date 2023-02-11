open Aslim

let replMode () =
  while true do
    print_string "> ";
    let input = read_line () in
    let res = try 
      Stages.interpret_single_expr input
      with 
      | Parsing.Parse_error -> 
          print_endline "Ill formed expression"; 
          Interpreter.Unit
      | Interpreter.Invalid_sequence ->
          print_endline "Invalid sequence"; 
          Interpreter.Unit
      | Interpreter.Unit_assignment s ->
          print_endline ("Unit assignment" ^ s); 
          Interpreter.Unit
    in match res with
    | Aslim.Interpreter.Unit ->
        ()
    | Aslim.Interpreter.Explicit v ->
      begin match v with
      | String s -> Printf.printf "str: %s\n" s
      | Int n -> Printf.printf "int: %d\n" n
      | Bool b -> Printf.printf "bool: %b\n" b
      end
  done

let run_file path =
  open_in path
  |> Stages.interpret_file

let () = Arg.parse [
    "-i", 
      Unit (fun () -> replMode ()), 
      "Start an interactive session (REPL)";
  ]
  (fun x -> run_file x)
  (Sys.argv |> Array.to_list |> String.concat " ")
  
