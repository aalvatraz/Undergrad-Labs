;
;Lab4_serial.asm
;Name: Adrian Alvarez
;Section: 3189
;TA:Madison Emas
;Description: This program contains subroutines for asynchronous serial communication

.include "ATxmega128A1Udef.inc"
.equ stack = 0x3FFF


.org 0x0000
	rjmp MAIN

.org 0x0100
MAIN:

	ldi YL, low(stack)	;initialize stack pointer
	sts CPU_SPL, YL
	ldi YH, high(stack)
	sts CPU_SPH, YH

	rcall USART_GPIO_INIT	;initiate USART
	rcall USART_INIT

MAIN_LOOP:
	rcall IN_CHAR
	rcall OUT_CHAR
	rjmp MAIN_LOOP



/*****************************SUBROUTINE****************************************************
Name:     USART_INIT
Function: Initialize USARTD0 Tx and Rx capability 
          Baud = 38,400 Hz, No parity
          1 start bit, 1 stop bit
		  puts test data in 0x2000 (data memory)
Input:    None
Output:   None
Affected: USARTD0: _CTRLB, _CTRLC, _BAUDCTRLA, _BAUDCTRLB
*******************************************************************************************/
USART_INIT:

	.equ BSEL = 289
	.equ BSCALE = -7
	
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
	ld R16, Z+ ;load R16 with data at address pointed to by Z
	rcall OUT_CHAR
	cp R16, R17
	brne OUT_STRING_LOOP

	pop R16
	pop R17
	ret

