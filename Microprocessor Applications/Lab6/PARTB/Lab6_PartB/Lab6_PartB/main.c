/*
 * Lab6_PartB.c
 *
 * Created: 4/1/2016 2:00:09 AM
 * Author : Adrian
 * Section: 3189
 * TA: Madison Emas
 * Description: This program uses 2 TCs to create a musical keypad
 *
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>
#include "ebi_driver.h"
//DEFINES
#define IO_ADDR 0x004000
#define CS1_ADDR 0x370000
#define LCD_instr  0x37A000
#define LCD_data 0x37A001
#define F_CPU 2000000
#define val 2000000
#define A5 880
#define As5 932
#define B5 988
#define C6 1047
#define Cs6 1109
#define D6 1175
#define Ds6 1245
#define E6 1319
#define F6 1397
#define Fs6 1480
#define G6 1568
#define Gs6 1661
#define A6 1760
#define C7 2093
//PROTOTYPES
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
char getKey(void);
void delay_ms(int x);
void pulse_init(void);
void pulse_out(float freq, float duration);
void playZelda(void);
void playArp(void);

volatile int i;

int main(void)
{
	//INITIALIZATIONS
	ebi_init();
	lcd_init();
	keypad_init();
	pulse_init();
	PORTE.DIR = 0x01 ; //set OC0, 1 pin as output
	char note;
	//MAIN LOOP
    while(1)
	{
		note = getKey();
		switch(note)
		{
			case '1':
			lcd_clr();
			lcd_home();
			lcd_outstring("C6");
			lcd_pos(1, 0);
			lcd_outstring("1046.5 Hz");
			pulse_out(1046.5, 0.5678);
			
			break;
			
			case '2':
			lcd_clr();
			lcd_home();
			lcd_outstring("C#6");
			lcd_pos(1, 0);
			lcd_outstring("1108.73 Hz");
			pulse_out(1108.73, 0.5678);
			break;
			
			case '3':
			lcd_clr();
			lcd_home();
			lcd_outstring("D6");
			lcd_pos(1, 0);
			lcd_outstring("1173.66 Hz");
			pulse_out(1173.66, 0.5678);
			break;
			
			case '4':
			lcd_clr();
			lcd_home();
			lcd_outstring("D#6");
			lcd_pos(1, 0);
			lcd_outstring("1244.51 Hz");
			pulse_out(1244.51, 0.5678);
			break;
			
			case '5':
			lcd_clr();
			lcd_home();
			lcd_outstring("E6");
			lcd_pos(1, 0);
			lcd_outstring("1318.51 Hz");
			pulse_out(1318.51, 0.5678);
			break;
			
			case '6':
			lcd_clr();
			lcd_home();
			lcd_outstring("F6");
			lcd_pos(1, 0);
			lcd_outstring("1396.91 Hz");
			pulse_out(1396.91, 0.5678);
			break;
			
			case '7':
			lcd_clr();
			lcd_home();
			lcd_outstring("F#6");
			lcd_pos(1, 0);
			lcd_outstring("1479.98 Hz");
			pulse_out(1479.98, 0.5678);
			break;
			
			case '8':
			lcd_clr();
			lcd_home();
			lcd_outstring("G6");
			lcd_pos(1, 0);
			lcd_outstring("1567.98 Hz");
			pulse_out(1567.98, 0.5678);
			break;
			
			case '9':
			lcd_clr();
			lcd_home();
			lcd_outstring("G#6");
			lcd_pos(1, 0);
			lcd_outstring("1661.22 Hz");
			pulse_out(1661.22, 0.5678);
			break;
			
			case '0':
			lcd_clr();
			lcd_home();
			lcd_outstring("A6");
			lcd_pos(1, 0);
			lcd_outstring("1760.0 Hz");
			pulse_out(1760.0, 0.5678);
			break;
			
			case 'A':
			lcd_clr();
			lcd_home();
			lcd_outstring("A#6");
			lcd_pos(1, 0);
			lcd_outstring("1864.66 Hz");
			pulse_out(1864.66, 0.5678);
			break;
			
			case 'B':
			lcd_clr();
			lcd_home();
			lcd_outstring("B6");
			lcd_pos(1, 0);
			lcd_outstring("1975.53 Hz");
			pulse_out(1975.53, 0.5678);
			break;
			
			case 'C':
			lcd_clr();
			lcd_home();
			lcd_outstring("C7");
			lcd_pos(1, 0);
			lcd_outstring("2093.0 Hz");
			pulse_out(2093.0, 0.5678);
			break;
			
			case 'D':
			lcd_clr();
			lcd_home();
			lcd_outstring("Db7");
			lcd_pos(1, 0);
			lcd_outstring("2217.46 Hz");
			pulse_out(2217.46, 0.5678);
			break;
			
			case '#':
			playZelda();
			break;
			
			case '*':
			playArp();
			break;
			
			default:
			break;
		}
	}

}

void pulse_init(void)
{
	
	//TCE for frequency generation
	TCE0.CTRLA = TC_CLKSEL_DIV1_gc; //prescaler values, do math to get good freq value
	TCE0.CTRLB = TC0_WGMODE0_bm;//WGMODE(1<<0) ***DONT ENABLE YET***
	//TCE0.CTRLC = (1<<0)
	TCE0.CTRLD = 0;
	TCE0.CTRLE = TC_BYTEM_NORMAL_gc;
	TCE0.INTCTRLA = 0;
	TCE0.INTCTRLB = 0;
	TCE0.CTRLFSET = 0;
	//TCE0.CTRLGSET= //check bit1 to see if new value in CCxBUF

	PMIC.CTRL = 1; //enable low level interrupts

	//TCD for duration generation
	TCD0.CTRLA = TC_CLKSEL_DIV64_gc; //prescaler values, do math to get good freq value
	TCD0.CTRLB = 0x00;//Normal mode
	TCD0.CTRLD = 0;
	TCD0.CTRLE = TC_BYTEM_NORMAL_gc;
	TCD0.INTCTRLA = 1; //enable low level overflow interrupt
	TCD0.INTCTRLB = 0;
	
	sei(); //enable interrupts
}

void delay_ms(int x) 
{
	while(x != 0)
	{
		for( volatile uint8_t t = 82; t > 0; t--);
		x--;
	}
}

void pulse_out(float freq, float duration)
{
	if(duration != 0)
	{
		uint16_t CCA16 = (uint16_t) ((((float) val)/(2.0*freq))-1.0);
		uint16_t PER16 = (uint16_t) (((((float) val)/64.0)*duration)-0x0DFF);
		TCE0.PER = CCA16;
		TCE0.CCA = CCA16;
		TCD0.PER = PER16;
		TCE0.CTRLB = TC0_CCAEN_bm | TC0_WGMODE0_bm; //start frequency
		TCD0.CTRLFSET |= (1 << 3); //restart duration timer
	}
	/*else if(freq == 0 && duration != 0)
	{
		TCE0.CTRLB &= !(1 << 4); //turn off CCA
		uint16_t PER16 = (uint16_t) (((((float) val)/64.0)*duration)-0x0DFF);
		TCD0.PER = PER16;
		TCD0.CTRLFSET |= (1 << 3); //restart duration timer
	}*/
	else
	TCE0.CTRLB &= !(1 << 4); //turn off CCA
	
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

