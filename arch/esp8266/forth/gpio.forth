0 constant: GPIO_INTTYPE_NONE
1 constant: GPIO_INTTYPE_EDGE_POS
2 constant: GPIO_INTTYPE_EDGE_NEG
3 constant: GPIO_INTTYPE_EDGE_ANY
4 constant: GPIO_INTTYPE_LEVEL_LOW
5 constant: GPIO_INTTYPE_LEVEL_HIGH
1 constant: GPIO_IN
2 constant: GPIO_OUT
1 constant: GPIO_HIGH
0 constant: GPIO_LOW

: blink ( pin -- )
    dup 
    GPIO_OUT gpio-mode
    dup
    GPIO_HIGH gpio-write
    250 ms
    GPIO_LOW gpio-write
    250 ms ;
    
: times-blink ( pin ntimes -- )
    0 do
        dup blink
    loop 
    drop ;    
