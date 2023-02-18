let rec print_bool b =
  if b then print_string "true"
  else print_string "false"

and print_list l =
  print_string "(li ";
  let rec aux = function
    | [] -> ()
    | [x] -> print_poly x;
    | h::t -> print_poly h; print_string " "; aux t
  in aux l; print_string ")"

and print_poly (x : Globals.value) = 
  match x with
  | Int a -> print_int a
  | Float f -> print_float f
  | String s -> print_string s
  | Bool b -> print_bool b
  | List l -> print_list l

let print_stack_trace st =
  Lexing.(
  print_string "Stack trace (most recent call first):\n";
  let rec aux = function
    | [] -> ()
    | (count, name, pos)::t ->
        Printf.printf "  at %s:%d:%d (%d times)\n" 
          name pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1) count;
        aux t
  in aux st)

