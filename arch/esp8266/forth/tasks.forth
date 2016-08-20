0 constant: PAUSED
1 constant: SKIPPED

struct
    cell field: .next
    cell field: .status
    cell field: .sp
    cell field: .rp
    cell field: .ip
    cell field: .s0
    cell field: .r0
    cell field: .handler
constant: Task

here Task allot constant: INTERPRETER
INTERPRETER INTERPRETER .next !
SKIPPED INTERPRETER .status !
_s0 INTERPRETER .s0 !
_r0 INTERPRETER .r0 !

320 init-variable: var-task-stack-size
320 init-variable: var-task-rstack-size
INTERPRETER init-variable: var-last-task
INTERPRETER init-variable: var-current-task

: last-task ( -- task ) var-last-task @ ;
: last-task! ( task -- ) var-last-task ! ;
: current-task ( -- task ) var-current-task @ ;
: current-task! ( task -- ) var-current-task ! ;

: alloc-data-stack ( -- a )
    var-task-stack-size @ allot here ;

: alloc-return-stack ( -- a )
    var-task-rstack-size @ allot here ;

: task: ( user-space-size "name" ) ( -- task )
    create:
        here                                 \ task header begins here
        swap Task + allot                    \ make room for task header + user space
        SKIPPED             over .status !   \ new status is SKIPPED
        last-task .next @   over .next !     \ this.next = last-task.next
        dup last-task .next !                \ last-task.next = this
        alloc-data-stack    over .sp !       \ this.sp = allocated
        alloc-return-stack  over .rp !       \ this.sp = allocated
        0                   over .handler !  \ exception handler of this thread
        dup .sp @ over .s0 !                 \ init s0 = top of stack address
        dup .rp @ over .r0 !                 \ init r0 = top of rstack address
        last-task! ;                         \ last-task = this

: task-choose-next ( -- )    
    current-task
    begin        
        .next @ dup
        .status @ PAUSED =
    until ;

: task-save-context ( sp ip rp -- ) \ XXX temporal coupling
    current-task .rp !
    current-task .ip !
    current-task .sp ! ;

: task-restore-context ( -- )    
    current-task .sp @ sp!
    current-task .rp @ rp!
    current-task .ip @ >r ;

: task-run ( task -- )
    current-task!
    SKIPPED current-task .status !
    task-restore-context ;

: task-user-space ( task -- a ) Task + ;

: user-space ( -- a )
    current-task task-user-space ;

defer: pause

: pause-multi ( -- )
    PAUSED current-task .status !
    sp@ r> rp@ task-save-context
    task-choose-next task-run ;

: pause-single ( -- ) ;

: s0-multi ( -- top-stack-adr ) current-task .s0 @ ;
: r0-multi ( -- top-rstack-adr ) current-task .r0 @ ;

' s0 is: s0-multi
' r0 is: r0-multi

: activate ( task -- )
    r> over .ip !
    PAUSED current-task .status !   \ pause current task
    sp@ cell + r> rp@ task-save-context        
    task-run ;

: stop ( task -- )
    SKIPPED swap .status ! 
    task-choose-next task-run ;

: deactivate ( -- )
    current-task stop ;

: task-find ( task -- link )
    lastword
    begin
        dup 0<>
    while
        2dup
        link>body cell + = if \ XXX skip behaviour pointer
            nip exit
        then
        @
    repeat
    2drop 0 ;

: tasks-print ( -- )
    current-task
    begin
        dup task-find dup 0<> if
            link-type cr
        else
            drop println: "interpreter"
        then
        .next @ dup
        current-task =
    until
    drop ;
   
: semaphore: ( -- ) init-variable: ;
: mutex: ( -- ) 1 semaphore: ;

: wait ( semaphore -- )
    begin
        pause
        dup @ 0<>
    until
    -1 swap +! ;

: signal ( semaphore -- )
    1 swap +! 
    pause ;
 
: multi-handler ( -- a ) current-task .handler ;

: multi ( -- ) \ switch to multi-task mode
    ['] handler is: multi-handler \ each tasks should have its own exception handler
    ['] pause xpause !
    ['] pause is: pause-multi ;     
    
: single ( -- ) \ switch to signle-task mode
    ['] handler is: single-handler \ use global handler
    0 xpause ! 
    ['] pause is: pause-single ;     
    
: mailbox: ( size ) ( -- mailbox ) ringbuf: ;

: mailbox-send ( message mailbox -- )
    begin
        dup ringbuf-full? 
    while
        pause 
    repeat
    ringbuf-enqueue ;

: mailbox-receive ( mailbox -- message )
    begin
        dup ringbuf-empty?
    while
        pause
    repeat
    ringbuf-dequeue ;
    
single
