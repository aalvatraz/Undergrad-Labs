/*
 * Lab6_PartA.c
 *
 * Created: 3/31/2016 6:06:41 PM
 * Author : Adrian
 * Section: 3189
 * TA: Madison Emas
 * Description: This program uses TC to output a square waveform on PORTE PIN0 when a switch input is true
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>
#define PCLK 2000000

void freq_init(void);
void delay_ms(int x);
void freq_out(float freq, float prescale);

int main(void)
{
	PORTE.DIR = (1 << 0) ; //set OC pin as output
	PORTE.DIRCLR = (1 << 7) ; //set switch as input
	freq_init();
		
	//
    while (1)
	{
		if ((PORTE.IN & 0x80) == 0x80)
			freq_out(1760.0, 1);
		else
			freq_out(0, 0);
	}
	
}

void freq_init(void)
{
	
	//select waveform mode
	//enable CCx via CCxEN
	TCE0.CTRLA = TC_CLKSEL_DIV1_gc; //prescaler values, do math to get good freq value
	TCE0.CTRLB = TC0_WGMODE0_bm;//WGMODE(1<<0) ***DONT ENABLE YET***
	//TCE0.CTRLC = (1<<0)
	TCE0.CTRLD = 0;
	TCE0.CTRLE = TC_BYTEM_NORMAL_gc;
	TCE0.INTCTRLA = 0;
	TCE0.INTCTRLB = 0;
	TCE0.CTRLFSET = 0;
	//TCE0.CTRLGSET= //check bit1 to see if new value in CCxBUF
	//CNT = actual counter value (16 bit)
	//PER = TOP value (16 bit)
	//CCA = compare value
}

void delay_ms(int x)
{
	while(x != 0)
	{
		for( volatile uint8_t t = 82; t > 0; t--);
		x--;
	}
}

void freq_out(float freq, float prescale)
{
	if(freq != 0)
	{
		 uint16_t CCA8 = (uint16_t) ((((float) PCLK)/(2.0*freq*prescale))-1.0);
		 TCE0.PER = CCA8;
		 TCE0.CCA = CCA8;
		 TCE0.CTRLB = TC0_CCAEN_bm | TC0_WGMODE0_bm;
	}
	else
		TCE0.CTRLB &= !(1 << 4); //turn off CCA
	 
}