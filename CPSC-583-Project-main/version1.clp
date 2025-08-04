; Set-up all the parts of the board
(deffacts squares "all of the squares x y on the 4x4 game board, also the players starting position"
    (square 1 1)
    (square 1 2)
    (square 1 3)
    (square 1 4)
    (square 2 1)
    (square 2 2)
    (square 2 3)
    (square 2 4)
    (square 3 1)
    (square 3 2)
    (square 3 3)
    (square 3 4)
    (square 4 1)
    (square 4 2)
    (square 4 3)
    (square 4 4)
    (player_at 1 1)
    (safe 1 1)
)
(deffacts board "sample user input for board"
    (wumpus 4 1)
    (gold 1 4)
    (pit 4 4)
    (pit 3 3)
)

(defrule add_stench "squares adjacent to Wumpus contain a stench"
    (wumpus ?x ?y)
    =>
    (assert (stench (+ ?x 1) ?y))
    (assert (stench (- ?x 1) ?y))
    (assert (stench ?x (+ ?y 1)))
    (assert (stench ?x (- ?y 1)))
)
(defrule check_stench "make sure each stench is on a valid sqaure, if not remove it"
    ?stench <- (stench ?x ?y)
    (not(square ?x ?y))
    =>
    (retract ?stench)
)
(defrule add_breeze"squares adjacent to pit contains a breeze"
    (pit ?x ?y)
    =>
    (assert (breeze (+ ?x 1) ?y))
    (assert (breeze (- ?x 1) ?y))
    (assert (breeze ?x (+ ?y 1)))
    (assert (breeze ?x (- ?y 1)))
)
(defrule check_breeze "make sure each breeze is on a valid square, if not remove it"
    ?breeze <- (breeze ?x ?y)
    (not(square ?x ?y))
    =>
    (retract ?breeze)
)
; Movement rules
(defrule add_visitable "if a square is deemed safe, add adjacent squares as vistable"
    (safe ?x ?y)
    =>
    (assert (visitable (+ ?x 1) ?y))
    (assert (visitable (- ?x 1) ?y))
    (assert (visitable ?x (+ ?y 1)))
    (assert (visitable ?x (- ?y 1)))
)
(defrule check_visitable "make sure each visitable square is on a valid square and retract any squares already deemded safe."
    ?visitable <- (visitable ?x ?y)
    (or (not(square ?x ?y))
    (safe ?x ?y))
    =>
    (retract ?visitable)
)
(defrule check_safe_square "make sure the square is safe and retract visitable."
    (visitable ?x ?y)
    (not (breeze ?x ?y))
    (not (stench ?x ?y))
    =>
    (assert (safe ?x ?y))
    (printout t "Safe(" ?x "," ?y ")"  crlf)
)
(defrule check_if_gold "if square has gold, printout all safe squares and end game"
    (safe ?x ?y)
    (gold ?x ?y)
    =>
    (printout t "Gold found at: square(" ?x "," ?y ")"  crlf)
    (halt)
)