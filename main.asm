;
; LDCScreen.asm
;
; Created: 25-Nov-17 11:42:27 AM
; Author : Root
;

.equ    F_CPU               = 16000000      ; system clock frequency
.equ	BAUD				= 9600			; Baud rate
.equ	UBRRVAL				= (F_CPU / (BAUD * 16)) - 1

.def    temp                = R16           ; temporary storage
.def	data				= R17			; read data from serial monitor

.equ    lcd_E_port          = PORTB         ; lcd Enable pin
.equ    lcd_E_bit           = PORTB3
.equ    lcd_E_ddr           = DDRB

.equ    lcd_RS_port         = PORTB         ; lcd Register Select pin
.equ    lcd_RS_bit          = PORTB2
.equ    lcd_RS_ddr          = DDRB

.equ    lcd_D7_port         = PORTB         ; lcd D7 connection
.equ    lcd_D7_bit          = PORTB1
.equ    lcd_D7_ddr          = DDRB

.equ    lcd_D6_port         = PORTB         ; lcd D6 connection
.equ    lcd_D6_bit          = PORTB0
.equ    lcd_D6_ddr          = DDRB

.equ    lcd_D5_port         = PORTD         ; lcd D5 connection
.equ    lcd_D5_bit          = PORTD7
.equ    lcd_D5_ddr          = DDRD

.equ    lcd_D4_port         = PORTD         ; lcd D4 connection
.equ    lcd_D4_bit          = PORTD6
.equ    lcd_D4_ddr          = DDRD

.equ    lcd_D3_port         = PORTD         ; lcd D3 connection
.equ    lcd_D3_bit          = PORTD5
.equ    lcd_D3_ddr          = DDRD

.equ    lcd_D2_port         = PORTD         ; lcd D2 connection
.equ    lcd_D2_bit          = PORTD4
.equ    lcd_D2_ddr          = DDRD

.equ    lcd_D1_port         = PORTD         ; lcd D1 connection
.equ    lcd_D1_bit          = PORTD3
.equ    lcd_D1_ddr          = DDRD

.equ    lcd_D0_port         = PORTD         ; lcd D0 connection
.equ    lcd_D0_bit          = PORTD2
.equ    lcd_D0_ddr          = DDRD

; LCD module information
.equ    lcd_LineOne         = 0x00          ; start of line 1
.equ    lcd_LineTwo         = 0x40          ; start of line 2

; LCD instructions
.equ    lcd_Clear           = 0b00000001    ; replace all characters with ASCII 'space'
.equ    lcd_Home            = 0b00000010    ; return cursor to first position on first line
.equ    lcd_EntryMode       = 0b00000110    ; shift cursor from left to right on read/write
.equ    lcd_DisplayOff      = 0b00001000    ; turn display off
.equ    lcd_DisplayOn       = 0b00001100    ; display on, cursor off, don't blink character
.equ    lcd_FunctionReset   = 0b00110000    ; reset the LCD
.equ    lcd_FunctionSet8bit = 0b00111000    ; 8-bit data, 2-line display, 5 x 7 font
.equ    lcd_SetCursor       = 0b10000000    ; set cursor position

.DSEG
;.org	 0x200
read_string:	.BYTE		16				; array of 16 bytes

.CSEG
.org	0x0000
rjmp		start

; ****************************** Main Program Code **************************
start:
; initialize the stack pointer to the highest RAM address
    ldi     temp, LOW(RAMEND)
    out     SPL, temp
    ldi     temp, HIGH(RAMEND)
    out     SPH, temp
	
; configure the microprocessor pins for the data lines
    sbi     lcd_D7_ddr, lcd_D7_bit          ; 8 data lines - output
    sbi     lcd_D6_ddr, lcd_D6_bit
    sbi     lcd_D5_ddr, lcd_D5_bit
    sbi     lcd_D4_ddr, lcd_D4_bit
    sbi     lcd_D3_ddr, lcd_D3_bit
    sbi     lcd_D2_ddr, lcd_D2_bit
    sbi     lcd_D1_ddr, lcd_D1_bit
    sbi     lcd_D0_ddr, lcd_D0_bit

; configure the microprocessor pins for the control lines
    sbi     lcd_E_ddr,  lcd_E_bit           ; E line - output
    sbi     lcd_RS_ddr, lcd_RS_bit          ; RS line - output

; initialize the LCD controller 
    call    lcd_init						; initialize the LCD display for an 8-bit interface

; initialize the serial communication
	call	serial_init						; initialize serial communication with 9600 baudrate

; display the first line of information
    ;ldi     ZH, high(read_string)			; point to the information that is to be displayed
    ;ldi     ZL, low(read_string)
    ;ldi     temp, lcd_LineOne               ; point to where the information should be displayed
    ;call    lcd_write_string

