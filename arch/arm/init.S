.macro init_forth
    ldr r0, =input_buffer
    ldr r1, =input_index
    str r0, [r1]

    ldr r0, =dictionary
    ldr r1, =var_dp 
    str r0, [r1]

    ldr r1, =stack_top
    str sp, [r1]

    ldr r6, =rstack_top
    ldr r7, =outer_interpreter 
    NEXT                         
.endm
