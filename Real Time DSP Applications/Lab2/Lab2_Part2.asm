; Name: Lab2_Part2.asm
; Author: Adrian Alvarez
; Class: EEE4511- Real Time DSP Applications
; Purpose: Lab 2
; Description:
;
;   This file performs basic GPIO functions
;	It reads input from Active high Switch circuits on GPA x-x and outputs them on GPA x-x
;*******************************************************************************************

;Include Register Defines File
	.include "F2833x_Register_Defines.asm"

	.global _c_int00

;******LOCAL_DEFINES*************
;bitmasks for gpio
;LED_DIR 	.set
;********************************

;*******PROGRAM*****************************
	.text

_c_int00:

	;enable protected registers
	EALLOW

	;disable watchdog timer
	MOV AR0,#0x0068				;put 0x0068 in AR0
	MOV AR1,#WDRC				;put WDRC register address(0x7029) in AR1
	MOV *AR1,AR0				;disable watchdog

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

	;load AH with GPADAT
	;MOV AH,#GPADAT
	;MOV AR1,#GPADAT

;poll for input
POLL_SWITCHES:
	MOV AR1,#GPADAT
	MOV AL,*AR1
	MOV AH,AL
	LSR AH,4
	LSR AL,8
	AND AH,#0xf0
	AND AL,#0x0f
	OR AL,AH
	AND AL,#0xff
	MOV *AR1,AL
	B POLL_SWITCHES,UNC
;branch to POLL unconditionally (loop program forever)5



