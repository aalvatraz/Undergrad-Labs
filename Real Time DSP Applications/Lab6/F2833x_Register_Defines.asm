; Name: F2833x_Register_Defines.asm
; Author: Adrian Alvarez
; Class: EEE4511- Real Time DSP Applications
; Purpose: Register Defines File
; Description:
;
;    This files stores register defines for various, commonly used registers on the F28335 DSP
;*******************************************************************************************
;EALLOW Protected Registers
GPACTRL			.set	0x6f80			;GPIO A Control Register (GPIO0 to 31)
GPAQSEL1		.set	0x6f82			;GPIO A Qualifier Select 1 Register (GPIO0 to 15)
GPAQSEL2		.set	0x6f84			;GPIO A Qualifier Select 2 Register (GPIO16 to 31)
GPAMUX1			.set	0x6f86			;GPIO A MUX 1 Register (GPIO0 to 15)
GPAMUX2			.set	0x6f88			;GPIO A MUX 2 Register (GPIO16 to 31)
GPADIR			.set	0x6f8a			;GPIO A Direction Register (GPIO0 to 31)
GPAPUD			.set	0x6f8c			;GPIO A Pull Up Disable Register (GPIO0 to 31)
GPBCTRL			.set	0x6f90			;GPIO B Control Register (GPIO32 to 63)
GPBQSEL1		.set	0x6f92			;GPIO B Qualifier Select 1 Register (GPIO32 to 47)
GPBQSEL2		.set	0x6f94			;GPIO B Qualifier Select 2 Register (GPIO48 to 63)
GPBMUX1			.set	0x6f96			;GPIO B MUX 1 Register (GPIO32 to 47)
GPBMUX2			.set	0x6f98			;GPIO B MUX 2 Register (GPIO48 to 63)
GPBDIR			.set	0x6f9a			;GPIO B Direction Register (GPIO32 to 63)
GPBPUD			.set	0x6f9c			;GPIO B Pull Up Disable Register (GPIO32 to 63)
GPCMUX1			.set	0x6fa6			;GPIO C MUX1 Register (GPIO64 to 79)
GPCMUX2			.set	0x6fa8			;GPIO C MUX2 Register (GPIO80 to 87)
GPCDIR			.set	0x6faa			;GPIO C Direction Register (GPIO64 to 87)
GPCPUD			.set	0x6fac			;GPIO C Pull Up Disable Register (GPIO64 to 87)

;Non EALLOW Protected Registers
GPADAT			.set	0x6fc0			;GPIO A Data Register (GPIO0 to 31)
GPASET			.set    0x6fc2			;GPIO A Data Set Register (GPIO0 to 31)
GPACLEAR		.set	0x6fc4			;GPIO A Data Clear Register (GPIO0 to 31)
GPATOGGLE		.set	0x6fc6			;GPIO A Data Toggle Register (GPIO0 to 31)
GPBDAT			.set	0x6fc8			;GPIO B Data Register (GPIO32 to 63)
GPBSET			.set	0x6fca			;GPIO B Data Set Register (GPIO32 to 63)
GPBCLEAR		.set	0x6fcc			;GPIO B Data Clear Register (GPIO32 to 63)
GPBTOGGLE		.set	0x6fce			;GPIO B Data Toggle Register (GPIO32 to 63)
GPCDAT			.set	0x6fd0			;GPIO C Data Register (GPIO64 to 87)
GPCSET			.set	0x6fd2			;GPIO C Data Set Register (GPIO64 to 87)
GPCCLEAR		.set	0x6fd4			;GPIO C Data Clear Register (GPIO64 to 87)
GPCTOGGLE		.set	0x6fd6			;GPIO C Data Toggle Register (GPIO64 to 87)

;MISC Registers
WDRC			.set	0x7029				;Watchdog Register

;Constants
BIT0			.set	0x1
BIT1			.set	0x2
BIT2			.set	0x4
BIT3			.set	0x8
BIT4			.set	0x10
BIT5			.set	0x20
BIT6			.set	0x40
BIT7			.set	0x80
BIT8			.set	0x100
BIT9			.set	0x200
BIT10			.set	0x400
BIT11			.set	0x800
BIT12			.set	0x1000
BIT13			.set	0x2000
BIT14			.set	0x4000
BIT15			.set	0x8000
