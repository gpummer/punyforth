12 constant: BUTTON_BEDROOM \ D6 pin on nodemcu
14 constant: BUTTON_HALL    \ D5 pin on nodemcu

\ setup gpio buttons
BUTTON_HALL GPIO_IN gpio-mode
BUTTON_HALL GPIO_INTTYPE_EDGE_NEG gpio-set-interrupt
BUTTON_BEDROOM GPIO_IN gpio-mode
BUTTON_BEDROOM GPIO_INTTYPE_EDGE_NEG gpio-set-interrupt

800 constant: DEBOUNCE_TIME \ 0.8 sec
0 init-variable: last-hall-event
0 init-variable: last-bedroom-event

Event buffer: event

: toggle-hall ( -- )
    ms@ last-hall-event @ - DEBOUNCE_TIME > if
        HALL toggle
        ms@ last-hall-event !
    then ;

: toggle-bedroom ( -- )
    ms@ last-bedroom-event @ - DEBOUNCE_TIME > if
        BEDROOM toggle
        ms@ last-bedroom-event !
    then ;

: switch-loop ( task -- )
    activate
    begin
        event next-event
        event .type @ EVT_GPIO = if
            event .payload @
            case
                BUTTON_HALL of
                    toggle-hall
                endof
                BUTTON_BEDROOM of
                    toggle-bedroom
                endof
                drop
            endcase
        else
            print: 'unknown event: ' event .type ? cr
        then
    again
    deactivate ;

0 task: hue-task
    
: hue-start ( -- )
    multi
    hue-task switch-loop ;
