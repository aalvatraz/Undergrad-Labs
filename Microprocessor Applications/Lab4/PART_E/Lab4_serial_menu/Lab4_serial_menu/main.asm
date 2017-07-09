;
; Lab4_serial_menu.asm
;Name: Adrian Alvarez
;Section: 3189
;TA:Madison Emas
;Description: This program contains creates a serial menu via the xmega USART system

.include "ATxmega128A1Udef.inc"
.equ stack = 0x3FFF
.equ CR = 0x0D
.equ LF = 0x0A
.equ ESC = 0x1B
.equ TAB = 0x09

.cseg
.org 0x0000
	rjmp MAIN

.org 0x0100
;data table for menu
MENU:
	.db 'A', 'd', 'r', 'i', 'a', 'n', ''', 's', ' ', 'f', 'a', 'v', 'o', 'r', 'i', 't', 'e', ' ', ':', CR, LF, CR, LF, '1', '.', TAB, 'B', 'o', 'o', 'k', CR, LF, CR, LF, '2', '.', TAB, 'P', 'i', 'z', 'z', 'a', ' ', 't', 'o', 'p', 'p', 'i', 'n', 'g', 's', CR, LF, CR, LF, '3', '.', TAB, 'I', 'c', 'e', ' ', 'c', 'r', 'e', 'a', 'm', '/', 'y', 'o', 'g', 'u', 'r', 't', ' ', 'f', 'l', 'a', 'v', 'o', 'r', CR, LF, CR, LF, '4', '.', TAB, 'F', 'o', 'o', 'd', CR, LF, CR, LF, '5', '.', TAB, 'A', 'c', 't', 'o', 'r', '/', 'A', 'c', 't', 'r', 'e', 's', 's', '/', 'R', 'e', 'a', 'l', 'i', 't', 'y', ' ', '"', 'S', 't', 'a', 'r', '"', CR, LF, CR, LF, '6', '.', TAB, 'R', 'e', '-', 'd', 'i', 's', 'p', 'l', 'a', 'y', ' ', 'm', 'e', 'n', 'u', CR, LF, CR, LF, 'E', 'S', 'C', ':', ' ', 'e', 'x', 'i', 't', CR, LF, CR, LF, 0x00

;favorite book
BOOK:
	.db 'A', 'd', 'r', 'i', 'a', 'n', ''', 's', ' ', 'f', 'a', 'v', 'o', 'r', 'i', 't', 'e', ' ', 'b', 'o', 'o', 'k', ' ', 'i', 's', ' ', 'T', 'h', 'e', ' ', 'H', 'o', 'b', 'b', 'i', 't', CR, LF, CR, LF, 0x00

;favorite pizza topping
PIZZA:
	.db 'A', 'd', 'r', 'i', 'a', 'n', ''', 's', ' ', 'f', 'a', 'v', 'o', 'r', 'i', 't', 'e', ' ', 'p', 'i', 'z', 'z', 'a', ' ', 't', 'o', 'p', 'p', 'i', 'n', 'g', ' ', 'i', 's', ' ','P', 'e', 'p', 'p', 'e', 'r', 'o', 'n', 'i', CR, LF, CR, LF, 0x00

;favorite ice-cream flavor
FLAVOR:
	.db 'A', 'd', 'r', 'i', 'a', 'n', ''', 's', ' ', 'f', 'a', 'v', 'o', 'r', 'i', 't', 'e', ' ', 'i', 'c', 'e', ' ', 'c', 'r', 'e', 'a', 'm', '/', 'y', 'o', 'g', 'u', 'r', 't', ' ', 'f', 'l', 'a', 'v', 'o', 'r', ' ', 'i', 's', ' ', 'H', 'o', 't', ' ', 'f', 'u', 'd', 'g', 'e', ' ', 's', 'u', 'n', 'd', 'a', 'e', CR, LF, CR, LF, 0x00
;favorite food
FOOD:
	.db 'A', 'd', 'r', 'i', 'a', 'n', ''', 's', ' ', 'f', 'a', 'v', 'o', 'r', 'i', 't', 'e', ' ', 'f', 'o', 'o', 'd', ' ', 'i', 's', ' ', 'M', 'o', 'f', 'o', 'n', 'g', 'o', CR, LF, CR, LF, 0x00
;favorite actor
ACTOR:
	.db 'A', 'd', 'r', 'i', 'a', 'n', ''', 's', ' ', 'f', 'a', 'v', 'o', 'r', 'i', 't', 'e', ' ', 'a', 'c', 't', 'o', 'r', ' ', 'i', 's', ' ','S', 't', 'e', 'v', 'e', ' ', 'C', 'a', 'r', 'r', 'e', 'l', 'l', CR, LF, CR, LF, 0x00

