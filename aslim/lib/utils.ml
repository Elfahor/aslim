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
  | String s -> print_string s
  | Bool b -> print_bool b
  | List l -> print_list l
