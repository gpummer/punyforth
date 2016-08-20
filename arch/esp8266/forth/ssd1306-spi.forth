\ ssd1306 SPI display driver

\ define the wiring
14 constant: SCL  \ SCL D5 leg
13 constant: SDA  \ SDA D7 leg
2  constant: DC   \ DC  D4 leg
0  constant: RST  \ RST D3 leg
1  constant: BUS

141 constant: SSD1306_CHARGE_PUMP_REGULATOR
20  constant: SSD1306_CHARGE_PUMP_ON
129 constant: SSD1306_SET_CONTRAST
164 constant: SSD1306_RESUME_TO_RAM_CONTENT
165 constant: SSD1306_IGNORE_RAM_CONTENT
166 constant: SSD1306_DISP_NORMAL
167 constant: SSD1306_DISP_INVERTED
174 constant: SSD1306_DISP_SLEEP
175 constant: SSD1306_DISP_ON

\ Scroll commands
38  constant: SSD1306_SCROLL_RIGHT
39  constant: SSD1306_SCROLL_LEFT
41  constant: SSD1306_SCROLL_VERTICAL_RIGHT
42  constant: SSD1306_SCROLL_VERTICAL_LEFT
46  constant: SSD1306_SCROLL_OFF
47  constant: SSD1306_SCROLL_ON
163 constant: SSD1306_VERT_SCROLL_AREA

\ Address setting commands
0   constant: SSD1306_SET_COL_LO_NIBBLE
16  constant: SSD1306_SET_COL_HI_NIBBLE
32  constant: SSD1306_MEM_ADDRESSING
33  constant: SSD1306_SET_COL_ADDR
34  constant: SSD1306_SET_PAGE_ADDR
176 constant: SSD1306_SET_PAGE_START_ADDR

\ Hardware configuration
64  constant: SSD1306_SET_DISP_START_LINE
160 constant: SSD1306_SET_SEG_REMAP_0
161 constant: SSD1306_SET_SEG_REMAP_127
168 constant: SSD1306_SET_MULTIPLEX_RATIO
192 constant: SSD1306_SET_COM_SCAN_NORMAL
200 constant: SSD1306_SET_COM_SCAN_INVERTED
211 constant: SSD1306_SET_VERTICAL_OFFSET
218 constant: SSD1306_SET_WIRING_SCHEME
213 constant: SSD1306_SET_DISP_CLOCK
217 constant: SSD1306_SET_PRECHARGE_PERIOD
219 constant: SSD1306_SET_VCOM_DESELECT_LEVEL
227 constant: SSD1306_NOP

0 constant: SPI_MODE0
1 constant: SPI_MODE1
2 constant: SPI_MODE2
3 constant: SPI_MODE3

1 constant: SPI_WORD_SIZE_8BIT
2 constant: SPI_WORD_SIZE_16BIT
4 constant: SPI_WORD_SIZE_32BIT

0 constant: SPI_LITTLE_ENDIAN
1 constant: SPI_BIG_ENDIAN

: spi-get-freq-div ( divider count -- freq ) 16 lshift swap 65535 and or ;
    
64 10 spi-get-freq-div constant: SPI_FREQ_DIV_125K  \ < 125kHz
32 10 spi-get-freq-div constant: SPI_FREQ_DIV_250K  \ < 250kHz
16 10 spi-get-freq-div constant: SPI_FREQ_DIV_500K  \ < 500kHz
8  10 spi-get-freq-div constant: SPI_FREQ_DIV_1M    \ < 1MHz
4  10 spi-get-freq-div constant: SPI_FREQ_DIV_2M    \ < 2MHz
2  10 spi-get-freq-div constant: SPI_FREQ_DIV_4M    \ < 4MHz
5  2  spi-get-freq-div constant: SPI_FREQ_DIV_8M    \ < 8MHz
4  2  spi-get-freq-div constant: SPI_FREQ_DIV_10M   \ < 10MHz
2  2  spi-get-freq-div constant: SPI_FREQ_DIV_20M   \ < 20MHz
1  2  spi-get-freq-div constant: SPI_FREQ_DIV_40M   \ < 40MHz
1  1  spi-get-freq-div constant: SPI_FREQ_DIV_80M   \ < 80MHz

127 constant: DEFAULT_CONTRAST

128 constant: DISPLAY_WIDTH
64  constant: DISPLAY_HEIGHT

exception: ESSD1306
exception: ESSD1306_WRITE

