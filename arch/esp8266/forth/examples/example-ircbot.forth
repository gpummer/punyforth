2 constant: LED    
512 constant: buffer-size
buffer-size buffer: line-buffer
0 init-variable: irc-con

exception: EIRC

: connect ( -- )
    6667 str: "irc.freenode.net" TCP netcon-connect irc-con ! ;

: send ( str -- )
    irc-con @ swap netcon-writeln ;
    
: register ( -- )
    str: "NICK hodor179" send
    str: "USER hodor179 hodor179 bla :hodor179" send ;
    
: join ( -- ) str: "JOIN #somechan" send ;
: greet ( -- ) str: "PRIVMSG #somechan :Hooodoor!" send ;
: quit ( -- ) str: "QUIT :hodor" send ;
    
: readln ( -- str )
    irc-con @ buffer-size line-buffer netcon-readln -1 = if
        EIRC throw
    then    
    line-buffer ;
        
: processline ( str -- )
    dup type cr
    dup str: "PING" str-starts? if
        str: "PONG" send
        random 200 % 0= if
            greet
        then
    then
    dup str: "PRIVMSG" str-in? if
        LED blink
    then 
    drop ;

0 task: ircbot-task

: run ( -- )    
    connect 
    register 
    join
    begin
        readln processline        
    again ;

: bot-start ( -- )
    multi
    ircbot-task activate
    begin
        println: "Starting IRC bot"
        ['] run catch ?dup if
            print: 'Exception in ircbot: ' ex-type cr
        then
        irc-con @ if
            irc-con @ netcon-dispose
            0 irc-con !
        then
        5000 ms
    again
    deactivate ;
