;
; Name: Filters.asm
;
; This file contains assembly code for implementing
; an FIR filter with buffer size of 1024 words
;
;
;
	.include"F2833x_Register_Defines.asm"

	.def _FIRFilter2
	.def _IIR_MAC

	.sect ".text"

;*************************************
;-----------FIRFilter2-------------
;Applies Filter to data and
;returns result
;
;XAR4 = data pointer (uint32)
;XAR5 = taps pointer (uint32)
;
;AL = data size (16 bits)
;AH = taps size
;*************************************
_FIRFilter2:

	;must save XAR1, XAR2, XAR3, R4H, R5H, R6H, R7H on stack before using
	PUSH XAR1
	PUSH XAR3
	MOV32 XAR1,R6H
	PUSH XAR1
	MOV32 XAR1,R7H
	PUSH XAR1

	;enter routine

	;AR3 <-- AH (taps size)
	MOV AR3, AH

	;XAR6<--XAR4 (data pointer)
	MOVL XAR6, XAR4

	;XAR7<--XAR5 (taps pointer)
	MOVL XAR7, XAR5

	; Circular Indirect Addressing Mode buffer set up
	MOV AH, #0x0400
	LSL AL, 1			;AL has current counter

	MOVL XAR1, ACC

_FIRFilter2_Loop:

	ZERO R2H
	ZERO R3H
	ZERO R6H
	ZERO R7H

	SETC AMODE ;AMODE = 1

	;calculate FIRfilter output
	RPT AR3  ; Repeat MACF32 AR3 times
 || MACF32 R7H, R3H, *+XAR6[AR1%++], *XAR7++     ; inc XAR6 with wrap around
	ADDF32 R7H, R7H, R3H

	CLRC AMODE		;clear AMODE bit

_FIRFilter2_End:
	;change result back to Uint16
	F32TOI16 R0H, R7H

	;return saved values from stack
	POP XAR1
	MOV32 R7H, XAR1
	POP XAR1
	MOV32 R6H, XAR1
	POP XAR3
	POP XAR1

	;put in correct return register & add dc offset
	MOV32 ACC, R0H
	ADD ACC, #0x7FFF

	LRETR



;*************************************
;-----------IIRFilter--------------
;Applies Filter to data and
;returns result
;
;XAR4 = IIR taps pointer (uint32)
;XAR5 = IIR data pointer (uint32)
;*************************************

_IIR_MAC:

	MOVL XAR7, XAR4
	MOVL XAR6, XAR5

	ZERO R2H
	ZERO R3H
	ZERO R6H
	ZERO R7H


	;debug: test with array instead of struct
	;debug: use individual MAC instructions
	;debug: Neither things worked, moving to TI function...


	;calculate IIRfilter output
	RPT #4  ; Repeat MACF32 (5-1) times for SOS
 || MACF32 R7H, R3H, *XAR6++, *XAR7++     ; inc XAR6&7
	ADDF32 R0H, R7H, R3H
	NOP
	NOP

	LRETR
