;
; lab2b1.asm
; Lab 2 Part B1
; Author : Adrian
; Section : 3189
; TA: Madison Emas
; Created: 1/26/2016 1:04:00 PM
; Description:
; This program uses the assumption that each instruction takes .5e-6 s to take place and creates a delay for output pins

.include "ATxmega128A1Udef.inc"

.equ stack = 0x3FFF
.org 0x0100		;program at 0x0100

MAIN:					;MAIN
	ldi YL, low(stack)	;initialize stack pointer
	sts CPU_SPL, YL
	ldi YH, high(stack)
	sts CPU_SPH, YH
	ldi R16, 0xE0		; load R16 with Delay parameter (global variable, not used in this program)
	ldi R17, 0xFF		; load R17 with Pin directions
	sts PORTE_DIRSET, R17	; set pin directions to output
	ldi R17, 0xAA			; load R17 with portE pin 1
	sts PORTE_OUT, R17		; Pin 1 on PortE to High
TOGGLE:						; Toggle 
    ldi R17, 0xAA		
	sts PORTE_OUT, R17	; Toggle some pins on Port E
	rcall DELAY200		; Call delay subroutine
	ldi R17, 0x55		; Toggle the other pins on Port E
	sts PORTE_OUT, R17
	rcall DELAY200
	rjmp TOGGLE				; loop toggle

;-------------------------------------------------

.org 0x0200				; subroutine at 0x0200
;----DELAY200-----------
; Subroutine which causes a delay by creating a counter
; R19 sets the upper limit for the counter in R18.
; This subroutine recieves and passes no parameters.
DELAY200:
	push R19			; push registers
	push R18
	ldi R19, 0xC8		; load r19 and R18 with delay parameters
	ldi R18, 0x00
DELAY:
	cp R18, R19			; compare r18 to r19
	breq END_DELAY		; branch to CHECK if equal
	inc R18				; if not equal, increment r18
	rjmp DELAY			; loop back to delay
END_DELAY:			
	pop R18				;pop registers
	pop R19
	ret					; return to MAIN
	

