//include file and defines
#include <avr/io.h>
#include "ebi_driver.h"
#ifndef ADRIAN_3744
#define IO_ADDR 0x004000
#define CS1_ADDR 0x370000
#define LCD_instr  0x37A000
#define LCD_data 0x37A001
#define F_CPU 2000000

//Function prototypes

void ebi_init(void);
void lcd_init(void);
void lcd_delay(void);
void lcd_wait(void);
void lcd_home(void);
void lcd_clr(void);
void lcd_blink_tgl(void);
void lcd_out(char value);
void lcd_outstring(char *value);
void lcd_pos(uint8_t x, uint8_t y);
	

#endif