; display the second line of information
    ;ldi     ZH, high(program_version)       ; point to the information that is to be displayed
    ;ldi     ZL, low(program_version)
    ;ldi     temp, lcd_LineTwo               ; point to where the information should be displayed
    ;call    lcd_write_string_8d

; endless loop
main:
	ldi		XH, high(read_string)			; initialize the pointer to the beginning of array
	ldi		XL, low(read_string)
	ldi		r18, 0

	call	serial_read						; read a string from serial monitor

	ldi     temp, lcd_Clear                 ; clear display RAM
    call    lcd_write_instruction
    ldi     temp, 4                         ; 1.64 mS delay
    call    delayTx1mS

	ldi		ZH, HIGH(read_string)			; point to where the information is
	ldi		ZL, LOW(read_string)

	ldi		temp, lcd_LineOne				; point to the line that should be displayed to

	call	lcd_write_string				; call the write procedure

    rjmp    main							; loop endlessly

; ****************************** End of Main Program Code *******************

; ============================== Serial Communication Subroutines ===========

serial_init:
; Initialize baudrate
	ldi		temp, LOW(UBRRVAL)
	sts		UBRR0L, temp
	ldi		temp, HIGH(UBRRVAL)
	sts		UBRR0H, temp

; Enable receiver and transmitter
	ldi		temp, (1 << RXEN0) | (1 << TXEN0)
	sts		UCSR0B, temp

; Set frame format: 8-bit, 2 stop bits	ldi		temp, (1 << USBS0) | (3 << UCSZ00)	sts		UCSR0C, temp
	ret

; ---------------------------------------------------------------------------

serial_receive:
	; Wait for data to be received
	lds		temp, UCSR0A
	sbrs	temp, RXC0
	rjmp	serial_receive
	; Get received data from buffer
	lds		data, UDR0
	ret

; ---------------------------------------------------------------------------

serial_transmit:
	; Wait for empty transmit buffer
	lds		temp, UCSR0A
	sbrs	temp, UDRE0
	rjmp	serial_transmit
	; Put data into buffer and send it
	sts		UDR0, data
	ret

; ---------------------------------------------------------------------------

serial_read:
	call	serial_receive

	cpi		data, '\n'
	breq	serial_read_1
	st		X+, data
	inc		r18
	cpi		r18, 16
	brlo	serial_read

	serial_read_1:
	ldi		data, 0
	st		X, data
	ret

; ============================== End of Serial Communication Subroutines ====

; ============================== 8-bit LCD Subroutines ======================

lcd_init:
; Power-up delay
    ldi     temp, 100                       ; initial 40 mSec delay
    call    delayTx1mS

; Reset the LCD controller.
    ldi     temp, lcd_FunctionReset         ; first part of reset sequence
    call    lcd_write_instruction
    ldi     temp, 10                        ; 4.1 mS delay (min)
    call    delayTx1mS

    ldi     temp, lcd_FunctionReset         ; second part of reset sequence
    call    lcd_write_instruction
    ldi     temp, 200                       ; 100 uS delay (min)
    call    delayTx1uS

    ldi     temp, lcd_FunctionReset         ; third part of reset sequence
    call    lcd_write_instruction
    ldi     temp, 200                       
    call    delayTx1uS

; Function Set instruction
    ldi     temp, lcd_FunctionSet8bit       ; set mode, lines, and font
    call    lcd_write_instruction
    ldi     temp, 80                        ; 40 uS delay (min)
    call    delayTx1uS

; Display On/Off Control instruction - turns OFF the display
    ldi     temp, lcd_DisplayOff            ; turn display OFF
    call    lcd_write_instruction
    ldi     temp, 80                        ; 40 uS delay (min)
    call    delayTx1uS

; Clear Display instruction
    ldi     temp, lcd_Clear                 ; clear display RAM
    call    lcd_write_instruction
    ldi     temp, 4                         ; 1.64 mS delay (min)
    call    delayTx1mS

; Entry Mode Set instruction
    ldi     temp, lcd_EntryMode             ; set desired shift characteristics
    call    lcd_write_instruction
    ldi     temp, 80                        ; 40 uS delay (min)
    call    delayTx1uS

; Display On/Off Control instruction - turns ON the display
    ldi     temp, lcd_DisplayOn             ; turn the display ON
    call    lcd_write_instruction
    ldi     temp, 80                        ; 40 uS delay (min)
    call    delayTx1uS
    ret

; ---------------------------------------------------------------------------

lcd_write_string:
; preserve registers
    push    ZH                              ; preserve pointer registers
    push    ZL

; fix up the pointers for use with the 'lpm' instruction
    ;lsl     ZL                              ; shift the pointer one bit left for the lpm instruction
    ;rol     ZH

; set up the initial DDRAM address
    ori     temp, lcd_SetCursor             ; convert the plain address to a set cursor instruction
    call    lcd_write_instruction	        ; set up the first DDRAM address
    ldi     temp, 80                        ; 40 uS delay (min)
    call    delayTx1uS

