; Name: Lab2_Part3.asm
; Author: Adrian Alvarez
; Class: EEE4511 - Real Time DSP Applications
; Purpose: Lab 2
; Description:
;
;   This is the entry point for completing Lab2 part3.
;	This files depends on LCD.asm and I2C.asm to
;	successfully print to the LCD screen via bit
;	banged I2C protocol
;
;
;*******************************************************************************************



	.include "F2833x_Register_Defines.asm"
	.ref I2C_INIT,LCD_INIT,LCD_CLEAR,LCD_STRING,LCD_LINE2

	.global _c_int00

	.sect ".cinit"

NAME:
	.word "Adrian Alvarez"
	.word 0x0

CLASS:
	.word "EEL4511"
	.word 0x0


	.text

_c_int00:

	;enable protected registers
	EALLOW

	;disable watchdog timer
	MOV AR0,#0x0068				;put 0x0068 in AR0
	MOV AR1,#WDRC				;put WDRC register address(0x7029) in AR1
	MOV *AR1,AR0				;disable watchdog

;initialize i2c and LCD
	LC I2C_INIT
	LC LCD_INIT


LOOP:
	LC LCD_CLEAR
	MOV AR0,#NAME
	LC LCD_STRING
	LC LCD_LINE2
	MOV AR0,#CLASS
	LC LCD_STRING
	B LOOP,UNC
