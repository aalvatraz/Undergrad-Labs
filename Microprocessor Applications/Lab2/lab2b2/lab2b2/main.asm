;
; lab2b2.asm
; Lab 2 Part B2
; Author : Adrian
; Section: 3189
; TA: Madison Emas
; Created: 1/31/2016 2:39:13 PM
; Description:
; This function uses a subroutine to create a 2.5 kHz signal
; by adding a 400us delay between each toggle on the output pins

.include "ATxmega128A1Udef.inc"
.equ STACK_ADDR = 0x3FFF


.org 0x0100		;program at 0x0100

MAIN:					;MAIN
	ldi R16, low(STACK_ADDR) ;initialize stack pointer
	out CPU_SPL, R16 
	ldi R16, high(STACK_ADDR)
	out CPU_SPH, R16

	ldi R16, 0x01		; load R16 with Delay parameter (global variable)
	ldi R17, 0xFF		; load R17 with Pin directions
	sts PORTE_DIRSET, R17	; set pin directions to output
	ldi R17, 0x01			; load R17 with portE pin 1
	sts PORTE_OUT, R17		; Pin 1 on PortE to High
TOGGLE:						; Toggle 
	ldi R17, 0xAA
	sts PORTE_OUT, R17	; Toggle Port E
	rcall DELAY200		; Call delay subroutine
	ldi R17, 0x55
	sts PORTE_OUT, R17
	rcall DELAY200
	rjmp TOGGLE				; loop toggle

;-------------------DELAY------------------------------
;This subroutine takes in one parameter from R16 to choose how many 200us delays to create
;The result of this subroutine is a delay of (R16+1) x 200 microseconds
;To achieve 2.5 kHz, we use a delay of 400 us, therefore R16 is set to 0x01

.org 0x0200				; subroutine at 0x0200
DELAY200:
	push R19			; push registers
	push R18
	push R17
	ldi R19, 0x25		; load r19 and R18 with delay parameters
	ldi R18, 0x00
	ldi R17, 0x00
DELAY:
	cp R18, R19			; compare r18 to r19
	breq CHECK			; branch to CHECK if equal
	inc R18				; if not equal, increment r18
	rjmp DELAY			; loop back to delay
CHECK:
	cp R16, R17			;compare r17 to delay parameter in R16
	breq END_DELAY		; branch to END_DELAY if equal
	inc R17				; increment r17 if not equal
	clr R18
	rjmp DELAY			; jumpt to delay
END_DELAY:
	pop R17				;pop registers
	pop R18
	pop R19
	ret					; return to MAIN
	

