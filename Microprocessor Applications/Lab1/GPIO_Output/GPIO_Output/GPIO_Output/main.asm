;
; GPIO_Output.asm
;
; Created: 1/14/2016 2:12:34 PM
; Author : Adrian
;
/* This program shows how to initialize a GPIO port on the Atmel (Port D for this example)
 and demonstrates various ways to write to a GPIO port. 
 The output will blink LEDs at the bottom left of the uPAD,
 labeled DS. Port D0, Port D1 and Port D4 are the red, green,
 and blue LEDs, respectively. Note that these LED's are active-low.
 */
; Replace with your application code
;Definitions for all the registers in the processor. ALWAYS REQUIRED
;View the contents of this file in the Processor "Solution Explorer"
; window under "Dependencies"
.include "ATxmega128A1Udef.inc"

.equ BIT0 = 0x01
.equ RED = ~(BIT0)
.equ BIT1 = 0x02
.equ GREEN = ~(BIT1)
.equ BIT4 = 0x10
.equ BLUE = ~(BIT4)
.equ BIT410 = 0x13
.equ WHITE = ~(BIT410)
.equ BIT40 = 0x11
.equ PINK = ~(BIT40)
.equ BLACK = 0xFF

.ORG 0x00000		;CODE starts running from address 0x0000
		rjmp MAIN	;Relative jump to start of program

.ORG 0x0100			;Start PROGRAM at 0x0100 so we don't overwrite (why?)
					; vectors that are at 0x000-0x00FD

MAIN:
		ldi R16, BIT410		;Load Register 16 with RED(~BIT0 = ~0x01) 
		sts PORTD_DIRSET, R16	;Set GPIO in Register 16(Port D) as outputs

; Notice that the 3 LEDs are all on now, creating white.

;The following code shows different ways to write to GPIO pins.

;Turn on each fo the primary colored LEDs in turn, then use some combinations
	;These instructions send the value in R16 to the PORTD pins
	; Since the LEDs are wired as active-low,  an R16 = RED = ~0x01 = 0xFE = 0b1111 1110
	; will turn the RED LED on.

	ldi R16, RED		; load R16 with RED = 0xFE
	sts PORTD_OUT, R16	; send the value in R16 to the PORTD pins
	ldi R16,GREEN
	sts PORTD_OUT, R16
	ldi R16,BLUE
	sts PORTD_OUT, R16
	ldi R16,WHITE
	sts PORTD_OUT, R16
	ldi R16,PINK
	sts PORTD_OUT, R16
	ldi R16,BLACK
	sts PORTD_OUT, R16
	;D5 isnow dimly on, check uPAD schematics for clue
	ldi R16,BLUE
	sts PORTD_OUT, R16
	; OUTSET makes LED go off, since LED is active-low
	ldi R16,BIT4
	sts PORTD_OUTSET, R16
	ldi R16,BIT4
	sts PORTD_OUTCLR, R16
	;Notice: OUTTGL toggles the value of PORT pin
	sts PORTD_OUTTGL, R16
	LOOP:
			sts PORTD_OUTTGL, R16

			rjmp LOOP			;repeat forever!