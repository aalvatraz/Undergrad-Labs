; Name: Lab2_Quiz.asm
; Author: Adrian Alvarez
; Class: EEE4511- Real Time DSP Applications
; Purpose: Lab 2
; Description:
;
;    Quiz
;*******************************************************************************************

	.include "F2833x_Register_Defines.asm"

	.ref Quiz_Values,Quiz_Values_Length,Min_Value,Max_Value,I2C_INIT,LCD_INIT,LCD_STRING,LCD_CLEAR

	.global _c_int00

;******************************************************************************************
	.sect ".cinit"

Maximum:
	.word "Maximum"
	.word 0x0
Minimum:
	.word "Minimum"
	.word 0x0
;*******************************************************************************************

	.text

_c_int00:

		;enable protected registers
		EALLOW

		;disable watchdog timer
		MOV AR0,#0x0068				;put 0x0068 in AR0
		MOV AR1,#WDRC				;put WDRC register address(0x7029) in AR1
		MOV *AR1,AR0				;disable watchdog

		;program
		LC SORTMIN32
		LC SORTMAX32

		LC GPIO_INIT
		LC I2C_INIT
		LC LCD_INIT

QUIZ_LOOP:

		LC CHECK_SWITCHES 			;this set AH to SwitchBit 3 and AL to SwitchBits 0 and1
		LC LCD_QUIZ



		B QUIZ_LOOP,UNC

;***********************************************************************************************
;***********************************************************************************************
;***********************************************************************************************
;***********************************************************************************************
;***********************************************************************************************
;***********************************************************************************************

SORTMIN32:
	;use ARx registers as pointers
		MOVL XAR0,#Quiz_Values				;make XAR0 a pointer to table
		MOVL XAR2,#Quiz_Values_Length		;make XAR2 a pointer to table length
		MOVL XAR4,#Min_Value					;make XAR4 a pointer to min value

		MOV AR7,*XAR2
;start by putting first value in ACC
		MOVL XT,*AR0

;use AH and AL to compare values, storing the lowest value in T
SORTMIN32_LOOP:
		ADDB XAR0,#0x2
		DEC AR7						;decrement data at AR1(table length)
		B SORTMIN32_END,EQ						;branch if score_vector_len data equals zero (Z=1)
		MOVL ACC,*XAR0						;move next value into T
		CMPL ACC,XT						;AL-AH
		B SORTMIN32_LOOP,HI						;branch to "Loop" if AL is greater than AH (use HI condition for unsigned numbers)
		MOVL XT,ACC					;AL is lower than AH, so move it to AH

		B SORTMIN32_LOOP,UNC						;branch to Loop unconditionally


;store lowest value (in AH) in "min"
SORTMIN32_END:
		MOVL *XAR4,XT						;move lowest value to "min"

		LRET

;********************************************************************************************

SORTMAX32:
	;use ARx registers as pointers
		MOVL XAR0,#Quiz_Values				;make XAR0 a pointer to table
		MOVL XAR2,#Quiz_Values_Length		;make XAR2 a pointer to table length
		MOVL XAR4,#Max_Value					;make XAR4 a pointer to min value

		MOV AR7,*XAR2
;start by putting first value in ACC
		MOVL XT,*AR0

;use AH and AL to compare values, storing the lowest value in T
SORTMAX32_LOOP:
		ADDB XAR0,#0x2
		DEC AR7						;decrement data at AR1(table length)
		B SORTMAX32_END,EQ						;branch if score_vector_len data equals zero (Z=1)
		MOVL ACC,*XAR0						;move next value into T
		CMPL ACC,XT						;AL-AH
		B SORTMAX32_LOOP,LO						;branch to "Loop" if AL is greater than AH (use HI condition for unsigned numbers)
		MOVL XT,ACC					;AL is lower than AH, so move it to AH

		B SORTMAX32_LOOP,UNC						;branch to Loop unconditionally


;store lowest value (in AH) in "min"
SORTMAX32_END:
		MOVL *XAR4,XT						;move lowest value to "min"

		LRET

;***********************************************************************************************

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

;***********************************************************************************************
CHECK_SWITCHES:

	;get data pointer
	MOV AR0,#GPADAT

	;check Switch3 and store its bit in AH
	MOV AH, *AR0
	LSR AH,#11
	AND AH,#0x1

	;check Switches 1 and 2 and store in AL
	MOV AL,*AR0
	LSR AL,#8
	AND AL,#0x3

	LRET

