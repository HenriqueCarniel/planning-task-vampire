(define (domain vampire)
    (:requirements :conditional-effects)
    (:predicates
        (light-on ?r)
        (slayer-is-alive)
        (slayer-is-in ?r)
        (vampire-is-alive)
        (vampire-is-in ?r)
        (fighting)
        (NEXT-ROOM ?r ?rn)
        (CONTAINS-GARLIC ?r)
    )

    (:action toggle-light
        :parameters (?anti-clockwise-neighbor ?room ?clockwise-neighbor)
        :precondition (and
            (NEXT-ROOM ?anti-clockwise-neighbor ?room)
            (NEXT-ROOM ?room ?clockwise-neighbor)
            (not (fighting))
        )
        :effect (and
            ;; Alterna a luz na sala ?room
            (when (light-on ?room) (not (light-on ?room)))
            (when (not (light-on ?room)) (light-on ?room))

            ;; Movimentos do vampiro
            (when (and (vampire-is-in ?room) (not (light-on ?room)))
                (and
                    (not (vampire-is-in ?room))
                    ;; Vampiro move-se para a esquerda se estiver escuro
                    (when (not (light-on ?anti-clockwise-neighbor))
                        (and
                            (vampire-is-in ?anti-clockwise-neighbor)
                            ;; Verifica se o caçador também está lá
                            (when (slayer-is-in ?anti-clockwise-neighbor) (fighting))
                        ))
                    ;; Vampiro move-se para a direita caso ambas as salas estejam iluminadas
                    (when (or (and (light-on ?anti-clockwise-neighbor) (light-on ?clockwise-neighbor))
                            (and (light-on ?anti-clockwise-neighbor) (not (light-on ?clockwise-neighbor))))
                        (and
                            (vampire-is-in ?clockwise-neighbor)
                            ;; Verifica se o caçador também está lá
                            (when (slayer-is-in ?clockwise-neighbor) (fighting))
                        ))
                )
            )

            ;; Movimentos da caçador
            (when (and (slayer-is-in ?room) (light-on ?room))
                (and
                    (not (slayer-is-in ?room))
                    ;; Caçador move-se para a direita se estiver iluminado
                    (when (light-on ?clockwise-neighbor)
                        (and
                            (slayer-is-in ?clockwise-neighbor)
                            ;; Verifica se o vampiro também está lá
                            (when (vampire-is-in ?clockwise-neighbor) (fighting))
                        ))
                    ;; Caso contrário, move-se para a esquerda
                    (when (not (light-on ?clockwise-neighbor))
                        (and
                            (slayer-is-in ?anti-clockwise-neighbor)
                            ;; Verifica se o vampiro também está lá
                            (when (vampire-is-in ?anti-clockwise-neighbor) (fighting))
                        ))
                )
            )
        )
    )

    (:action watch-fight
        :parameters (?room)
        :precondition (and
            (slayer-is-in ?room)
            (slayer-is-alive)
            (vampire-is-in ?room)
            (vampire-is-alive)
            (fighting)
        )
        :effect (and
            ;; Caçador morre se a sala é escura e não contém alho
            (when (and (not (light-on ?room)) (not (CONTAINS-GARLIC ?room)))
                (and (not (slayer-is-alive)) (not (fighting)) (not (slayer-is-in ?room))))

            ;; Vampiro morre se a sala é clara ou contém alho
            (when (or (light-on ?room) (CONTAINS-GARLIC ?room))
                (and (not (vampire-is-alive)) (not (fighting)) (not (vampire-is-in ?room))))
        )
    )
)
