;
; lab2c.asm
; Lab 2 Part C
; Author : Adrian
; Section: 3189
; TA: Madison Emas
; Created: 1/31/2016 2:52:13 PM
; Description:
; This program reads each pin on the LED and returns a hex value into R16. (No key = 0xFF)
; Be sure to call KEYPAD_SETUP before using GETKEY in order to obtain key stroke.


.include "ATxmega128A1Udef.inc"

.equ stack_addr = 0x3FFF   ;stack address 

.org 0x0100
MAIN:
	ldi YL, low(stack_addr)		;initialize low byte of stack pointer
	out CPU_SPL, YL			
	ldi YL, high(stack_addr)	;initialize high byte of stack pointer
	out CPU_SPH, YL	
LOOP:		
	rcall KEYPAD_SETUP			; initializes Tables
	rcall GETKEY				; get key value
	rjmp LOOP


.org 0x0200
;------------KEYPAD_SETUP-----------------
;This subroutine is used in conjunction with GETKEY in order to pass a key value into R16
;This subroutine creates tables in program memory which will correspond to pin detection values and return values
; The idea was to try to minimize the amount of code needed and it MUST be called before calling GETKEY
KEYPAD_SETUP:		;name of subroutine
	TABLE_1:		; pointer to data
		.db 0x11, 0x12, 0x14, 0x18, 0x21, 0x22, 0x24, 0x28, 0x41, 0x42, 0x44, 0x48, 0x81, 0x82, 0x84, 0x88 ;data table for pin detection
	TABLE_2:
		.db 0x0D, 0x0C, 0x0B, 0x0A, 0x0F, 0x09, 0x06, 0x03, 0x00, 0x08, 0x05, 0x02, 0x0E, 0x07, 0x04, 0x01	;data table for return value
		ret

;------------GETKEY--------------
;This subroutine outputs a value into R16 by setting some pins in PORTF to input and output
; The upper nibble of PORTF are the output pins and the lower nibble are the pulled down inputs
; This function iterates through each row (bottom to top) and each column (right to left)
; It returns a hex value into R16 corresponding to the key that was pressed
GETKEY:	
	;push all registers except r16
	push R17
	push R18
	push R19
	push R20
	push R21
	push ZL
	push ZH
GETKEY_SETUP:
	ldi ZL, low(TABLE_1 << 1)	;load Z register with Table address
	ldi ZH, high(TABLE_1 << 1)
	ldi R18, 0x00				;zero for comparison purposes 
	ldi R17, 0x10				;pull down resistor OPC for PINnCTRL
	ldi R21, 0x10				;data  displacement between TABLE_1 and TABLE_2
	sts PORTF_PIN0CTRL, R17		;set PORTF pins 0-3 to pulled down inputs
	sts PORTF_PIN1CTRL, R17
	sts PORTF_PIN2CTRL, R17
	sts PORTF_PIN3CTRL, R17
	ldi R17, 0xF0				;load R17 with 0b11110000
	sts PORTF_DIR, R17			;set pin indicated by R17 as outputs
	ldi R17, 0x10				;set R17 for first output pin
READPAD:
	cp R18, R17					;compare R17 and R18
	breq NO_KEY					; branch if R17 = R18
	sts PORTF_OUT, R17			;set pin indicated by R17 to high
	nop
	lds R19, PORTF_IN			;get PortF pins
	lpm R20, Z+					;get Table value for comparison, increment pointer
	cp R19, R20					;compare registers
	breq SETR16					;break if read value in R19 = data in Table (ie. break if key is pressed)
	lpm R20, Z+					;same for next row up
	cp R19, R20
	breq SETR16	
	lpm R20, Z+
	cp R19, R20
	breq SETR16	
	lpm R20, Z+
	cp R19, R20
	breq SETR16	
	lsl R17    ;shift R17 to the left to output to next col if no butons in current column were pressed
	rjmp READPAD
SETR16:			; set R16 if key is pressed
	dec ZL		; decrement ZL to obtain correct data since we already performed a post increment 
	ADD ZL, R21	; add displacement to get correct return value from Table_2
	lpm R16, Z	; load return value into R16
	rjmp RETURN	; jump to return
NO_KEY:
	ldi R16, 0xFF	;error code when no key is pressed
RETURN:
	;pop all registers
	pop ZH
	pop ZL
	pop R21
	pop R20
	pop R19
	pop R18
	pop R17
	ret	;return 

