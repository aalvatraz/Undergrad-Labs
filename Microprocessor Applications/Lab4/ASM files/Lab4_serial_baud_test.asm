;
;Lab4_serial.asm
;Name: Adrian Alvarez
;Section: 3189
;TA:Madison Emas
;Description: This program contains subroutines for asynchronous serial communication

.include "ATxmega128A1Udef.inc"
.equ stack = 0x3FFF

.cseg
.org 0x0000
	rjmp MAIN

.org 0x0100
MAIN:
	;initialize stack pointer
	ldi YL, low(stack)
	sts CPU_SPL, YL
	ldi YH, high(stack)
	sts CPU_SPH, YH
	


	;initialize USARTD0 and USART GPIO necessary so asynchronous serial communication
	rcall USART_GPIO_INIT
	rcall USART_INIT

MAIN_LOOP:
	
	ldi R16, 'U'			;load R16 with 'U' character
	rcall OUT_CHAR			; send 'U' via USART
	rcall DELAY_500US		; delay by 500US
	rjmp MAIN_LOOP			; loop forever

		




/*****************************SUBROUTINE****************************************************
Name:     USART_INIT
Function: Initialize USARTD0 Tx and Rx capability 
          Baud = 38,400 Hz, No parity
          1 start bit, 1 stop bit
Input:    None
Output:   None
Affected: USARTE0: _CTRLB, _CTRLC, _BAUDCTRLA, _BAUDCTRLB
*******************************************************************************************/
USART_INIT:

	.equ BSEL = 0x0121   ; 289 in hex
	.equ BSCALE = 0b1001 ; -7n in 2s compliment binary
	
	push R16

	ldi R16, 0x18 ; turn on Tx and Rx lines
	sts USARTE0_CTRLB, R16

	ldi R16, 0x03		; set async mode, Parity to none, 8 bit frame, 1 stop bit
	sts USARTE0_CTRLC, R16
	
	ldi R16, (BSEL & 0xFF) ; set lower 8 bits of BSEL in _BAUDCTRLA
	sts USARTE0_BAUDCTRLA, R16

	ldi R16, ((BSEL >> 8) & 0x0F) | ((BSCALE << 4) & 0xF0)	 ; upper nibble of _BAUDCTRLB are BSCALE and lower nibble is highest byte of BSEL	
	sts USARTE0_BAUDCTRLB, R16

	pop R16
	ret

/*****************************SUBROUTINE****************************************************
Name:     USART_GPIO_INIT
Function: Set PORTD_PIN3 as output (Tx) and _PIN2 for input (Rx)
		  Set PORTD_PIN2 and _PIN3 to USB by writing 0 to PORTQ bits 1 and 3
Input:    None
Output:   None
Affected: PORTE: _DIR, _OUT
*******************************************************************************************/
USART_GPIO_INIT:
	push R16

	ldi R16, 0x08			;set PORTD_PIN3 direction accordingly (Tx)
	sts PORTE_DIRSET, R16
	sts PORTE_OUTSET, R16	;set TX line to default to 1

	ldi R16, 0x04			;set PORTD_PIN2 direction (Rx)
	sts PORTE_DIRCLR, R16

	;ldi R16, 0x0A			;enable PORTQ bits 1 and 3 and
	;sts PORTQ_DIRSET, R16	;select PORTD pins2 and 3 as serial to USB
	;sts PORTQ_OUTCLR, R16

	pop R16
	ret
/*****************************SUBROUTINE****************************************************
Name:     OUT_CHAR
Function: Transmit character passed into routine after checking DREF
Input:    Data to be transmitted in R16
Output:   Transmit Data
Affected: USARTE0: _STATUS, _DATA
*******************************************************************************************/
OUT_CHAR:
	push R17

POLL_DREIF:
	lds R17, USARTE0_STATUS	; copy USARTD0_STATUS into R17
	sbrs R17, 5 ; skip next instruction if bit 5 is set (DREIF)
	rjmp POLL_DREIF
	sts USARTE0_DATA, R16 ; put data in R16 into USARTD0_DATA register
	
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
	lds R16, USARTE0_STATUS ;copy USARTD0_STATUS into R16
	sbrs R16, 7 ; is RXCIF flag is set, skip next instruction
	rjmp POLL_RXCIF
	lds R16, USARTE0_DATA ;put recieved data(in USARTD0_DATA) in R16
	
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