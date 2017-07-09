/*
 * Lab5_lcd_voltage.c
 *
 * Created: 3/21/2016 4:10:52 AM
 * Author : Adrian
 */ 

#include <avr/io.h>
#include "ebi_driver.h"
#define IO_ADDR 0x004000
#define CS1_ADDR 0x370000
#define LCD_instr 0x37A000
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
void adc_init(void);
float getVoltage(void);
void lcd_voltage(float voltage);
//int floatToHexChar(float x);

uint16_t getVoltage16(void)
{
	ADCB.CTRLA = 0x05; //start channel 0, single ended
	while((ADCB.INTFLAGS & 0x01) == 0 );
	int16_t x = (int16_t) (ADCB.CH0.RES) ;
	//if( ( ( x >> 15 ) & 1) == 1)
	//{
	//	x = 0;
	//}
	
	ADCB.INTFLAGS |= 1 << 0;
	return x;
}

void lcd_voltage16(uint16_t voltage)
{
	char char1, char2, char3;
	char1 = ((voltage>>8) & 0xF) | 0x30;
	lcd_out(char1);
	char2 = ((voltage>>4) & 0xF) | 0x30;
	lcd_out(char2);
	char3 = ((voltage>>0) & 0xF) | 0x30;
	lcd_out(char3);
	// don't have the hex display here yet

}

int main(void)
{
    ebi_init();
	lcd_init();
	adc_init();
	float voltage;
	int16_t voltage16;
	
    while (1) 
    {
		lcd_home();
		voltage= getVoltage();//3.142; //
		if(voltage >= 0.01)
		lcd_voltage(voltage);
		lcd_delay();
	}
}

/*********FUNCTION**************            
* FUNCTION: Initialize ADC
* INPUTS: None
* OUTPUTS: None
*******************************/
void adc_init(void)
{
	PORTB.DIRCLR = PIN7_bm | PIN0_bm; //set pin7 and pin0(2.5V ref) as input
	
	ADCB.CTRLA = ADC_FLUSH_bm;
	ADCB.CTRLB = ADC_CONMODE_bm | ADC_RESOLUTION_12BIT_gc;
	ADCB.REFCTRL = ADC_REFSEL_AREFB_gc;
	ADCB.PRESCALER = ADC_PRESCALER_DIV64_gc;
	ADCB.CTRLA= ADC_ENABLE_bm;
	ADCB.CH0.CTRL = ADC_CH_INPUTMODE_DIFF_gc | ADC_CH0START_bm;
	ADCB.CH0.MUXCTRL = 0x3F;
	ADCB.CH0.INTCTRL= 0;
}

/*********FUNCTION**************
* NAME: getVoltage()
* FUNCTION: Get voltage from ADC (single conversion). must call adc_init() first
* INPUTS: None
* OUTPUTS: float type value for voltage
*******************************/
float getVoltage(void)
{
	ADCB.CTRLA = 0x05; //start channel 0 conversion, single ended	
	while((ADCB.CH0.INTFLAGS & 0x01) == 0 );
	float x = (float) (ADCB.CH0.RES) ;
	if(x < 0)
	{
		x = 0;
	}
	else
	{
		x *= 5.0; //convert to volts
		x /= 2047.0;
	}
	return x;
}



/*********FUNCTION**************
* NAME: lcd_voltage()
* FUNCTION: display voltage on LCD
* INPUTS: float value for voltage from ADC
* OUTPUTS: None
*******************************/
void lcd_voltage(float voltage)
{
	char firstdigit, seconddigit, thirddigit;// to get digit values
	firstdigit = (int) voltage; //cast voltage as int to get first digit
	lcd_out((char) (firstdigit + 0x30));	//display first digit
	lcd_out('.');
	float voltage2 = 10*(voltage - firstdigit); //move next digit to 1s place
	seconddigit = (int) voltage2;	//get second digit via type cast
	lcd_out((char) (seconddigit + 0x30));	//display 2nd digit
	float voltage3 = 10*(voltage2 - seconddigit); //get and display 3rd digit
	thirddigit = (int) voltage3;
	lcd_out((char) (thirddigit + 0x30));
	lcd_out('V');
	// don't have the hex display here yet

}


/*********FUNCTION**************
* NAME: ebi_LCD_init()
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
void lcd_blink(uint8_t on)
{
	if(on == 1)
	{
		lcd_wait();
		__far_mem_write( LCD_instr, 0x0F);
	}
	else
	{
		lcd_wait();
		__far_mem_write( LCD_instr, 0x0C);
	}
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

/*int floatToHexChar(float x)
{
	uint8_t xh = ((uint8_t) x>>3) & 0xF;
	uint8_t xm = (uint8_t) x & 0xF;
	uint8_t xl = (uint8_t)( (int) x & 0xF);
	
	if(xh > 0x9) xh |= 0x40;	
	else xh |= 0x30;
	
	if(xm > 0x9) xm |= 0x40;
	else xm |= 0x30;
	
	if(xl > 0x9) xl |= 0x40;
	else xl |= 0x30;
	int y = (xh<<7)|(xm<<3)|(xl);
	return y;
}
*/
