;
; lab3b.asm
;
; Created: 2/20/2016 1:50:00 PM
; Author : Adrian
;


; Replace with your application code
.include "ATxmega128A1Udef.inc"

.set IO_PORT = 0x004000
.set IO_PORT_END = 0x007FFF

.org 0x0000
	rjmp MAIN

.org 0x0100
MAIN:
	ldi R16, 0b00010111 ;Configure PORTH bits 4, 2, 1, 0 as output
	sts PORTH_DIRSET, R16 ; let CS0, WE, RE, ALE1 be outputs
	
	ldi R16, 0b00010100  ;Set default of RE and WE to 1=H=false since they are active low
	sts PORTH_OUTSET, R16

	ldi R16, 0xFF	; Set all PORTK pins to output (address lines 0-15)
	sts PORTK_DIRSET, R16

	ldi R16, 0xFF ; Set all PORTJ pins to output (data line 0-7)
	sts PORTJ_DIRSET, R16

	ldi R16, 0x01	; 3port SRAM ALE1 mode
	sts EBI_CTRL, R16

	ldi ZH, high(EBI_CS0_BASEADDR) ; set Z as pointer to CS0 address space (data memory)
	ldi ZL, low(EBI_CS0_BASEADDR)

	ldi R16, byte2(IO_PORT)		; load byte2 of IO_PORT to CS0 BASEADDR
	st Z+, R16

	ldi R16, byte3(IO_PORT)		; load byte3 of IO_PORT to CS0 BASEADDR
	st Z, R16

	ldi R16, 0x19				; set 16K address size (4000-7FFF) and SRAM mode
	sts EBI_CS0_CTRLA, R16

	ldi R16, byte3(IO_PORT)  ; initialize pointer for reading memory mapped IO
	sts CPU_RAMPX, R16
	ldi XH, high(IO_PORT)
	ldi XL, 0x25

	ldi R16, 0xFF
	sts PORTE_DIRSET, R16

LOOP:
	ld R16, X
	nop
	st X, R16
	;sts PORTE_OUT, R16
	rjmp LOOP