void playZelda(void)
{
	cli();
	char* name = "Zelda Theme";
	char* artist = "Koji Kondo";
	lcd_clr();
	lcd_home();
	lcd_outstring(name);
	lcd_pos(1, 0);
	lcd_outstring(artist);
	float bpm = 90.0;
	float notes[40] = {E6, A5,  B5, Cs6,  D6,   E6,   0,  E6,   F6,  G6,  A6,  0,  A6,   0,  A6,  G6,  F6,  G6,  F6,  E6,  E6, D6,   0,   E6,  F6,  0, E6, D6,  C6, D6, E6,  D6, C6,  B5,  C6, D6,   0, F6,   0, E6};
	float dur[40] =  {1.0,  2, 0.5, 0.5, 0.5,  1.5,  .5, 0.5,  0.5, 0.5, 1.5, .5, .25, .25, 0.5, 0.5, 0.5, .75, 0.5, 1.5, 1.0, .5, 0.5,  0.5, 1.0, .5, .5, .5, 1.0, .5, 1.0, .5, .5, 1.5,  .5, .5, .25, .5, .25,  1.5};
		
	for(i = 0; i < 40; i++)
	{
		TCD0.INTFLAGS= 1;
		if(notes[i])
		pulse_out(notes[i], (float) ((60.0/bpm)*dur[i]));
		while((TCD0.INTFLAGS & 1) == 0);
	}
	sei();
	
}

void playArp(void)
{
	cli();
	lcd_clr();
	lcd_home();
	lcd_outstring("C Major");
	lcd_pos(1, 0);
	lcd_outstring("Arpeggio");
	float notes[]= {C6, E6, G6, C7, G6, E6, C6};
	float dur = 0.5678;
	for(i = 0; i < 7; i++)
	{
		TCD0.INTFLAGS= 1;
		if(notes[i])
		pulse_out(notes[i], dur);
		while((TCD0.INTFLAGS & 1) == 0);
	}
	sei();
}


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

ISR(TCD0_OVF_vect)
{
	pulse_out(0, 0);
}