DISPLAY_WIDTH DISPLAY_HEIGHT * 8 / constant: BUFFER_SIZE

\ display buffers
BUFFER_SIZE byte-array: screen-ary1
BUFFER_SIZE byte-array: screen-ary2
BUFFER_SIZE byte-array: screen-output

' screen-ary1 init-variable: var-screen-ary1
' screen-ary2 init-variable: var-screen-ary2
: screen1 ( index -- addr ) var-screen-ary1 @ execute ;
: screen2 ( index -- addr ) var-screen-ary2 @ execute ;

: display-setup-wiring
    DC GPIO_OUT gpio-mode
    RST GPIO_OUT gpio-mode
    DC  GPIO_LOW gpio-write
    RST GPIO_LOW gpio-write ;

: check-write-result ( code -- | ESSD1306_WRITE )
    255 <> if 
        ESSD1306_WRITE throw 
    then ;

: write-command ( cmd -- | ESSD1306_WRITE ) 
    DC GPIO_LOW gpio-write
    BUS spi-send8 
    check-write-result ;

: write-data ( data -- | ESSD1306_WRITE ) 
    DC GPIO_HIGH gpio-write
    BUS spi-send8 
    check-write-result ;

: display-on ( -- )
    RST GPIO_HIGH gpio-write
    1 ms
    RST GPIO_LOW gpio-write
    10 ms
    RST GPIO_HIGH gpio-write ;

: display-send-init-sequence ( -- )
    SSD1306_DISP_SLEEP              write-command
    SSD1306_SET_DISP_CLOCK          write-command
    128                             write-command
    SSD1306_SET_MULTIPLEX_RATIO     write-command
    63                              write-command
    SSD1306_SET_VERTICAL_OFFSET     write-command
    0                               write-command
    SSD1306_SET_DISP_START_LINE     write-command
    SSD1306_CHARGE_PUMP_REGULATOR   write-command
    SSD1306_CHARGE_PUMP_ON          write-command
    SSD1306_MEM_ADDRESSING          write-command
    0                               write-command
    SSD1306_SET_SEG_REMAP_0         write-command
    SSD1306_SET_COM_SCAN_NORMAL     write-command
    SSD1306_SET_WIRING_SCHEME       write-command
    18                              write-command
    SSD1306_SET_VCOM_DESELECT_LEVEL write-command
    64                              write-command
    SSD1306_RESUME_TO_RAM_CONTENT   write-command
    SSD1306_DISP_NORMAL             write-command
    SSD1306_DISP_ON                 write-command ;

: display-reset ( -- )
    33 write-command
    0 write-command
    127 write-command
    34 write-command
    0 write-command
    7 write-command 
    1025 0 do 0 write-data loop ;

: xchg-screen ( -- ) 
    var-screen-ary2 @
    var-screen-ary1 @ var-screen-ary2 !
    var-screen-ary1 ! ;    

: y>bitmask ( y -- bit-index )
    7 and
    1 swap lshift ;

: xy>buffer-pos ( x y -- bit-mask array-index )
    dup 
    y>bitmask -rot
    3 rshift            \  8 /
    7 lshift + ;        \  DISPLAY_WIDTH * +

: or! ( value addr -- )
    tuck c@ or swap c! ;

: and! ( value addr -- )
    tuck c@ and swap c! ;

: set-pixel ( x y -- )    
    xy>buffer-pos screen1 or! ;

: unset-pixel ( x y -- ) 
    xy>buffer-pos screen1 
    swap invert swap and! ;

: pixel-set? ( x y -- )
    xy>buffer-pos screen1
    c@ and 0<> ;

: fill-screen-buffer ( value -- ) 
    BUFFER_SIZE 0 do 
        dup i screen1 c! 
    loop 
    drop ;

: show-screen-buffer ( -- )
    SPI_WORD_SIZE_8BIT
    BUFFER_SIZE
    0 screen-output
    0 screen1
    BUS 
    spi-send BUFFER_SIZE <> if
        ESSD1306 throw
    then ;

: display-clear ( -- )
    0 fill-screen-buffer
    show-screen-buffer ;

: truncate-xy ( x y -- x' y' )
    swap 127 and 
    swap 63 and ;

: display-init ( -- | ESSD1306 )
    display-setup-wiring
    TRUE SPI_BIG_ENDIAN TRUE SPI_FREQ_DIV_4M SPI_MODE0 BUS 
    spi-init 1 <> if
        ESSD1306 throw
    then
    display-on
    display-send-init-sequence
    display-reset ;
