; Name: Lab3_Part1.asm
; Author: Adrian Alvarez
; Class: EEE4511- Real Time DSP Applicationszz
; Purpose: Lab3 Part1 FPA Assembly
; Description:
;
;    This files utilizes FPU assembly to sort a vector of floating point numbers from smallest to largest
;*******************************************************************************************
	.include "F2833x_Register_Defines.asm"

SRAM_loc	.set 0x200000

	.sect ".cinit"

test1_failaddr	.usect ".ebss",2
test1_failval	.usect ".ebss",1
test2_failaddr	.usect ".ebss",2
test2_failval	.usect ".ebss",1
test3_failaddr	.usect ".ebss",2
test3_failval	.usect ".ebss",1

	.global _c_int00
	
	
	.text


_c_int00:

	EALLOW

	MOV AR1,#WDRC
	MOV AR0,#0x0068
	MOV *AR1,AR0
	
MAIN:

	LC SRAM_INIT
	LC GPIO_INIT

;	LC TEST1
;	LC TEST2
	LC TEST3

MAIN_END:
	B MAIN, UNC

;********************************************


SRAM_INIT:

	;enable A19-17
	MOV AR1, #GPAMUX2 + 1
	MOV AR0, #0xFC00
	MOV *AR1,AR0

	;enable XREADY,XR/~W
	MOV AR1, #GPBMUX1
	MOV AR0, #0xFCF0
	MOV *AR1,AR0

	;enable mid byte address signals
	MOV AR1, #GPBMUX1 + 1
	MOV AR0, #0xFFFF
	MOV *AR1, AR0

	;enable data signals
	MOV AR1, #GPCMUX1
	MOV AR0, #0xFFFF
	MOV *AR1,AR0

	;enable data signals
	MOV AR1, #GPCMUX1 + 1
	MOV AR0, #0xFFFF
	MOV *AR1,AR0

	;enable low byte address signals
	MOV AR1, #GPCMUX2
	MOV AR0, #0xFFFF
	MOV *AR1,AR0

	;enable zone selects
	MOV AR1,#PCLKCR3
	MOV  AL, #BIT12
	MOV *AR1,AL

	LRET

GPIO_INIT:

		;mux select GPIO on LED pins
		MOV AR0,#0
		MOV AR1,#GPAMUX1
		MOV *AR1,AR0

		;mux select GPIO on switch pins
		MOV AR0,#0
		MOV AR1,#GPAMUX1
		MOV *AR1,AR0

		;set GPIO_0-7 directions for LEDs (outputs) and GPIO8-11 directions for switches (inputs)
		MOV AR0,#0xff
		MOV AR1,#GPADIR
		MOV *AR1,AR0

		LRET

;****************************************************

TEST1:

		MOVL XAR0, #SRAM_loc
		MOV  AH, #0x0030
		MOV	 AL,#0x0000
		MOVL XAR2, #0xAA

TEST1_WLOOP:
		MOV *XAR0,AR2
		ADDB XAR0,#0x1
		CMPL ACC,XAR0
		B TEST1_WLOOP,NEQ

		MOVL XAR0, #SRAM_loc
		MOV AH, #0x0030
		MOV	 AL,#0x0000
		MOVL XAR2, #0xAA

TEST1_RLOOP:
		MOV AL,*XAR0						;get data
		nop
		nop
		ADDB XAR0,#1						;increment pointer
		nop
		nop

		CMP AL,AR2							;compare data to 0x00AA
		B TEST1_FAIL, NEQ					;branch if NEQ
		MOV AH, #0x0030
		MOV	 AL,#0x0000
		CMPL ACC,XAR0						;check if finished with SRAM
		B TEST1_RLOOP,NEQ					;branch to RLOOP if not finished

		MOV AR4,#GPADAT						;if test passed display 0xAA
		MOV *AR4,AR2
		B TEST1_END,UNC						;break to end UNC

TEST1_FAIL:
		SUBB XAR0,#1
		MOVL XAR7,#test1_failaddr
		MOVL *XAR7,XAR0
		MOVL XAR7,#test1_failval
		MOVL *XAR7,ACC
		MOV AR4,#0xEE
		MOV AR5,#GPADAT
		MOV *AR5,AR4

TEST1_END:
		LRET

;********************************************

TEST2:

		MOVL XAR0, #SRAM_loc
		MOV  AH, #0x0030
		MOV	 AL,#0x0000
		MOVL XAR2, #0x55

TEST2_WLOOP:
		MOV *XAR0,AR2
		ADDB XAR0,#0x1
		CMPL ACC,XAR0
		B TEST2_WLOOP,NEQ

		MOVL XAR0, #SRAM_loc
		MOV AH, #0x0030
		MOV	 AL,#0x0000
		MOVL XAR2, #0x55

TEST2_RLOOP:
		MOV AL,*XAR0						;get data
		nop
		nop
		ADDB XAR0,#1						;increment pointer
		nop
		nop

		CMP AL,AR2							;compare data to 0x0055
		B TEST2_FAIL, NEQ					;branch if NEQ
		MOV AH, #0x0030
		MOV	 AL,#0x0000
		CMPL ACC,XAR0						;check if finished with SRAM
		B TEST2_RLOOP,NEQ					;branch to RLOOP if not finished

		MOV AR4,#GPADAT						;if test passed display 0x55
		MOV *AR4,AR2
		B TEST2_END,UNC						;break to end UNC

TEST2_FAIL:
		SUBB XAR0,#1
		MOVL XAR7,#test2_failaddr
		MOVL *XAR7,XAR0
		MOVL XAR7,#test2_failval
		MOVL *XAR7,ACC
		MOV AR4,#0xEE
		MOV AR5,#GPADAT
		MOV *AR5,AR4

TEST2_END:
		LRET

;*********************************************

TEST3:

		MOVL XAR0, #SRAM_loc				;load sram location
		MOV  AH, #0x0024					;end location
		MOV	 AL,#0x0000
		MOV AR2, #0x0000					;data

TEST3_WLOOP:

		MOV *XAR0,AR2						;insert data
		ADDB XAR0,#0x1						;increment pointer
		INC AR2								;increment data
		CMPL ACC,XAR0						;branch if finished
		B TEST3_WLOOP,NEQ

		MOVL XAR0, #SRAM_loc				;load sram location
		MOV AH, #0x0024						;load end location
		MOV	 AL,#0x0000
		MOVL XAR2, #0x00					;load data

TEST3_RLOOP:
		MOV AL,*XAR0						;get data
		nop
		nop
		ADDB XAR0,#1						;increment pointer
		nop
		nop

		CMP AL,AR2							;compare data
		B TEST3_FAIL, NEQ					;branch if NEQ
		INC AR2								;increment data
		MOV AH, #0x0024
		MOV	 AL,#0x0000
		CMPL ACC,XAR0						;check if finished with SRAM
		B TEST3_RLOOP,NEQ					;branch to RLOOP if not finished

		MOV AR4,#GPADAT						;if test passed display 0xAA
		MOV AR2,#0x00
		MOV *AR4,AR2
		B TEST3_END,UNC						;break to end UNC

TEST3_FAIL:
		SUBB XAR0,#1
		MOVL XAR7,#test3_failaddr
		MOVL *XAR7,XAR0
		MOVL XAR7,#test3_failval
		MOVL *XAR7,ACC
		MOV AR4,#0xEE
		MOV AR5,#GPADAT
		MOV *AR5,AR4

TEST3_END:
		LRET