;*********************************************************************************************

LCD_QUIZ:
	CMP AH,#0
	B LCD_QUIZ_MAX,NEQ

LCD_QUIZ_MIN:
	LC LCD_CLEAR
	MOV AR0,#Minimum
	LC LCD_STRING
	LC LED_QUIZMIN
	B LCD_QUIZ_END,UNC

LCD_QUIZ_MAX:
	LC LCD_CLEAR
	MOV AR0,#Maximum
	LC LCD_STRING
	LC LED_QUIZMAX
	B LCD_QUIZ_END,UNC

LCD_QUIZ_END:
	LRET

;*************************************************************************************

LED_QUIZMAX:
	CMP AL,#0x0
	B LED_QUIZMAX_0,EQ
	CMP AL,#0x1
	B LED_QUIZMAX_1,EQ
	CMP AL,#0x2
	B LED_QUIZMAX_2,EQ
	CMP AL,#0x3
	B LED_QUIZMAX_3,EQ

LED_QUIZMAX_0:
	MOV AR1, #Max_Value
	MOV AR0, #GPADAT
	MOV AH, *AR1
	MOV AL, *AR0
	AND AH,#0x00FF
	AND AL,#0x0F00
	OR AH,AL
	MOV *AR0,AH
	B LED_QUIZMAX_END,UNC

LED_QUIZMAX_1:
	MOV AR1, #Max_Value
	MOV AR0, #GPADAT
	MOV AH, *AR1
	MOV AL, *AR0
	AND AH,#0xFF00
	LSR AH,#8
	AND AL,#0x0F00
	OR AH,AL
	MOV *AR0,AH
	B LED_QUIZMAX_END,UNC

LED_QUIZMAX_2:
	MOV AR1, #Max_Value+1
	MOV AR0, #GPADAT
	MOV AH, *AR1
	MOV AL, *AR0
	AND AH,#0x00FF
	AND AL,#0x0F00
	OR AH,AL
	MOV *AR0,AH
	B LED_QUIZMAX_END,UNC

LED_QUIZMAX_3:
	MOV AR1, #Max_Value+1
	MOV AR0, #GPADAT
	MOV AH, *AR1
	MOV AL, *AR0
	AND AH,#0xFF00
	LSR AH,#8
	AND AL,#0x0F00
	OR AH,AL
	MOV *AR0,AH
	B LED_QUIZMAX_END,UNC

LED_QUIZMAX_END:
	LRET

;*************************************************************************************

LED_QUIZMIN:
	CMP AL,#0x0
	B LED_QUIZMIN_0,EQ
	CMP AL,#0x1
	B LED_QUIZMIN_1,EQ
	CMP AL,#0x2
	B LED_QUIZMIN_2,EQ
	CMP AL,#0x3
	B LED_QUIZMIN_3,EQ

LED_QUIZMIN_0:
	MOV AR1, #Min_Value
	MOV AR0, #GPADAT
	MOV AH, *AR1
	MOV AL, *AR0
	AND AH,#0x00FF
	AND AL,#0x0F00
	OR AH,AL
	MOV *AR0,AH
	B LED_QUIZMIN_END,UNC

LED_QUIZMIN_1:
	MOV AR1, #Min_Value
	MOV AR0, #GPADAT
	MOV AH, *AR1
	MOV AL, *AR0
	AND AH,#0xFF00
	LSR AH,#8
	AND AL,#0x0F00
	OR AH,AL
	MOV *AR0,AH
	B LED_QUIZMIN_END,UNC

LED_QUIZMIN_2:
	MOV AR1, #Min_Value + 1
	MOV AR0, #GPADAT
	MOV AH, *AR1
	MOV AL, *AR0
	AND AH,#0x00FF
	AND AL,#0x0F00
	OR AH,AL
	MOV *AR0,AH
	B LED_QUIZMIN_END,UNC

LED_QUIZMIN_3:
	MOV AR1, #Min_Value + 1
	MOV AR0, #GPADAT
	MOV AH, *AR1
	MOV AL, *AR0
	AND AH,#0xFF00
	LSR AH,#8
	AND AL,#0x0F00
	OR AH,AL
	MOV *AR0,AH
	B LED_QUIZMIN_END,UNC

LED_QUIZMIN_END:
	LRET






