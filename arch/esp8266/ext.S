defword "readchar",8,readchar,REGULAR
    .int xt_xpause, xt_fetch, xt_branch0
    lbl readchar_blocking
readchar_again:
    .int xt_readchar_nowait, xt_dup, xt_btick, -1, xt_eq, xt_branch0
    lbl readchar_available
    .int xt_drop
    .int xt_xpause, xt_fetch, xt_execute
    .int xt_branch
    lbl readchar_again
readchar_available:
    .int xt_exit
readchar_blocking:
    .int xt_readchar_wait
    .int xt_exit

defword "xpause",6,xpause,REGULAR
    .int xt_btick, _M var_pause_xt
    .int xt_exit

defprimitive "readchar-wait",13,readchar_wait,REGULAR
    CCALL forth_getchar
    DPUSH a2
    NEXT    

defprimitive "readchar-nowait",15,readchar_nowait,REGULAR /* ( -- char | -1 ) */
    CCALL forth_getchar_nowait
    DPUSH a2
    NEXT

defprimitive "over",4,over,REGULAR /* ( a b -- a b a ) */
    l32i a8, a15, CELLS
    DPUSH a8
    NEXT

defprimitive "cells",5,cells,REGULAR
    DPOP a9
    movi a8, 2
    ssl a8
    sll a8, a9
    DPUSH a8
    NEXT

defprimitive ">",1,gt,REGULAR 
    DPOP a8
    DPOP a9
    movi a10, FALSE
    bge a8, a9, L5
    movi a10, TRUE
L5: DPUSH a10
    NEXT

defprimitive "=",1,eq,REGULAR 
    DPOP a8
    DPOP a9
    movi a10, FALSE
    bne a8, a9, L6
    movi a10, TRUE
L6: DPUSH a10
    NEXT

defprimitive "<>",2,noteq,REGULAR 
    DPOP a8
    DPOP a9
    movi a10, FALSE
    beq a8, a9, L7
    movi a10, TRUE
L7: DPUSH a10
    NEXT

defprimitive "<=",2,lte,REGULAR 
    DPOP a8
    DPOP a9
    movi a10, FALSE
    blt a8, a9, L8
    movi a10, TRUE
L8: DPUSH a10
    NEXT

defprimitive ">=",2,gte,REGULAR 
    DPOP a8
    DPOP a9
    movi a10, FALSE
    blt a9, a8, L9
    movi a10, TRUE
L9: DPUSH a10
    NEXT

defprimitive "1+",2,inc,REGULAR
    DPOP a8
    addi a8, a8, 1
    DPUSH a8
    NEXT

defprimitive "1-",2,dec,REGULAR
    DPOP a8
    addi a8, a8, -1
    DPUSH a8
    NEXT

defprimitive "0=",2,eq0,REGULAR
    DPOP a8
    movi a9, FALSE
    movi a10, TRUE
    moveqz a9, a10, a8 // move a10 to a9 if a8 is zero
    DPUSH a9
    NEXT

defprimitive "0<>",3,noteq0,REGULAR
    DPOP a8
    movi a9, FALSE
    movi a10, TRUE
    movnez a9, a10, a8 // move a10 to a9 if a8 is not zero
    DPUSH a9
    NEXT

defprimitive "0<",2,lt0,REGULAR
    DPOP a8
    movi a9, FALSE
    movi a10, TRUE
    movltz a9, a10, a8 // move a10 to a9 if a8 is less than zero
    DPUSH a9
    NEXT

defprimitive "0>",2,gt0,REGULAR
    DPOP a8
    movi a9, TRUE
    movi a10, FALSE
    movltz a9, a10, a8 // move a10 to a9 if a8 is less than zero
    moveqz a9, a10, a8 // move a10 to a9 if a8 is zero
    DPUSH a9
    NEXT

defprimitive "ms@",3,msat,REGULAR
    CCALL forth_time_ms
    DPUSH a2
    NEXT

defprimitive "_type",5,utype,REGULAR    // ( a -- )
    DPOP a2			// string
    CCALL forth_type
    NEXT

defprimitive "uart-set-bps",12,uart_set_bps,REGULAR    // ( bps uart_num -- )
    DPOP a2			// uart_num
    DPOP a3			// bps
    CCALL forth_uart_set_baud
    NEXT

defprimitive "gpio-mode",9,gpio_mode,REGULAR
    DPOP a3                     // gpio direction
    DPOP a2                     // gpio num
    CCALL forth_gpio_mode
    NEXT

