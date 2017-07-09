;
; Lab1_ASCII_Filter.asm
;
; Created: 1/15/2016 2:57:24 AM
;Lab1 PartB
;Name : Adrian Alvarez
;Section 3189
;TA: Madison Emas
/*Description:
This program filters ASCII data from an array in memory 
and copies the filtered data to specified memory locations
*/ 

.include "ATxmega128A1Udef.inc"		;include define file for controller

.equ A = 0x76		;let A equal 0x76 (comparison parameter 0x75 + 1 so we can accurately compare with brpl)
.equ B = 0x3C		;let B equal 0x3C (a comparison parameter)

.org 0x0000			; start code at address 0x0000
	rjmp MAIN		; jump to MAIN

.org 0x6180			; Write table to program memory at address 0x6180

TABLE: .db 'u', '1', 'P', '8', '_', '@', '!', '_', 'v', 'U', '+', 'F', '<', '_', '%', '=', ' ', '_', '"', 'f', '&', 'u', '6', 'n', ')'

.dseg		;data memory

.org 0x3760			;organize new table at address 0x3760

NEWTABLE: .byte 1

.cseg

.org 0x0200			;start program code at address 0x0200
MAIN:	ldi r16, A				;load registers with data and addresses
		ldi r17, B
		ldi r18, 0x0000
		ldi ZH, high(TABLE<<1)	;use Z register for accessing program memory
		ldi ZL, low(TABLE<<1)
		ldi YH, high(NEWTABLE)
		ldi YL, low(NEWTABLE)
LOOP:	lpm r19, Z+			;load r19 with table value, increment Table address afterwards
		cp r19, r18			;compare r19 with r18(0x00)
		breq END			;if r19=0x00, break to end, if not keep going
		cp r19, r16			;compare r19 to r16
		brpl LOOP			;if r19>r16=0x75 break to LOOP, else keep going
		cp r19, r17			;compare r19 to r17
		breq LOOP			;if r19=r17 break to LOOP
		brlo LOOP			;if r19<r17=0x3C break to LOOP,else keep going
		st Y+, r19			;the table entry has passed all tests, store it in data memory pointed to by Y, increment Y
		rjmp LOOP			;jump to LOOP

END:						;NUL character found, DONE
	rjmp END

