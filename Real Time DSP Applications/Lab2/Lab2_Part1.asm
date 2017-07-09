; Name: Lab2_Part1.asm
; Author: Adrian Alvarez
; Class: EEE4511- Real Time DSP Applications
; Purpose: Lab 2
; Description:
;
;    This file sorts through the data vector, or length stored at "score_vector_len", of signed (or unsigned) 16 bit numbers at label "score_addr"
;    to find the smallest value and store it at "min_addr"
;*******************************************************************************************

		.global		_c_int00

;reference external modules
		.ref score_addr,score_vector_len,min_addr


;**************************************************************************
;		.sect ".cinit"
;score_addr:
;		.byte 0x01, 0xFF, 0x80, 0x05, 0x38, 0xC9

;score_vector_len:
;		.word 0x6

;min_addr	.usect ".ebss",1

		.text

_c_int00:

;purge pipeline
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP

;use ARx registers as pointers
		MOV AR0,#score_addr				;make AR0 a pointer to score_addr
		MOV AR1,#score_vector_len		;make AR1 a pointer to score_vector_len
		MOV AR2,#min_addr				;make AR2 a pointer to min_addr

;start by putting first value in AH
		MOV AH,*AR0
;		LSL AH,8 ;(8bit data)

;use AH and AL to compare values, storing the lowest value in AH
Loop:
		INC AR0							;increment AR0(score_addr pointer)
		DEC *AR1						;decrement data at AR1(score_vector_len)
		B End,EQ						;branch if score_vector_len data equals zero (Z=1)
		MOV AL,*AR0						;move next value into AL
;		LSL AL,8 ;(8bit data)
		CMP AL,AH						;AL-AH
		B Loop,GT						;branch to "Loop" if AL is greater than AH (use HI condition for unsigned numbers)
		MOV AH,AL						;AL is lower than AH, so move it to AH



		B Loop,UNC						;branch to Loop unconditionally


;store lowest value (in AH) in "min_addr"
End:
		MOV *AR2,AH						;move lowest value to "min_addr"

Forever:
		B Forever, UNC					;branch forever unconditionally





