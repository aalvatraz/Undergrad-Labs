;
; Lab1Quiz.asm
;
; Created: 1/15/2016 4:25:39 PM
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
.equ caseshift = 0x20 ;difference between an uppercase and lowercase in ASCII

.org 0x0000			; start code at address 0x0000
	rjmp MAIN		; jump to MAIN

.org 0x6180			; Write table to program memory at address 0x6180

TABLE: .db 'u', '1', 'P', '8', '_', '@', '!', '_', 'v', 'U', '+', 'F', '<', '_', '%', '=', ' ', '_', '"', 'f', '&', 'u', '6', 'n', ')'

.dseg		;data memory

.org 0x3760			;organize new table at address 0x3760

NEWTABLE: .byte 1

.cseg

.org 0x0200			;start program code at address 0x0200
MAIN:	
		ldi r16, A				;load registers with data and addresses
		ldi r17, B
		ldi r18, 0x0000
		ldi r19, 0x20
		ldi r20, 0x41
		ldi r21, 0x59
		ldi r22, 0x61
		ldi ZH, high(TABLE<<1)	;use Z register for accessing program memory
		ldi ZL, low(TABLE<<1)
		ldi YH, high(NEWTABLE)
		ldi YL, low(NEWTABLE)
LOOP:	lpm r24, Z+			;load r24 with table value, increment Table address afterwards
		cp r24, r18			;compare r24 with r18(0x00)
		breq END			;if r24=0x00, break to end, if not keep going
		cp r24, r16			;compare r24 to r16
		brpl LOOP			;if r24>r16=0x75 break to LOOP, else keep going
		cp r24, r17			;compare r24 to r17
		breq LOOP			;if r24=r17 break to LOOP
		brlo LOOP			;if r24<r17=0x3C break to LOOP,else keep going
		cp r24, r20			; check if neither upper or lowercase
		brlo STORE
		cp r24,r22			; check if value is lowercase
		brsh LTU
		cp r24, r20			;check if value is at least uppercase
		brsh CHKU			;branch to check if uppercase

CHKU:	cp r24, r21			;check if uppercase	
        brlo UTL			;branch to UTL if upercase

STORE:	st Y+, r24			;the table entry has passed all necessary tests, store it in data memory pointed to by Y, increment Y
		rjmp LOOP			;jump to LOOP

UTL:	add r24, r19		;convert uppercase to lowercase
		rjmp STORE

LTU:    sub r24, r19		;convert lowercaseto uppercase
		rjmp STORE

END:						;NUL character found, DONE
	rjmp END

