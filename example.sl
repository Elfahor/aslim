(let _x 5)
(fun incr _a (
  (if (eq _a 7)
    (print "It's a five!")
    (print "No, my lucky number :("))
  (add _a 1)))
(print (incr _x))
(print (add "hello" " world"))
