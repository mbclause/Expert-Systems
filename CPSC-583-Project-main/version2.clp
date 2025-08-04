; template for the "turn" fact
(deftemplate turn
    (slot val)
)

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

    (visited 1 1)
    (turn (val 0))
)

(deffacts board "sample user input for board"
    (pit 2 4)
    (wumpus 3 2)
    (gold 4 4)
)


; populate board with stenches and breezes given pit and wumpus location
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

; if a square does not contain a breeze or stench, mark adjacent squares as "visitable"
(defrule add_visitable_up
    (visited ?x ?y)
    (not(stench ?x ?y))
    (not(breeze ?x ?y))
    (square =(+ ?x 1) ?y)
    (not(visited =(+ ?x 1) ?y))
    =>
    (assert(visitable (+ ?x 1) ?y))
)

(defrule add_visitable_right
    (visited ?x ?y)
    (not(stench ?x ?y))
    (not(breeze ?x ?y))
    (square ?x =(+ ?y 1))
    (not(visited ?x =(+ ?y 1)))
    =>
    (assert(visitable ?x (+ ?y 1)))
)

(defrule add_visitable_down
    (visited ?x ?y)
    (not(stench ?x ?y))
    (not(breeze ?x ?y))
    (square =(- ?x 1) ?y)
    (not(visited =(- ?x 1) ?y))
    =>
    (assert(visitable (- ?x 1) ?y))
)

(defrule add_visitable_left
    (visited ?x ?y)
    (not(stench ?x ?y))
    (not(breeze ?x ?y))
    (square ?x =(- ?y 1))
    (not(visited ?x =(- ?y 1)))
    =>
    (assert(visitable ?x (- ?y 1)))
)

; go to next visitable square
(defrule visit_square
    ?visitable <- (visitable ?x ?y)
    ?r <- (turn (val ?n))
    =>
    (retract ?visitable)
    (assert(visited ?x ?y))
    (modify ?r (val (+ ?n 1)))
    (printout t "Turn " (+ ?n 1) " (" ?x ", " ?y ")" crlf)
)

; if a stench is found on a square, mark it
(defrule found_stench
    (visited ?x ?y)
    (stench ?x ?y)
    =>
    (assert(stench_found ?x ?y))
    (printout t "Stench at " ?x ", " ?y "!" crlf)
)

; if a breeze is found on a square, mark it
(defrule found_breeze
    (visited ?x ?y)
    (breeze ?x ?y)
    =>
    (assert(breeze_found ?x ?y))
    (printout t "Breeze at " ?x ", " ?y "!" crlf)
)

; IF a square DOES contain a stench
; THEN adjacent non-visitable squares contain possible_wumpus
(defrule add_possible_wumpus_up
    (stench_found ?x ?y)
    (square =(+ ?x 1) ?y)
    (not(visited =(+ ?x 1) ?y))
    (not(visitable =(+ ?x 1) ?y))
    (turn (val ?n))
    =>
    (assert(possible_wumpus ?n (+ ?x 1) ?y))
)

(defrule add_possible_wumpus_right
    (stench_found ?x ?y)
    (square ?x =(+ ?y 1))
    (not(visited ?x =(+ ?y 1)))
    (not(visitable ?x =(+ ?y 1)))
    (turn (val ?n))
    =>
    (assert(possible_wumpus ?n ?x (+ ?y 1)))
)

(defrule add_possible_wumpus_down
    (stench_found ?x ?y)
    (square =(- ?x 1) ?y)
    (not(visited =(- ?x 1) ?y))
    (not(visitable =(- ?x 1) ?y))
    (turn (val ?n))
    =>
    (assert(possible_wumpus ?n (- ?x 1) ?y))
)

(defrule add_possible_wumpus_left
    (stench_found ?x ?y)
    (square ?x =(- ?y 1))
    (not(visited ?x =(+ ?y 1)))
    (not(visitable ?x =(+ ?y 1)))
    (turn (val ?n))
    =>
    (assert(possible_wumpus ?n ?x (- ?y 1)))
)


; IF a square DOES contain a breeze
; THEN adjacent non-visitable squares contain possible_pit
(defrule add_possible_pit_up
    (breeze_found ?x ?y)
    (square =(+ ?x 1) ?y)
    (not(visited =(+ ?x 1) ?y))
    (not(visitable =(+ ?x 1) ?y))
    (turn (val ?n))
    =>
    (assert(possible_pit ?n (+ ?x 1) ?y))
)

(defrule add_possible_pit_right
    (breeze_found ?x ?y)
    (square ?x =(+ ?y 1))
    (not(visited ?x =(+ ?y 1)))
    (not(visitable ?x =(+ ?y 1)))
    (turn (val ?n))
    =>
    (assert(possible_pit ?n ?x (+ ?y 1)))
)

(defrule add_possible_pit_down
    (breeze_found ?x ?y)
    (square =(- ?x 1) ?y)
    (not(visited =(- ?x 1) ?y))
    (not(visitable =(- ?x 1) ?y))
    (turn (val ?n))
    =>
    (assert(possible_pit ?n (- ?x 1) ?y))
)

(defrule add_possible_pit_left
    (breeze_found ?x ?y)
    (square ?x =(- ?y 1))
    (not(visited ?x =(+ ?y 1)))
    (not(visitable ?x =(+ ?y 1)))
    (turn (val ?n))
    =>
    (assert(possible_pit ?n ?x (- ?y 1)))
)

; if more than one "possible_wumpus" fact is on a square, and the wumpus has not been found,
; that is the location of the wumpus
(defrule found_wumpus
    (not(wumpus_found ?asdf ?wefj))
    (possible_wumpus ?n ?x ?y)
    (possible_wumpus ?z ?a ?b)
    (test(= ?x ?a))
    (test(= ?y ?b))
    (test(neq ?n ?z))
    =>
    (assert(wumpus_found ?x ?y))
    (printout t "wumpus at " ?x ", " ?y crlf)
)

; if more than one "possible_pit" fact is on a square, and the pit has not been found,
; that is the location of the pit
(defrule found_pit
    (not(pit_found ?asdf ?wefj))
    (possible_pit ?n ?x ?y)
    (possible_pit ?z ?a ?b)
    (test(= ?x ?a))
    (test(= ?y ?b))
    (test(neq ?n ?z))
    =>
    (assert(pit_found ?x ?y))
    (printout t "pit at " ?x ", " ?y crlf)
)

; end game
(defrule check_if_gold "if square has gold, printout all safe squares and end game"
    (visited ?x ?y)
    (gold ?x ?y)
    =>
    (printout t "Gold found at: square(" ?x "," ?y ")"  crlf)
)