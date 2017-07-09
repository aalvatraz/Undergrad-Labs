; Name: LCD.asm
; Author: Adrian Alvarez
; Class: EEE4511 - Real Time DSP Applications
; Purpose: Lab 2
; Description:
;
;   This file provides a top layer interface for the LCD using the I2C.asm modules
;	To use: Initialize I2C FIRST
;			Initialize LCD
;			To send a command: Load AR0 with desired send value and call LCD_COMMAND
;			To send a single character: Load AH with the desired value and call LCD_DATA
;			To send a string: Load AR0 with a pointer to null-terminated string, then call LCD_STRING
;
;*******************************************************************************************




	.include "F2833x_Register_Defines.asm"
	.ref I2C_SEND
	.def LCD_STRING,LCD_CLEAR,LCD_LINE2,LCD_INIT


lcdaddr		.set 0x7E ;(0x3f with ~W at LSB)


	.sect ".text"

;**********SUBROUTINE***********
;this subroutine initializes LCD
LCD_INIT:

	EALLOW
	;send 0x33 manually
	;LC LCD_15msDELAY
	PUSH #0x30
	PUSH #lcdaddr
	LC I2C_SEND
	LC LCD_40usDELAY
	PUSH #0x30
	PUSH #lcdaddr
	LC I2C_SEND

	;send 0x32 manually
	LC LCD_40usDELAY
	PUSH #0x30
	PUSH #lcdaddr
	LC I2C_SEND
	LC LCD_40usDELAY
	PUSH #0x20
	PUSH #lcdaddr
	LC I2C_SEND

	;send 0x28
	MOV AR0,#0x28
	LC LCD_COMMAND

	;send 0x08
	MOV AR0,#0x08
	LC LCD_COMMAND

	;send 0x0F
	MOV AR0,#0x0F
	LC LCD_COMMAND

	;send 0x01
	MOV AR0,#0x01
	LC LCD_COMMAND

	LRET
;***********************************


;**********SUBROUTINE************
;send character in AH to LCD data (loaded from AR0)
LCD_DATA:
	PUSH AR0

	MOV AR0, AH

	;send upper nibble
	LC LCD_4100usDELAY			;delay
	MOV AH,AR0					;get data in AH
	AND AH,#0x00F0				;AND the top nibble
	OR AH,#0x000D				;send with D as lower nibble
	PUSH AH
	PUSH #lcdaddr
	LC I2C_SEND
	LC LCD_100usDELAY
	MOV AH,AR0					;get data in AH
	AND AH,#0x00F0				;AND the top nibble
	OR AH,#0x0009				;send with 9 as lower nibble
	PUSH AH
	PUSH #lcdaddr
	LC I2C_SEND
	LC LCD_4100usDELAY

	;send lower nibble
	LC LCD_4100usDELAY
	MOV AH, AR0
	AND AH,#0x000F				;mask the lower nibble
	LSL AH,#0x4					;shift left 4 times
	OR AH,#0x000D				;send with D as lower nibble
	PUSH AH
	PUSH #lcdaddr
	LC I2C_SEND
	LC LCD_40usDELAY
	MOV AH, AR0
	AND AH,#0x0F				;mask lower nibble
	LSL AH,#0x4					;left shift 4 times
	OR AH,#0x09					;send with 9 as lower nibble
	PUSH AH
	PUSH #lcdaddr
	LC I2C_SEND
	LC LCD_4100usDELAY
	POP AR0
	LRET
;*********************************************


;********SUBROUTINE***********
;send character in AR0 to LCD command register  (similar to LCD_DATA but with RS low)
LCD_COMMAND:
;send upper nibble
	LC LCD_40usDELAY
	;mask with enable
	MOV AH,AR0
	AND AH,#0x00F0
	OR AH,#0x000C
	PUSH AH
	PUSH #lcdaddr
	LC I2C_SEND
	LC LCD_40usDELAY
	;mask with enable not
	MOV AH,AR0
	AND AH,#0x00F0
	OR AH,#0x0008
	PUSH AH
	PUSH #lcdaddr
	LC I2C_SEND
	LC LCD_40usDELAY

;send lower nibble
	MOV AH, AR0
	;mask with enable
	AND AH,#0x000F
	LSL AH,#0x4
	AND AH,#0x00F0
	OR AH,#0x000C
	PUSH AH
	PUSH #lcdaddr
	LC I2C_SEND
	LC LCD_40usDELAY
	MOV AH, AR0
	;mask with enable not
	AND AH,#0x0F
	LSL AH,#0x4
	AND AH,#0x00F0
	OR AH,#0x08
	PUSH AH
	PUSH #lcdaddr
	LC I2C_SEND
	LC LCD_4100usDELAY

	LRET
;***************************


;*********SUBROUTINE**************
;this subroutine sends a string pointed to by AR0
LCD_STRING:
	MOV AH,*AR0
	B LCD_STRING_END,EQ		;branch as long as character is not null
	LC LCD_DATA				;print to screen
	INC AR0
	B LCD_STRING,UNC
LCD_STRING_END:
	LRET
;***********************************


;*****MISC SUBROUTINES***********
;clear screen and return home
LCD_CLEAR:
	PUSH AR0
	MOV AR0,#0x01
	LC LCD_COMMAND
	POP AR0
	LRET

;drop to line 2
LCD_LINE2:
	PUSH AR0
	MOV AR0,#0xC0
	LC LCD_COMMAND
	POP AR0
	LRET

;********************************


;****DELAY FUNCTIONS****
LCD_40usDELAY:
	PUSH AH
	MOV AH,#0x15

LCD_40usDELAY_LOOP:
	DEC AH
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	B LCD_40usDELAY_LOOP,NEQ

	POP AH
	LRET






LCD_15msDELAY:
	PUSH AR0

	MOV AR0,#0x1FFF

LCD_15msDELAY_LOOP:
	DEC AR0
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	B LCD_15msDELAY_LOOP,NEQ

	POP AR0

	LRET




LCD_4100usDELAY:
	PUSH AR0

	MOV AR0,#0x8CF
LCD_4100usDELAY_LOOP:
	DEC AR0
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	B LCD_4100usDELAY_LOOP,NEQ

	POP AR0

	LRET





LCD_100usDELAY:
	PUSH AR0

	MOV AR0,#0x34

LCD_100usDELAY_LOOP:
	DEC AR0
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	B LCD_100usDELAY_LOOP,NEQ

	POP AR0

	LRET



