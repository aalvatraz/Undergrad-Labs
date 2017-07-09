/*
 * Lab5_lcd_keypad.c
 *
 * Created: 3/21/2016 7:09:48 AM
 * Author : Adrian
 */ 

#include <avr/io.h>
#include "ebi_driver.h"
#include "3744.h"
#define IO_ADDR 0x004000
#define CS1_ADDR 0x370000
#define LCD_instr  0x37A000
#define LCD_data 0x37A001
#define F_CPU 2000000

void ebi_init(void);
void lcd_init(void);
void lcd_delay(void);
void lcd_wait(void);
void lcd_home(void);
void lcd_clr(void);
void lcd_blink(uint8_t on);
void lcd_out(char value);
void lcd_outstring(char *value);
void lcd_pos(uint8_t x, uint8_t y);
void keypad_init(void);
char getKey();
void displayName(void);
void displaySchwartz(void);
void displayVoltage(void);
void extra(void);
void adc_init(void);
float getVoltage(void);
void lcd_voltage(float voltage);

int main(void)
{
    /* Replace with your application code */
	ebi_init();
	lcd_init();
	adc_init();
	keypad_init();
	char key= ' ';
	//lcd_out(key);
while(1)
{
   while(key == ' ')
		{
			key = getKey();
		}
		switch(key)
		{
			case '0': case '1':
				displayName();
				break;
				
			case '2' : case '3':
				lcd_clr();
				lcd_home();
				lcd_blink(1);
				break;
				
			case '4' : case '5':
				displaySchwartz();
				break;
				
			case '6' : case '7':
				displayVoltage();
				break;
			default:
				extra();
				break;
    }
	key = ' ';
	lcd_blink(0);
}
}


void displayName(void)
{
	lcd_clr();
	lcd_home();
	char *name = "Adrian Alvarez";
	lcd_outstring(name);
}

void displaySchwartz(void)
{
	lcd_clr();
	lcd_home();
	char* top = "May the Schwartz";
	char* bottom = "be with you!";
	lcd_outstring(top);
	lcd_pos(1,0);
	lcd_outstring(bottom);
	
}

void displayVoltage(void)
{
	float voltage;
	lcd_clr();
	lcd_home();
	voltage = getVoltage();
	lcd_voltage(voltage);
}

/*********FUNCTION**************
* NAME: keypad_init()
* FUNCTION: Initializes PORT I/O config as well as Interrupt for PORTF pins 0xF0 on any edge
* INPUTS: None
* OUTPUTS: None
*******************************/
void keypad_init(void)
{
	PORTF_DIR = 0xF0;		//upper nibble as outputs
	PORTF_DIRCLR = 0x0F;	//lower nibble as inputs
	PORTF_PIN0CTRL = 0x10;	//set input pins as pulled down
	PORTF_PIN1CTRL = 0x10;
	PORTF_PIN2CTRL = 0x10;
	PORTF_PIN3CTRL = 0x10;
}

char getKey()
{
	uint8_t x;
	char result= ' '; //change to 0x00 to get main() to work
	for (int i = 0; i<4; i++)
	{
		PORTF_OUT = 1 << (i+4);
		asm volatile("nop");
		asm volatile("nop");
		x = (uint8_t) PORTF_IN;
		if(x == 0x11)
			result = 'D';
		else if(x == 0x12)
			result = 'C';
		else if(x == 0x14)
			result = 'B';
		else if(x == 0x18)
			result = 'A';
		else if(x == 0x21)
			result = '#';
		else if(x == 0x22)
			result = '9';
		else if(x == 0x24)
			result = '6';
		else if(x == 0x28)
			result = '3';
		else if(x == 0x41)
			result = '0';
		else if(x == 0x42)
			result = '8';
		else if(x == 0x44)
			result = '5';
		else if(x == 0x48)
			result = '2';
		else if(x == 0x81)
			result = '*';
		else if(x == 0x82)
			result = '7';
		else if(x == 0x84)
			result = '4';
		else if(x == 0x88)
			result = '1';
	}
	return result;
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

void extra(void)
{
	lcd_clr();
	lcd_home();
	char* dumble = " It's dangerous";
	char* dore = "  to go alone!";
	lcd_outstring(dumble);
	lcd_pos(1, 0);
	lcd_outstring(dore);
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
	ADCB.CH0.INTFLAGS ^= 1 << 0;
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