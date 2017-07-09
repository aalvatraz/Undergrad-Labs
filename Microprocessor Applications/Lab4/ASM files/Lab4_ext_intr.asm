;
;Lab4_ext_intr.asm
;Name: Adrian Alvarez
;Section: 3189
;TA: Madison Emas
;Description: This interrupt driven program will count the number of times a switch is bouncing;The data will be displayed on the LEDs via the EBI bus (to avoid more wire wrapping)

.include "ATxmega128A1Udef.inc"

.equ stack = 0x3FFF

.org 0x0000
	rjmp MAIN

;put code in at the interrupt vector for the PORTx_INTn interrrupt
.org PORTF_INT0_VECT
	jmp EXT_INT_ISR

.org 0x0100
MAIN: 
	;set stack pointer
	ldi YH, high(stack)
	sts CPU_SPH, YH
	ldi YL, low(stack)
	sts CPU_SPL, YL

	;set data direction for output pin, clear port
	ldi R16, 0xFF
	sts PORTE_DIRSET, R16
	sts PORTE_OUTCLR, R16

	;call subroutine to initialize external interrupt on PORTE Pin 0
	rcall INIT_EXT_INT_ISR
LOOP:

	sts PORTE_OUT, R17

	rjmp LOOP
	




/******************************************************************
Name:    INIT_EXT_INT_ISR
Purpose: Subroutine to initialize external pin interrupt
Inputs:  None
Outputs: None
Affected: PMIC_CTRL, PORTF: _INT0MASK_OUT, INTCTRL, PIN0CTRL, _DIRSET
*******************************************************************/
INIT_EXT_INT_ISR:
	push R16

	;Select a pin in that port for the interrupt in one of the interrupt mask registers, PORTx_INTnMASK
	ldi R16, 0x01		; use Pin 0
	sts PORTF_INT0MASK, R16

	;set PORTE pin 2 to default to 1
	sts PORTF_OUT, R16

	;set PORTE pin 2 to input
	sts PORTF_DIRCLR, R16

	;set as low level interrupt
	sts PORTF_INTCTRL, R16

	;Select input/sense configuration to falling edge in PORTF_PIN0CTRL
	ldi R16, 0x02
	sts PORTF_PIN0CTRL, R16

	;Turn on PMIC interrupt level in the PMIC_CTRL register
	ldi R16, 0x01
	sts PMIC_CTRL, R16

	;clear R17 (where our result will be stored)
	clr R17

	sei  ;Set global interrupt enable

	pop R16

	ret  ;return from subroutine

/*********************************************
Name:     EXT_INT_ISR
Purpose:  ISR for pin 0 on PORTD
Inputs:   None
Outputs:  R17
Affected: None
*********************************************/
EXT_INT_ISR:
	rcall DELAY_100MS
	push R16
	lds R16, CPU_SREG	;push status register onto the stack 
	push R16

	
	lds R16, (PORTF_IN)
	sbrs R16, 0
	inc R17				;increment R17 if low(ISR count) and clear when R17 = 0xFF
	ldi R16, 0xFF		
	cp R16, R17
	breq CLR_COUNT
	rjmp EXT_INT_ISR_END

CLR_COUNT:
	clr R17 

EXT_INT_ISR_END:
	ldi	 R16, 0x01
	sts  PORTF_INTFLAGS, R16	; Clear the PORTF_INTFLAGS

	pop R16
	sts CPU_SREG, R16 ; return status register
	pop R16
	reti

/*******Delay 100 ms**************/
DELAY_100MS:
	push R16
	push R17
	push R18

	ldi R16, 0x00
	ldi R17, 0x00
	ldi R18, 0xC9
	
DELAY_100MS_LOOP1:
	cp R16, R18
	breq DELAY_100MS_LOOP2
	inc R16
	rjmp DELAY_100MS_LOOP1

DELAY_100MS_LOOP2:
	cp R17, R18
	breq DELAY_100MS_END
	inc R17
	clr R16
	rjmp DELAY_100MS_LOOP1

DELAY_100MS_END:
    pop R18
	pop R17
	pop R16
	ret

