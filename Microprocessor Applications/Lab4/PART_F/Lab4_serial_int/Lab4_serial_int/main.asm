;
; Lab4_serial_int.asm
;
; Created: 3/7/2016 8:55:31 AM
; Author : Adrian
; Section: 3189
; TA: Madison Emas
; Description: This program uses serial interrupts to echo a character back to the user (serial terminal)
;

.include"ATxmega128A1Udef.inc"

.equ stack = 0x3FFF
.equ CR = 0x0D
.equ LF = 0x0A
.equ ESC = 0x1B
.equ TAB = 0x09

.org 0x0000
	rjmp MAIN

.org USARTD0_RXC_VECT
	rjmp USART_RX_ISR

.org 0x0100
MAIN:
	ldi YL, low(stack) ; initiate stack pointer
	sts CPU_SPL, YL
	ldi YH, high(stack)
	sts CPU_SPH, YH

	rcall USART_GPIO_INIT ; initiate USART with interrupt driven Rx echo
	rcall USART_INIT

LOOP:
	rcall DELAY_370MS
	rjmp LOOP







/*****************************SUBROUTINE****************************************************
Name:     USART_INIT
Function: Initialize USARTD0 Tx and Rx capability as well as Rx interrupt
          Baud = 38,400 Hz, No parity
          1 start bit, 1 stop bit
Input:    None
Output:   None
Affected: USARTD0: _CTRLB, _CTRLC, _BAUDCTRLA, _BAUDCTRLB
*******************************************************************************************/
USART_INIT:

	.equ BSEL = 0x0121   ; 289 in hex
	.equ BSCALE = 0b1001 ; -7 in 2s compliment binary
	
	push R16

	ldi R16, 0x10 ;enable Rx interrupt
	sts USARTD0_CTRLA, R16

	ldi R16, 0x01 ;enable low level interrupts in PMIC
	sts PMIC_CTRL, R16

	ldi R16, 0x18 ; turn on Tx and Rx lines
	sts USARTD0_CTRLB, R16

	ldi R16, 0x03		; set async mode, Parity to none, 8 bit frame, 1 stop bit
	sts USARTD0_CTRLC, R16
	
	ldi R16, (BSEL & 0xFF) ; set lower 8 bits of BSEL in _BAUDCTRLA
	sts USARTD0_BAUDCTRLA, R16

	ldi R16, ((BSEL >> 8) & 0x0F) | ((BSCALE << 4) & 0xF0)	 ; upper nibble of _BAUDCTRLB are BSCALE and lower nibble is highest byte of BSEL	
	sts USARTD0_BAUDCTRLB, R16

	sei

	pop R16
	ret

/*****************************SUBROUTINE****************************************************
Name:     USART_GPIO_INIT
Function: Set PORTD_PIN3 as output (Tx) and _PIN2 for input (Rx)
		  Set PORTD_PIN2 and _PIN3 to USB by writing 0 to PORTQ bits 1 and 3
Input:    None
Output:   None
Affected: PORTD: _DIR, _OUT
		  PORTQ: _DIR, _OUT
*******************************************************************************************/
USART_GPIO_INIT:
	push R16

	ldi R16, 0x08			;set PORTD_PIN3 direction accordingly (Tx)
	sts PORTD_DIRSET, R16
	sts PORTD_OUTSET, R16	;set TX line to default to 1

	ldi R16, 0x04			;set PORTD_PIN2 direction (Rx)
	sts PORTD_DIRCLR, R16

	ldi R16, 0x0A			;enable PORTQ bits 1 and 3 and
	sts PORTQ_DIRSET, R16	;select PORTD pins2 and 3 as serial to USB
	sts PORTQ_OUTCLR, R16

	pop R16
	ret

/*****************************SUBROUTINE****************************************************
Name:     OUT_CHAR
Function: Transmit character passed into routine after checking DREF
Input:    Data to be transmitted in R16
Output:   Transmit Data
Affected: USARTD0: _STATUS, _DATA
*******************************************************************************************/
OUT_CHAR:
	push R17

POLL_DREIF:
	lds R17, USARTD0_STATUS	; copy USARTD0_STATUS into R17
	sbrs R17, 5 ; skip next instruction if bit 5 is set (DREIF)
	rjmp POLL_DREIF
	sts USARTD0_DATA, R16 ; put data in R16 into USARTD0_DATA register
	
	pop R17
	ret


/*****************************SUBROUTINE****************************************************
Name:     IN_CHAR
Function: Recieve character from PC terminal
Input:    Data from USARTD0 Rx pin
Output:   Data from PC into R16
Affected: USARTD0: _STATUS, _DATA
*******************************************************************************************/
IN_CHAR:

POLL_RXCIF:
	lds R16, USARTD0_STATUS ;copy USARTD0_STATUS into R16
	sbrs R16, 7 ; is RXCIF flag is set, skip next instruction
	rjmp POLL_RXCIF
	lds R16, USARTD0_DATA ;put recieved data(in USARTD0_DATA) in R16
	ret



/*****************************SUBROUTINE****************************************************
Name:     OUT_STRING
Function: Send string in data memory to PC terminal
Input:    Z pointer
Output:   String Data to PC terminal
Affected: USARTD0: _STATUS, _DATA
*******************************************************************************************/
OUT_STRING:
	push R17
	push R16

	ldi R17, 0x00

OUT_STRING_LOOP:
	lpm R16, Z+ ;load R16 with data at address pointed to by Z(post-inc)
	cp R16, R17
	breq OUT_STRING_END
	rcall OUT_CHAR
	;rcall DELAY_500US
	rjmp OUT_STRING_LOOP

OUT_STRING_END:
	pop R16
	pop R17
	ret

/*****************************SUBROUTINE****************************************************
Name:     USART_RX_ISR
Function: ISR for USART reciever, will echo back the value recieved
Input:    USARTD0_DATA =>R16
Output:   R16 => USARTD0_DATA => Terminal
Affected: USARTD0: _STATUS, _DATA
*******************************************************************************************/
USART_RX_ISR:

	rcall IN_CHAR
	rcall OUT_CHAR

	reti

/*******Delay 370 ms**************/
DELAY_370MS:
	push R16
	push R17
	push R18
	push R19

	ldi R16, 0x00
	ldi R17, 0x00
	ldi R18, 0x00
	ldi R19, 0x34	
DELAY_370MS_LOOP1:
	cp R16, R19
	breq DELAY_370MS_LOOP2
	inc R16
	rjmp DELAY_370MS_LOOP1

DELAY_370MS_LOOP2:
	cp R17, R19
	breq DELAY_370MS_LOOP3
	inc R17
	clr R16
	rjmp DELAY_370MS_LOOP1

DELAY_370MS_LOOP3:
	cp R18, R19
	breq DELAY_370MS_END
	inc R18
	clr R16
	clr R17
	rjmp DELAY_370MS_LOOP1

DELAY_370MS_END:
	pop R19
    pop R18
	pop R17
	pop R16
	ret