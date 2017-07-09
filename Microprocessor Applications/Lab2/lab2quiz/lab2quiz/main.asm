;
; lab2quiz.asm
;
; Created: 2/1/2016 4:18:42 PM
; Author : Adrian
;
.equ stack = 0x3FFF

.org 0x0100

MAIN:
ldi YL, low(stack)
sts CPU_SPL, YL
ldi YH, high(stack)
sts CPU_SPH, YH
ldi R16, 0xFF
sts PORTE_DIRSET, R16
rcall KEYPAD_SETUP
ldi R22, 0xFF
START:
rcall GETKEY
sts PORTE_OUT, R16
ldi R23, 0x03
cp R16, R23
breq STATE1PRE

rjmp START

STATE1PRE:
rcall DELAY200
STATE1:
sts PORTE_OUT, R16
rcall GETKEY
ldi R23, 0x08
cp R16, R23
breq STATE2
ldi R23, 0xFF
cp R16, R23
breq STATE1
rjmp START

STATE2:
ldi R24, 0x80
ldi R18, 0x00
NIGHTRIDER:
rcall GETKEY
ldi R23, 0x08
cp R16, R23
brne START
sts PORTE_OUT, R24
lsr R24
rcall DELAY200
cp R24, R18
breq RESET
rjmp NIGHTRIDER
RESET:
ldi R24, 0x80
rjmp NIGHTRIDER




.org 0x0200

;------------KEYPAD_SETUP-----------------
;This subroutine is used in conjunction with GETKEY in order to pass a key value into R16
;This subroutine creates tables in program memory which will correspond to pin detection values and return values
; The idea was to try to minimize the amount of code needed and it MUST be called before calling GETKEY
KEYPAD_SETUP:		;name of subroutine
	TABLE_1:		; pointer to data
		.db 0x11, 0x12, 0x14, 0x18, 0x21, 0x22, 0x24, 0x28, 0x41, 0x42, 0x44, 0x48, 0x81, 0x82, 0x84, 0x88 ;data table for pin detection
	TABLE_2:
		.db 0x0D, 0x0C, 0x0B, 0x0A, 0x0F, 0x09, 0x06, 0x03, 0x00, 0x08, 0x05, 0x02, 0x0E, 0x07, 0x04, 0x01	;data table for return value
		ret

;------------GETKEY--------------
;This subroutine outputs a value into R16 by setting some pins in PORTF to input and output
; The upper nibble of PORTF are the output pins and the lower nibble are the pulled down inputs
; This function iterates through each row (bottom to top) and each column (right to left)
; It returns a hex value into R16 corresponding to the key that was pressed (default = 0xFF)
GETKEY:	
	;push all registers except r16
	push R17
	push R18
	push R19
	push R20
	push R21
	push ZL
	push ZH
GETKEY_SETUP:
	ldi ZL, low(TABLE_1 << 1)	;load Z register with Table address
	ldi ZH, high(TABLE_1 << 1)
	ldi R18, 0x00				;zero for comparison purposes 
	ldi R17, 0x10				;pull down resistor OPC for PINnCTRL
	ldi R21, 0x10				;data  displacement between TABLE_1 and TABLE_2
	sts PORTF_PIN0CTRL, R17		;set PORTF pins 0-3 to pulled down inputs
	sts PORTF_PIN1CTRL, R17
	sts PORTF_PIN2CTRL, R17
	sts PORTF_PIN3CTRL, R17
	ldi R17, 0xF0				;load R17 with 0b11110000
	sts PORTF_DIR, R17			;set pin indicated by R17 as outputs
	ldi R17, 0x10				;set R17 for first output pin
READPAD:
	cp R18, R17					;compare R17 and R18
	breq NO_KEY					; branch if R17 = R18
	sts PORTF_OUT, R17			;set pin indicated by R17 to high
	nop
	lds R19, PORTF_IN			;get PortF pins
	lpm R20, Z+					;get Table value for comparison, increment pointer
	cp R19, R20					;compare registers
	breq SETR16					;break if read value in R19 = data in Table (ie. break if key is pressed)
	lpm R20, Z+					;same for next row up
	cp R19, R20
	breq SETR16	
	lpm R20, Z+
	cp R19, R20
	breq SETR16	
	lpm R20, Z+
	cp R19, R20
	breq SETR16	
	lsl R17    ;shift R17 to the left to output to next col if no butons in current column were pressed
	rjmp READPAD
SETR16:			; set R16 if key is pressed
	dec ZL		; decrement ZL to obtain correct data since we already performed a post increment 
	ADD ZL, R21	; add displacement to get correct return value from Table_2
	lpm R16, Z	; load return value into R16
	rjmp RETURN	; jump to return
NO_KEY:
	ldi R16, 0xFF	;error code when no key is pressed
RETURN:
	;pop all registers
	pop ZH
	pop ZL
	pop R21
	pop R20
	pop R19
	pop R18
	pop R17
	ret	;return 










;-------------------DELAY------------------------------
;This subroutine takes in one parameter from R16 to choose how many 200us delays to create
;The result of this subroutine is a delay of (R16+1) x 200 microseconds
;To achieve 2.5 kHz, we use a delay of 400 us, therefore R16 is set to 0x01

				; subroutine at 0x0200
DELAY200:
	push R19			; push registers
	push R18
	push R17
	ldi R19, 0xFF		; load r19 and R18 with delay parameters
	ldi R18, 0x00
	ldi R17, 0x00
DELAY:
	cp R18, R19			; compare r18 to r19
	breq CHECK			; branch to CHECK if equal
	inc R18				; if not equal, increment r18
	rjmp DELAY			; loop back to delay
CHECK:
	cp R22, R17			;compare r17 to delay parameter in R22
	breq END_DELAY		; branch to END_DELAY if equal
	inc R17				; increment r17 if not equal
	dec R17
	dec R17
	inc R17
	inc R17
	clr R18
	rjmp DELAY			; jump to delay
END_DELAY:
	clr r17
END_DELAY2:
	inc r17
	cp R17, R19
	brne END_DELAY2
	pop R17				;pop registers
	pop R18
	pop R19
	ret					; return to MAIN
	
