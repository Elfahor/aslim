# Ideas for elf.lang

(let incr (fun x (+ x 1)))
Assignment("incr", 
  Function(["x"],
    Application("+",
      [Ident "x", Int 1]
    )
  )
)