defprimitive "gpio-set-interrupt",18,gpiointerrupt,REGULAR
    DPOP a3                     // gpio interrupt type
    DPOP a2                     // gpio num
    CCALL forth_gpio_set_interrupt
    NEXT

defprimitive "gpio-write",10,gpiowrite,REGULAR
    DPOP a3                     // bool
    DPOP a2                     // gpio num
    CCALL forth_gpio_write
    NEXT

defprimitive "gpio-read",9,gpioread,REGULAR
    DPOP a2                     // gpio num
    CCALL forth_gpio_read
    DPUSH a2
    NEXT

defprimitive "pwm-init",8,pwminit,REGULAR
    DPOP a2                     // pins array
    DPOP a3                     // number of pins in array
    CCALL pwm_init
    NEXT

defprimitive "pwm-freq",8,pwmfreq,REGULAR
    DPOP a2                     // freq 16b
    CCALL forth_pwm_freq
    NEXT

defprimitive "pwm-duty",8,pwmduty,REGULAR
    DPOP a2                     // duty 16b
    CCALL forth_pwm_duty
    NEXT

defprimitive "pwm-start",9,pwmstart,REGULAR
    CCALL pwm_start
    NEXT

defprimitive "pwm-stop",8,pwmstop,REGULAR
    CCALL pwm_stop
    NEXT

defprimitive "ms",2,ms,REGULAR
    DPOP a2                     // millis to wait
    CCALL forth_delay_ms
    NEXT

defprimitive "netcon-set-recvtimeout",22,netcon_set_recvtimeout,REGULAR 
    DPOP a2                    // conn
    DPOP a3                    // recv timeout ms
    CCALL forth_netcon_set_recvtimeout
    NEXT

defprimitive "netcon-new",10,netcon_new,REGULAR
    DPOP a2                    // conn type
    CCALL forth_netcon_new
    DPUSH a2
    NEXT

defprimitive "netcon-connect",14,netcon_connect,REGULAR       
    DPOP a2                    // conn
    DPOP a3                    // host
    DPOP a4                    // port
    CCALL forth_netcon_connect
    DPUSH a2
    NEXT

defprimitive "netcon-bind",11,netcon_bind,REGULAR       
    DPOP a2                    // conn
    DPOP a3                    // host
    DPOP a4                    // port
    CCALL forth_netcon_bind
    DPUSH a2
    NEXT

defprimitive "netcon-listen",13,netcon_listen,REGULAR       
    DPOP a2                    // netcon
    CCALL forth_netcon_listen
    DPUSH a2
    NEXT

defprimitive "netcon-send",11,netcon_send,REGULAR
    DPOP a2                    // conn
    DPOP a3                    // data
    DPOP a4                    // len
    CCALL forth_netcon_send
    DPUSH a2
    NEXT

defprimitive "netcon-write",12,netcon_write,REGULAR
    DPOP a2                    // conn
    DPOP a3                    // data
    DPOP a4                    // size
    CCALL forth_netcon_write
    DPUSH a2
    NEXT

defprimitive "netcon-recvinto",15,netcon_recvinto,REGULAR
    DPOP a2                    // conn
    DPOP a3                    // buffer
    DPOP a4                    // size
    CCALL forth_netcon_recvinto
    DPUSH a3                   // count read
    DPUSH a2                   // err_t
    NEXT

defprimitive "netbuf-del",10,netbuf_del,REGULAR
    DPOP a2                    // netbuf
    CCALL forth_netbufdel
    NEXT

defprimitive "netbuf-next",11,netbuf_next,REGULAR
    DPOP a2                    // netbuf
    CCALL forth_netbuf_next
    DPUSH a2
    NEXT

defprimitive "netbuf-data",11,netbuf_data,REGULAR
    DPOP a2                    // netbuf
    CCALL forth_netbuf_data
    DPUSH a3                   // buffer
    DPUSH a2                   // size
    NEXT

defprimitive "netcon-recv",11,netcon_recv,REGULAR
    DPOP a2                    // netcon
    CCALL forth_netcon_recv
    DPUSH a3                   // netbuf
    DPUSH a2                   // err_t
    NEXT

defprimitive "netcon-accept",13,netcon_accep,REGULAR
    DPOP a2                    // netcon
    CCALL forth_netcon_accept
    DPUSH a3                   // netcon
    DPUSH a2                   // err_t
    NEXT

defprimitive "netcon-close",12,netcon_close,REGULAR
    DPOP a2                    // conn
    CCALL forth_netcon_close
    NEXT

