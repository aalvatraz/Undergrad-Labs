;
; lab2a.asm
; Lab 2 Part A
; Section: 3189
; TA: Madison Emas
; Author : Adrian
; Created: 1/26/2016 12:48:00 PM
; Description:
; This program sets PORTE pints to output and toggles their values. For use with LED Array.

.include "ATxmega128A1Udef.inc"

.org 0x0100

MAIN:	
	ldi R16, 0xFF					;load R16 with Pin directions (All pins to output)
	sts PORTE_DIRSET, R16			; set pins to output
	sts PORTE_OUT, R16				; Set Pins high

TOGGLE:
	sts PORTE_OUTTGL, R16			; toggle pins
	rjmp TOGGLE						; loop forever


