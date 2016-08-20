\ Detects motion using a PIR sensor and turns Philips Hue lights on/off
\ I tested this with these mini IR PIR sensors http://www.banggood.com/3Pcs-Mini-IR-Infrared-Pyroelectric-PIR-Body-Motion-Human-Sensor-Detector-Module-p-1020422.html

4 constant: PIR_PIN         \ D2 leg
0 constant: MODE_MOTION
1 constant: MODE_NOMOTION
variable: mode
0 task: detector-task
Event buffer: event
defer: motion-detected

: detect-motion ( -- )
    PIR_PIN GPIO_IN gpio-mode
    PIR_PIN GPIO_INTTYPE_EDGE_POS gpio-set-interrupt 
    MODE_MOTION mode ! ;

: detect-nomotion ( -- )
    PIR_PIN GPIO_IN gpio-mode
    PIR_PIN GPIO_INTTYPE_EDGE_NEG gpio-set-interrupt 
    MODE_NOMOTION mode ! ;

: pir-event? ( event -- bool )
    { .type @ EVT_GPIO = }
    { .payload @ PIR_PIN = } bi and ;

: recent-event? ( event -- bool )
    ms@ swap .time @ - 80 < ;
    
: motion ( -- )
    print: 'motion detected at ' event .time ? cr
    detect-nomotion
    ['] motion-detected catch ?dup if
        ex-type cr
    then ;

: nomotion ( -- )
    print: 'motion stopped at ' event .time ? cr
    detect-motion ;

: event-loop ( task -- )
    activate
    begin
        event next-event 
        event pir-event? event recent-event? and if
            mode @ 
            case
                MODE_MOTION of motion endof
                MODE_NOMOTION of nomotion endof
            endcase
        then
    again
    deactivate ;

: lights-on ( -- )
    BEDROOM on? invert if BEDROOM on then ;

: lights-off ( -- )
    BEDROOM on? if BEDROOM off then ;

: hue-motion-start ( -- )
    multi
    detect-motion
    ['] motion-detected is: lights-on
    detector-task event-loop ;
    
hue-motion-start
