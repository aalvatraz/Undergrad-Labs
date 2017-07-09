; Name: I2C.asm
; Author: Adrian Alvarez
; Class: EEE4511 - Real Time DSP Applications
; Purpose: Lab 2
; Description:
;
;   This file provides a bit banging interface for I2C
;	To use: Push an effective address onto the stack then call i2s_send or i2c_receive routine
;
;*******************************************************************************************

	.include "F2833x_Register_Defines.asm"
	.def I2C_SEND,I2C_INIT


	.sect ".text"


;i2c init function
I2C_INIT:

	;set pins 32-33 to GPIO
	MOV AR1,#GPBMUX1
	MOV AR0,#0x0
	MOV *AR1,AR0

	;setting GPIO32-33 to input will release them high
	MOV AR1,#GPBDIR
	MOV AR0,#0x0
	MOV *AR1,AR0

	;enable pullup resistors
	MOV AR1,#GPBPUD
	MOV AR0,#0x0
	MOV *AR1,AR0

	LRET







I2C_SEND:
	;save return address
	POP AR7
	POP AR6

	;pop i2c address
	POP AR5
	;pop i2c data
	POP AR4

	;put return address back since AR7,6 get used for each subroutine call
	PUSH AR6
	PUSH AR7

	PUSH AH
	PUSH AR0
	PUSH AL

	EALLOW

	;load device address
	MOV AH,AR5
	AND AH, #0xFF ;8 bit address mask

	;load pointer to GPIO32,33 (SDA,SCL)
	MOV AR1,#GPBDIR

	;SDA low
	MOV AR0,#0x1
	MOV *AR1,AR0
	LC I2C_DELAY
	;SCL low
	OR AR0,#0x2
	MOV *AR1,AR0
	LC I2C_DELAY

	MOV T,#8				;set up counter/shifter
	NOT AH					;compliment AH (due to GPIO levels)
	AND AH,#0xFF			;AND with 0xFF to keep 8 bits only
	MOV AR2,AH				;store in AR2 (to relieve AH)

I2C_SEND_ADDR:
	MOV AH, *AR1			;load AH with current GPBDIR data
	MOV AL,AR2				;load value to be shifted out into AL
	DEC T					;decrement T (shift only 7 times)
	LSR AL,T				;shift AL right "T" times to get bits (MSB first)
	AND AL,#0x1				;AND result with 1 to only get one bit
	OR AL,#0x2				;OR with 0x2 to change SDA without affecting SCL
	MOV *AR1,AL  			;set/clear i2c address bit via GPBDIR
	LC I2C_CLOCK			;Clock the Clock
	CMP T,#0				;for branching purposes
	B I2C_SEND_ADDR,NEQ		;branch when T=0

	;set SDA low to ACK
	OR AR0,#0x1				;clear SDA without affecting SCL
	MOV *AR1,AR0			;update GPBDIR
	;Clock the Clock
	LC I2C_CLOCK
	;Signal incoming Data
	AND AR0,#0x2			;set SDA without affecting SCL
	MOV *AR1,AR0			;update GPBDIR
	LC I2C_DELAY

	MOV AR0,#0x3			;clear SDA without affecting SCL
	MOV *AR1,AR0			;update GPBDIR
	LC I2C_DELAY

	;load i2c data
	MOV AH,AR4				;load i2c data into AH
	NOT AH					;compliment AH (due to GPIO levels)
	AND AH, #0xFF 			;8 bit data mask
	MOV AR2,AH				;store in AR2 (to relieve AH)
	MOV T,#8				;set up counter/shifter

I2C_SEND_DATA:
	MOV AH, *AR1			;put most recent GBPDIR data in AH
	MOV AL,AR2				;put data to be shifted out in AL
	DEC T					;decrement T (shift only 7 times)
	LSR AL,T				;shift right "T" times (MSB first shifting)
	AND AL,#0x1				;keep only one bit
	OR AL,#0x2				;change SDA without affecting SCL
	MOV *AR1,AL  			;set/clear i2c data bit via GPBDIR
	LC I2C_CLOCK			;Clock the Clock
	CMP T,#0				;for branching purposes
	B I2C_SEND_DATA,NEQ

	;set SDA low to ACK
	OR AR0,#0x1				;clear SDA without affecting SCL
	MOV *AR1,AR0			;update GPBDIR
	;Clock the Clock
	LC I2C_CLOCK

	;release SCL then SDA (set to input = release high)
	MOV AR0,#0x1
	MOV *AR1,AR0
	LC I2C_DELAY
	LC I2C_DELAY
	MOV AR0,#0x0
	MOV *AR1,AR0

	POP AL
	POP AR0
	POP AH

	LRET


;i2c clock function
I2C_CLOCK:
	POP AR7
	POP AR6

	PUSH AR0
	PUSH AR1
	PUSH AH

	PUSH AR6
	PUSH AR7

	MOV AR1,#GPBDIR			;get pointer to GPIO direction
	MOV AH,*AR1			    ;put GPBDIR data in AH
	MOV AR0,AH
	LC I2C_DELAY
	XOR AR0,#0x2			;set SCL without changing SDA
	MOV *AR1,AR0			;update GPBDIR
	LC I2C_DELAY
	XOR AR0,#0x2			;clear SCL without changing SDA
	MOV *AR1,AR0			;update GPBDIR
	LC I2C_DELAY

	POP AR7
	POP AR6

	POP AH
	POP AR1
	POP AR0

	PUSH AR6
	PUSH AR7

	LRET

;I2C delay function
I2C_DELAY:
	POP AR7
	POP AR6

	PUSH AR0

	MOV AR0, #0x1F

I2C_DELAY_LOOP:

	DEC AR0
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	B I2C_DELAY_LOOP,NEQ

	POP AR0

	PUSH AR6
	PUSH AR7

	LRET








