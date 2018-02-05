;;==================== Tournament initiators & properties ====================;;

;; Setup the world.
to setup
  clear-all
  set-default-shape turtles "turtle" ;; Set default shape to turtle.
  ;; Create turtles and set strategy
  create-turtles number-of-agents-approach-one [
    construct-agents "tit-for-tat" 25  2
  ]
  create-turtles number-of-agents-approach-two [
    construct-agents "tit-for-two-tats" 95  2
  ]
  initialise-game-variables
  reset-ticks
  debugging-message "Setup ran successfuly."
  set number-of-round 0
end

;; Initiate tournament
to run-tournament
  if ticks >= 500 [stop]
  move-turtles
  tick
  debugging-message "New tournament started."
end

;; Initiate evolutionary tournament
to run-evolutionary-tournament [agents-type-of-strategy] ;; Targets agents by strategy type
    ;; The number playing approach A is proportional to the average score of A in the previous tournament
    let number-of-score score
    let agent-colour 0
    if agents-type-of-strategy = "tit-for-tat" [
      set agent-colour approach-one-colour
      reproduce-every-tournament 1 agents-type-of-strategy ;; Reproduce of turtle every tournament
    ]
    if agents-type-of-strategy = "tit-for-two-tats" [
      set agent-colour approach-two-colour
      reproduce-every-tournament 1 agents-type-of-strategy ;; Reproduce of turtle every tournament
    ]
end

;; Hatch new turtles every 100 ticks
to reproduce-every-tournament [num-of-new-turtles strategy-type]
    let number-to-reproduce-by (sum [score] of turtles with [strategy = strategy-type] / 100)
    if ticks mod 100 = 0 [
      show (word "Round number: " number-of-round)
      hatch num-of-new-turtles
      show "Turtles hatched"
    ]
end

;; Construct agents with a strategy, color and size, then plot them randomly on graph.
to construct-agents [agent-strategy agent-color agent-size]
  set strategy agent-strategy
  set size agent-size
  set color agent-color
  setxy random-xcor random-ycor
  debugging-message "Agent successfully constructed."
end

;; Global variables
globals [approach-one-colour approach-two-colour number-of-round]

;; Patches and turtles variables
patches-own []
turtles-own [score strategy interaction-history my-last-move opponent opponent-last-move]

;;==================== End of Tournament initiators & properties  ====================;;



;;==================== Turtle procedures ====================;;

to move-turtles
  ask turtles [
    move-random
    handle-interaction
    if evolutionary-tournament = true [
      run-evolutionary-tournament strategy
    ]
  ]
end

;; Move turtles randomly
to move-random
  right random 360
  forward 1
end

;; Initialise game variables here...
to initialise-game-variables
  ask turtles [
    set score 0
    set interaction-history []
    set approach-one-colour 25
    set approach-two-colour 95
  ]
  debugging-message "Game variables: score and interaction-history initialised"
end

;; Handle interaction between agent and opponent when they interact.
to handle-interaction
;; Detects interaction with other agents based on turtles found on neighbors4 patches
  if any? turtles-on neighbors4 [
     set opponent first [who] of turtles-on neighbors4
     ;; Initial cooperation
     ifelse (empty? interaction-history);; or occurrences [who] of turtles-on neighbors4 actions-history
     [
       cooperate-with-opponent (word opponent)
       remember-opponents-last-move
     ]
     [
       ;; Else if list is NOT empty?
       make-move strategy
     ]
     remember-opponents-last-move
  ]
end

;; If first encounter with agent, then cooperate. Otherwise, cooperate as a copied move from opponent.
to cooperate-with-opponent [opponent-number]
  set interaction-history lput (list (word "C" opponent-number) ) interaction-history ;; "C" denotes COOPERATION
  increase-score
end

;; Defects against opponent by setting "D" coupled with the number of the opponent (equating to "D[opponent-number]")
to defect-against-opponent [opponent-number]
  set interaction-history lput (list (word "D" opponent-number) ) interaction-history;; "D" denotes DEFECTION
  decrease-score
end

;; Identifies agent's strategy and makes appropriate move.
to make-move [agent-strategy]
  if agent-strategy = "tit-for-tat" [
     copy-opponent
  ]
  if agent-strategy = "tit-for-two-tats" [
    run-tit-for-two-tats
  ]
end

;; Copy opponent, based on their last move.
to copy-opponent
  if (item 1 (word opponent-last-move)) = "C" and interacted-with-opponent-previously? = true [
    cooperate-with-opponent (item 2 (word opponent-last-move))
  ]
  if (item 1 (word opponent-last-move)) = "D" and interacted-with-opponent-previously? = true [
    defect-against-opponent (item 2 (word opponent-last-move))
  ]
end

;; If I have cooperated with opponent before THEN copy opponents move.
to remember-opponents-last-move
  ;; Stores this agents last move
  set my-last-move (last interaction-history)
  ;; Stores lasts time I interacted with agent I am now interacting with.
  set opponent-last-move (last filter [last ? != (is-number? opponent)] interaction-history)
end

;; Increases score by 10
to increase-score
  set score score + 10
  debugging-message "Score increased by 1."
end

;; Decreases score by 10
to decrease-score
  set score score - 10
  debugging-message "Score decreased by 1."
end

;;==================== End of Turtle procedures ====================;;



;;==================== Strategy procedures ====================;;

;; Cooperates on first move, then defects ONLY when the opponent defects twice.
to run-tit-for-two-tats
  ifelse length (positions (word opponent) (word interaction-history)) > 1 [
    debugging-message "I have faced this opponent before, so defect."
    defect-against-opponent (item 2 (word opponent-last-move))
  ]
  [
    cooperate-with-opponent (item 2 (word opponent-last-move))
  ]
end

;;==================== End of Strategy procedures ====================;;



;;==================== Reporters ====================;;

to-report interacted-with-opponent-previously?
  report member? (word opponent) (word interaction-history)
end

;; count the number of occurrences of an item in a list
to-report occurrences [x the-list]
  report reduce
    [ifelse-value (?2 = x) [?1 + 1] [?1]] (fput 0 the-list)
end

;; Reports positions of text (x) in string (s)
to-report positions [x s]
  let result []
  foreach n-values length s [?] [
    if item ? s = x [ set result lput ? result ]
  ]
  report result
end
;;==================== End of Reporters ====================;;

;;==================== Debugging procedures ====================;;

to debugging-message [message]
  if debugging = true [
    show message
  ]
end
;;==================== End of Debugging procedures ====================;;