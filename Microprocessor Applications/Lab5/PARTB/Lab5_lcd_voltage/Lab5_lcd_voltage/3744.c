//include file and defines
#include <avr/io.h>
#include "ebi_driver.h"
#include "3744.h"

/*********FUNCTION**************
* NAME: ebi_init()
* FUNCTION: Initialize EBI bus to interface with LCD and IO port
* INPUTS: None
* OUTPUTS: None
*******************************/
void ebi_init(void)
{
	PORTH.DIRSET = 0x37; // Set RE, WE, CS0, CS1, ALE1 bits as output
	PORTH.OUTSET = 0x33;
	
	PORTK.DIRSET = 0xFF; // Set PORTK to output (ADDR 7-0/15-8)
	PORTJ.DIRSET = 0xFF; // Set PORTJ to output (DATA7-0)
	
	EBI.CTRL = EBI_SRMODE_ALE1_gc | EBI_IFMODE_3PORT_gc; // Set EBI to 3 Port (H, J, K) SRAM ALE1 mode.
	
	//IO PORT setup on CS0
	EBI.CS0.BASEADDRH = (uint8_t) (IO_ADDR>>16) & 0xFF; //Set highest byte of IO port base address on CS0
	EBI.CS0.BASEADDRL = (uint8_t) (IO_ADDR>>8) & 0xFF; // Set middle byte of IO port base address on CS0
	EBI.CS0.CTRLA = (uint8_t) 0x19; //set IO Port to 16K address size and SRAM mode
	
	//LCD setup on CS1
	EBI.CS1.BASEADDRH = (uint8_t) (CS1_ADDR>>16) & 0xFF; //Set highest byte of LCD base address on CS1
	EBI.CS1.BASEADDRL = (uint8_t) (CS1_ADDR>>8) & 0xFF; //Set middle byte of IO port base address on CS1
	EBI.CS1.CTRLA = (uint8_t) EBI_CS_ASPACE_64KB_gc | EBI_CS_MODE_SRAM_gc ;
}

/*********FUNCTION**************
* NAME: lcd_init()
* FUNCTION: Initiate Crystalfonz lcd screen. Must call ebi_init() first
* INPUTS: None
* OUTPUTS: None
*******************************/
void lcd_init(void)
{
	lcd_delay();//delay to allow device to start up
	__far_mem_write(LCD_instr, 0x38); //LCD 8 bit, 2 line mode
	lcd_wait();
	__far_mem_write(LCD_instr, 0x38); //LCD 8 bit, 2 line mode
	lcd_wait();
	__far_mem_write(LCD_instr, 0x0C); //turn LCD display on
	lcd_clr(); //clear lcd screen
	lcd_wait();
	__far_mem_write(LCD_instr, 0x06);// set cursor shift right and no screen shift
	lcd_pos(0,0);	
}

/*********FUNCTION**************
* NAME: lcd_home()
* FUNCTION: Return LCD cursor home. Must call ebi_init() and lcd_init() first
* INPUTS: None
* OUTPUTS: None
*******************************/
void lcd_home(void)
{
	lcd_wait();
	__far_mem_write(LCD_instr, 0x02);
	lcd_wait();
	lcd_pos(0,0);
}

/*********FUNCTION**************
* NAME: lcd_blink()
* FUNCTION: Blink Cursor. Must call ebi_init() and lcd_init() first
* INPUTS: None
* OUTPUTS: None
*******************************/
void lcd_blink_tgl(void)
{
	uint8_t x = (uint8_t)__far_mem_read(LCD_instr);
	lcd_wait();
	x ^= 1 << 0 ;	//toggle bit 0 (blink bit)
	__far_mem_write( LCD_instr, x);
}


/*********FUNCTION**************
* NAME: lcd_out()
* FUNCTION: Send 1 char out to lcd. Must call ebi_init() and lcd_init() first
* INPUTS: None
* OUTPUTS: None
*******************************/
void lcd_out(char value)
{
	lcd_wait();
	__far_mem_write(LCD_data, value);
}

/*********FUNCTION**************
* NAME: lcd_outstring()
* FUNCTION: Send char string to LCD. Must call ebi_init() and lcd_init() first
* INPUTS: None
* OUTPUTS: None
*******************************/
void lcd_outstring(char *value)
{
	while(*value != 0x00)
	{
	lcd_wait();
	__far_mem_write(LCD_data, *value);
	value++;
	}
}

/*********FUNCTION**************
* NAME: lcd_wait()
* FUNCTION: Wait function for lcd since xmega is too fast. Must call ebi_init() first
* INPUTS: None
* OUTPUTS: None
*******************************/
void lcd_wait(void)
{
	asm volatile ("nop");
	asm volatile ("nop");
	while(( __far_mem_read(LCD_instr) >> 7) == 0x01); //wait while busy flag on bit7 is high
}

/*********FUNCTION**************
* NAME: lcd_delay()
* FUNCTION: For use in lcd_init to allow device powerup. Must call ebi_init()first
* INPUTS: None
* OUTPUTS: None
*******************************/
void lcd_delay(void)
{
	volatile uint32_t ticks= 0;            //declare volatile so compiler won't optimize
	while(ticks<=(F_CPU>>10))  //enough delay to allow for LCD powerup
	{
		ticks++;
	}	
}

/*********FUNCTION**************
* NAME: lcd_clr()
* FUNCTION: clear lcs screen. Must call ebi_init()first
* INPUTS: None
* OUTPUTS: None
*******************************/
void lcd_clr(void)
{
	lcd_wait();
	__far_mem_write(LCD_instr, 0x01);
}

/*********FUNCTION**************
* NAME: lcd_pos(uint8_t x, uint8_t y)
* FUNCTION: Set LCD cursor to designated position. Must call ebi_init()first
* INPUTS: x position and y position
* OUTPUTS: None
*******************************/
void lcd_pos(uint8_t row, uint8_t col)
{
	uint8_t x = 0x00;
	if (row)
		x = 0x40;
	x |= (col & 0x0F);
	x |= (1 << 7);
	lcd_wait();
	__far_mem_write(LCD_instr, x);
}