MAIN:
	;initialize stack pointer
	ldi YL, low(stack)
	sts CPU_SPL, YL
	ldi YH, high(stack)
	sts CPU_SPH, YH

	;initialize USARTD0 and USART GPIO necessary so asynchronous serial communication
	rcall USART_GPIO_INIT
	rcall USART_INIT

	;load R17 with ESC 
	ldi R17, ESC

MAIN_LOOP:
	;display MENU
	ldi ZL, low(MENU<<1)
	ldi ZH, high(MENU<<1)
	rcall OUT_STRING

	rcall IN_CHAR
	cp R16, R17
	breq MAIN_TERMINATE
	rcall SORT
	rcall OUT_STRING
	rjmp MAIN_LOOP

MAIN_TERMINATE:
	rjmp MAIN_TERMINATE


		




/*****************************SUBROUTINE****************************************************
Name:     USART_INIT
Function: Initialize USARTD0 Tx and Rx capability 
          Baud = 38,400 Hz, No parity
          1 start bit, 1 stop bit
Input:    None
Output:   None
Affected: USARTD0: _CTRLB, _CTRLC, _BAUDCTRLA, _BAUDCTRLB
*******************************************************************************************/
USART_INIT:

	.equ BSEL = 0x0121   ; 289 in hex
	.equ BSCALE = 0b1001 ; -7n in 2s compliment binary
	
	push R16

	ldi R16, 0x18 ; turn on Tx and Rx lines
	sts USARTD0_CTRLB, R16

	ldi R16, 0x03		; set async mode, Parity to none, 8 bit frame, 1 stop bit
	sts USARTD0_CTRLC, R16
	
	ldi R16, (BSEL & 0xFF) ; set lower 8 bits of BSEL in _BAUDCTRLA
	sts USARTD0_BAUDCTRLA, R16

	ldi R16, ((BSEL >> 8) & 0x0F) | ((BSCALE << 4) & 0xF0)	 ; upper nibble of _BAUDCTRLB are BSCALE and lower nibble is highest byte of BSEL	
	sts USARTD0_BAUDCTRLB, R16

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
	sbrs R17, 5 ; skip next instructio if bit 5 is set (DREIF)
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
Name:     DELAY_500US
Function: Delay for 500 us
Input:    none
Output:   none
Affected: none
*******************************************************************************************/
DELAY_500US:
	push R16
	push R17

	ldi R16, 0x00
	ldi R17, 0xC8
	
DELAY_500US_LOOP:
	cp R16, R17
	breq DELAY_500US_END
	inc R16
	rjmp DELAY_500US_LOOP

DELAY_500US_END:
	pop R17
	pop R16
	ret

	ret

/*****************************SUBROUTINE****************************************************
Name:     SORT
Function: Sort input data from IN_CHAR, load appropriate pointer into Z
Input:    R16
Output:   Z
Affected: Z
*******************************************************************************************/
SORT:
	push R17

	;sort input value in R16
	ldi R17, '1'
	cp R16, R17
	breq BOOK_ANS
	inc R17
	cp R16, R17
	breq PIZZA_ANS
	inc R17
	cp R16, R17
	breq FLAVOR_ANS
	inc R17
	cp R16, R17
	breq FOOD_ANS
	inc R17
	cp R16, R17
	breq ACTOR_ANS
	inc R17
	cp R16, R17
	breq REDISPLAY
	rjmp SORT_END

;load Z with BOOK pointer
BOOK_ANS:
	ldi ZL, low(BOOK<<1)
	ldi ZH, high(BOOK<<1)
	rjmp SORT_END

;load Z with PIZZA pointer
PIZZA_ANS:
	ldi ZL, low(PIZZA<<1)
	ldi ZH, high(PIZZA<<1)
	rjmp SORT_END

;load Z with FLAVOR pointer
FLAVOR_ANS:
	ldi ZL, low(FLAVOR<<1)
	ldi ZH, high(FLAVOR<<1)
	rjmp SORT_END

;load Z with FOOD pointer
FOOD_ANS:
	ldi ZL, low(FOOD<<1)
	ldi ZH, high(FOOD<<1)
	rjmp SORT_END

;load Z with ACTOR pointer
ACTOR_ANS:
	ldi ZL, low(ACTOR<<1)
	ldi ZH, high(ACTOR<<1)
	rjmp SORT_END

;load Z with MENU pointer
REDISPLAY:
	ldi ZL, low(MENU<<1)
	ldi ZH, high(MENU<<1)
	rjmp SORT_END

SORT_END:
	pop R17
	ret
	