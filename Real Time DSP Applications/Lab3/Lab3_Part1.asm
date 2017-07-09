; Name: Lab3_Part1.asm
; Author: Adrian Alvarez
; Class: EEE4511- Real Time DSP Applications
; Purpose: Lab3 Part1 FPA Assembly
; Description:
;
;    This file initializes the SRAM and writes/reads to it
;*******************************************************************************************
	.include "F2833x_Register_Defines.asm"

	.global _c_int00

	.sect ".cinit"

float_vect:

		.float  765.3456
		.float	3.4
		.float	867.6
		.float	-0.89
		.float	52.793
		.float	73.7783
		.float	27.3
		.float	-385.7
		.float	32.0
		.float	-9.9

floatvect_size:
		.word	10

;index .usect ".ebss",10
sorted	.usect ".ebss",20

;******************************************************

	.text


_c_int00:

	EALLOW

	MOV AR1,#WDRC
	MOV AR0,#0x0068
	MOV *AR1,AR0

MAIN:

	LC COPY
	LC BUBBLESORTF

MAIN_END:
	B MAIN_END,UNC

;******************************************************************************************************************************

BUBBLESORTF:
	PUSH AR0			;address pointer
	PUSH AR1			;address pointer
	PUSH AR2			;sort counter
	PUSH AR3			;pass counter
	PUSH AR4			;pass compare
	PUSH AR5
	PUSH AR6			;data pointer
	PUSH AR7			;data pointer


	;load registers with pointers to data
	MOV AR7,#sorted
	MOV AR6,#floatvect_size
	MOV AH,*XAR6

	DEC AH								;n-1 passes for bubble sort

BUBBLESORTF_MAJLOOP:

	MOV AR0,AR7							;reload AR1 = changeable pointer
	MOV AR2,AR7
	ADD AR2,#2
	MOV AL,*XAR6							;to stop at final vector location
	DEC AL								;n-1 index positions
	DEC AH								;decrement pass number
	B BUBBLESORTF_END,EQ				;end sort if finished n-1 passes

BUBBLESORTF_MINLOOP:

	MOV32 R0H, *XAR0
	MOV32 R1H, *XAR2
	CMPF32 R0H,R1H
	MOVST0 ZF, NF 						;Move ZF and NF to ST0
	B BUBBLESORTF_SWITCH, LT			;branch if greater than or equal
	ADD AR0,#2							;increment pointers to next position
	ADD AR2,#2
	DEC AL
	B BUBBLESORTF_MAJLOOP,EQ			;break to major loop if finished with pass
	B BUBBLESORTF_MINLOOP,UNC			;move to next position of pass (minor loop)

BUBBLESORTF_SWITCH:
	MOV32 *XAR2, R0H
	MOV32 *XAR0, R1H
	ADD AR0,#2							;increment pointer to next position
	ADD AR2,#2
	DEC AL
	B BUBBLESORTF_MAJLOOP,EQ			;break to major loop if finished with pass
	B BUBBLESORTF_MINLOOP,UNC			;move to next position of pass (minor loop)

BUBBLESORTF_END:
	POP AR7			;address pointer
	POP AR6			;address pointer
	POP AR5			;sort counter
	POP AR4			;pass counter
	POP AR3			;pass compare
	POP AR2
	POP AR1			;data pointer
	POP AR0			;data pointer

	LRET

;*******************************************
;
;**************SUBROUTINE*******************
;
COPY:

	MOVL XAR4, #sorted
	MOVL XAR3, #float_vect
	MOVL XAR2, #floatvect_size
	MOV AL,*XAR2

COPY_LOOP:
	MOV32 R0H, *XAR3
	MOV32 *XAR4, R0H
	ADDB XAR3, #2
	ADDB XAR4, #2
	DEC AL
	B COPY_LOOP,NEQ

COPY_END:
	LRET