; write the string of characters
lcd_write_string_01:
    ld      temp, Z+                        ; get a character
    cpi     temp,  0                        ; check for end of string
    breq    lcd_write_string_02				; done

; arrive here if this is a valid character
    call    lcd_write_character				; display the character
    ldi     temp, 80                        ; 40 uS delay (min)
    call    delayTx1uS
    rjmp    lcd_write_string_01				; not done, send another character

; arrive here when all characters in the message have been sent to the LCD module
lcd_write_string_02:
    pop     ZL                              ; restore pointer registers
    pop     ZH
    ret

; ---------------------------------------------------------------------------

lcd_write_character:
    sbi     lcd_RS_port, lcd_RS_bit         ; select the Data Register (RS high)
    cbi     lcd_E_port, lcd_E_bit           ; make sure E is initially low
    call    lcd_write						; write the data
    ret

; ---------------------------------------------------------------------------

lcd_write_instruction:
    cbi     lcd_RS_port, lcd_RS_bit         ; select the Instruction Register (RS low)
    cbi     lcd_E_port, lcd_E_bit           ; make sure E is initially low
    call    lcd_write						; write the instruction
    ret

; ---------------------------------------------------------------------------

lcd_write:
; set up the data bits
    sbi     lcd_D7_port, lcd_D7_bit         ; assume that the data bit is '1'
    sbrs    temp, 7                         ; check the actual data value
    cbi     lcd_D7_port, lcd_D7_bit         ; arrive here only if the data was actually '0'

    sbi     lcd_D6_port, lcd_D6_bit         ; repeat for each data bit
    sbrs    temp, 6
    cbi     lcd_D6_port, lcd_D6_bit

    sbi     lcd_D5_port, lcd_D5_bit
    sbrs    temp, 5
    cbi     lcd_D5_port, lcd_D5_bit

    sbi     lcd_D4_port, lcd_D4_bit
    sbrs    temp, 4
    cbi     lcd_D4_port, lcd_D4_bit

    sbi     lcd_D3_port, lcd_D3_bit
    sbrs    temp, 3
    cbi     lcd_D3_port, lcd_D3_bit

    sbi     lcd_D2_port, lcd_D2_bit
    sbrs    temp, 2
    cbi     lcd_D2_port, lcd_D2_bit

    sbi     lcd_D1_port, lcd_D1_bit
    sbrs    temp, 1
    cbi     lcd_D1_port, lcd_D1_bit

    sbi     lcd_D0_port, lcd_D0_bit
    sbrs    temp, 0
    cbi     lcd_D0_port, lcd_D0_bit

; write the data
                                            ; 'Address set-up time' (40 nS)
    sbi     lcd_E_port, lcd_E_bit           ; Enable pin high
    call    delay1uS                        ; implement 'Data set-up time' (80 nS) and 'Enable pulse width' (230 nS)
    cbi     lcd_E_port, lcd_E_bit           ; Enable pin low
    call    delay1uS                        ; implement 'Data hold time' (10 nS) and 'Enable cycle time' (500 nS)
    ret

; ============================== End of 8-bit LCD Subroutines ===============

; ============================== Time Delay Subroutines =====================

delayYx1mS:
    call    delay1mS                        ; delay for 1 mS
    sbiw    YH:YL, 1                        ; update the the delay counter
    brne    delayYx1mS                      ; counter is not zero

; arrive here when delay counter is zero (total delay period is finished)
    ret

; ---------------------------------------------------------------------------

delayTx1mS:
    call    delay1mS                        ; delay for 1 mS
    dec     temp                            ; update the delay counter
    brne    delayTx1mS                      ; counter is not zero

; arrive here when delay counter is zero (total delay period is finished)
    ret

; ---------------------------------------------------------------------------

delay1mS:
    push    YL                              ; preserve registers
    push    YH                              ; 
    ldi     YL, low (((F_CPU/1000)-18)/4)   ; delay counter
    ldi     YH, high(((F_CPU/1000)-18)/4)   ; 

delay1mS_01:
    sbiw    YH:YL, 1                        ; update the the delay counter
    brne    delay1mS_01                     ; delay counter is not zero

; arrive here when delay counter is zero
    pop     YH                              ; restore registers
    pop     YL                              ; 
    ret                                     ; 

; ---------------------------------------------------------------------------

delayTx1uS:
    call    delay1uS                        ; delay for 1 uS
    dec     temp                            ; decrement the delay counter
    brne    delayTx1uS                      ; counter is not zero

; arrive here when delay counter is zero (total delay period is finished)
    ret

; ---------------------------------------------------------------------------

delay1uS:
    push    temp                            ;  these instructions do nothing except consume clock cycles
    pop     temp                            ; 
    push    temp                            ; 
    pop     temp                            ; 
    ret                                     ; 

; ============================== End of Time Delay Subroutines ==============