open Aslim

let replMode () =
  while true do
    print_string "> ";
    let input = read_line () in
    let res = try 
      Stages.interpret_single_expr input
      with 
      | Epl_lexer.Invalid_token ->
          print_endline "Invalid token"; 
          Globals.Unit
      | Parsing.Parse_error -> 
          print_endline "Ill formed expression"; 
          Globals.Unit
      | Interpreter.Invalid_sequence ->
          print_endline "Invalid sequence"; 
          Globals.Unit
      | Interpreter.Type_error s ->
          print_endline ("Type error " ^ s); 
          Globals.Unit
      | Interpreter.Recursion_error s ->
          print_endline ("Recursion error in " ^ s);
          Unit
      | Interpreter.Undeclared_identifier s ->
          print_endline ("Undeclared identifier: " ^ s);
          Unit

    in match res with
    | Globals.Unit ->
        ()
    | Globals.Explicit v ->
      begin match v with
      | String s -> Printf.printf "%s\n" s
      | Int n -> Printf.printf "%d\n" n
      | Bool b -> Printf.printf "%b\n" b
      | Float f -> Printf.printf"%f\n" f
      | List l -> Utils.print_list l; print_newline ()
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
  
