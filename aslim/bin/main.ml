open Aslim

let replMode () =
  while true do
    print_string "> ";
    let input = read_line () in
    let res =
      Stages.interpret_single_expr input
    in match res with
    | Globals.Unit ->
        ()
    | Globals.Explicit v ->
        Utils.print_poly v; print_endline "";
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
  