defprimitive "netcon-delete",13,netcon_delete,REGULAR
    DPOP a2                    // conn
    CCALL forth_netcon_delete
    NEXT

defprimitive "task-yield",10,task_yield,REGULAR
    CCALL forth_yield
    NEXT

defprimitive "wait-event",10,wait_event,REGULAR
    DPOP a2                    // delay ms
    DPOP a3                    // event buffer
    CCALL forth_wait_event
    DPUSH a2
    NEXT

defprimitive "random",6,random,REGULAR
    CCALL forth_random
    DPUSH a2
    NEXT

defprimitive "erase-flash",11,erase_flash,REGULAR
    DPOP a2                    // sector
    CCALL forth_flash_erase_sector
    DPUSH a2
    NEXT

defprimitive "read-flash",10,read_flash,REGULAR
    DPOP a2                    // sector
    DPOP a3                    // buffer
    DPOP a4                    // size
    CCALL forth_flash_read
    DPUSH a2
    NEXT

defprimitive "write-flash",11,write_flash,REGULAR
    DPOP a2                    // sector
    DPOP a3                    // buffer
    DPOP a4                    // size
    CCALL forth_flash_write
    DPUSH a2
    NEXT

defprimitive "spi-init",8,spi_init,REGULAR
    DPOP a2                    // bus
    DPOP a3                    // mode
    DPOP a4                    // freq_div
    DPOP a5                    // msb
    DPOP a6                    // endianness
    DPOP a7                    // minimal_pins
    CCALL forth_spi_init
    DPUSH a2
    NEXT

defprimitive "spi-send8",9,spi_send8,REGULAR
    DPOP a2                    // bus
    DPOP a3                    // data
    CCALL forth_spi_send8
    DPUSH a2
    NEXT

defprimitive "spi-send",8,spi_send,REGULAR
    DPOP a2                    // bus
    DPOP a3                    // out_data
    DPOP a4                    // in_data
    DPOP a5                    // size_data
    DPOP a6                    // word_size
    CCALL forth_spi_send
    DPUSH a2
    NEXT

defprimitive "wifi-set-mode",13,wifi_set_mode,REGULAR
    DPOP a2                    // mode
    CCALL forth_wifi_set_opmode
    DPUSH a2                   // c bool
    NEXT

defprimitive "wifi-set-station-config",23,wifi_set_station_config,REGULAR
    DPOP a2                    // ssid
    DPOP a3                    // password
    CCALL forth_wifi_set_station_config
    DPUSH a2                   // c bool
    NEXT

defprimitive "wifi-set-softap-config",22,wifi_set_softap_config,REGULAR
    DPOP a2                    // ssid
    DPOP a3                    // password
    DPOP a4                    // auth_mode
    DPOP a5                    // hidden
    DPOP a6                    // channels
    DPOP a7                    // max_connections
    CCALL forth_wifi_set_softap_config
    DPUSH a2                   // c bool
    NEXT

defprimitive "wifi-set-ip",11,wifi_set_ip,REGULAR
    DPOP a2                    // ipv4addr
    CCALL forth_wifi_set_ip
    NEXT

defprimitive "wifi-ip-str",11,wifi_ip_str,REGULAR
    DPOP a2                    // buffer
    DPOP a3                    // buffer size
    CCALL forth_wifi_get_ip_str
    NEXT

defprimitive "wifi-station-connect",20,wifi_station_connection,REGULAR
    CCALL forth_wifi_station_connect
    DPUSH a2                   // c bool
    NEXT

defprimitive "wifi-station-disconnect",23,wifi_station_disconnection,REGULAR
    CCALL forth_wifi_station_disconnect
    DPUSH a2                   // c bool
    NEXT

defprimitive "dhcpd-start",11,dhcp_start,REGULAR
    DPOP a2                    // first client ip
    DPOP a3                    // max leases 
    CCALL forth_dhcpd_start
    NEXT

defprimitive "dhcpd-stop",10,dhcp_stop,REGULAR
    CCALL forth_dhcpd_stop
    NEXT

defprimitive "push-enter",10,push_enter,REGULAR
    CCALL forth_push_enter
    NEXT

defprimitive "osfreemem",9,osfreemem,REGULAR
    CCALL forth_free_heap
    DPUSH a2                   // free heap size in bytes
    NEXT

defprimitive "us@",3,usat,REGULAR
    CCALL sdk_system_get_time
    DPUSH a2 // clock time in us
    NEXT

defprimitive "us",2,us,REGULAR
    DPOP a2                     // us to wait
    CCALL forth_delay_us
    NEXT

