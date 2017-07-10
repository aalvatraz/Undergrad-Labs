/*
 * Lab7_PartB.c
 *
 * Created: 4/8/2016 11:52:53 PM
 * Author : Adrian
 * Section: 3189
 * TA: Madison Emas
 * Description = TC and Interrupt driven waveform output on DAC CH0
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>

uint16_t wave[64]= {0x800,0x8c8,0x98f,0xa52,0xb0f,0xbc5,0xc71,0xd12,
					0xda7,0xe2e,0xea6,0xf0d,0xf63,0xfa7,0xfd8,0xff5,
					0xfff,0xff5,0xfd8,0xfa7,0xf63,0xf0d,0xea6,0xe2e,
					0xda7,0xd12,0xc71,0xbc5,0xb0f,0xa52,0x98f,0x8c8,
					0x800,0x737,0x670,0x5ad,0x4f0,0x43a,0x38e,0x2ed,
					0x258,0x1d1,0x159,0xf2,0x9c,0x58,0x27,0xa,
					0x0,0xa,0x27,0x58,0x9c,0xf2,0x159,0x1d1,
					0x258,0x2ed,0x38e,0x43a,0x4f0,0x5ad,0x670,0x737};

volatile int i_wave= 0;

void init_DAC(void);
void init_TC(float freq);

int main(void)
{
	init_DAC();
    init_TC(100); //duration for 64 sample/period @ 100 Hz
	while(1);
}

void init_TC(float freq)
{	
	//PORTE_DIR= 1;
	
	TCE0.CTRLA = TC_CLKSEL_DIV2_gc; //divide clock by 2
	TCE0.CTRLB = 0x0;
	TCE0.CTRLC = 0;
	TCE0.CTRLD = 0;
	TCE0.CTRLE = 0;
	TCE0.INTCTRLA = 1;
	TCE0.INTCTRLB = 0;
	TCE0.PER =  (uint16_t) (((((float) 2000000.0)/2.0)/(freq*64.0)));

	PMIC.CTRL = 1; //enable low level interrupt
	
	sei(); //enble gloabal interrupts
}

void init_DAC(void)
{
	PORTB_DIRCLR = PIN0_bm; //set AREFB as 2.5V input
	PORTB_DIRSET = PIN2_bm; //set DACB0 to output
	DACB.CTRLC = DAC_REFSEL_AREFB_gc; //set AREFB 
	DACB.CTRLB = DAC_CHSEL_SINGLE_gc; //rest not really needed
	DACB.CTRLA = DAC_CH0EN_bm | DAC_ENABLE_bm; //enable DAC
}

ISR(TCE0_OVF_vect)
{
	//PORTE_OUTTGL = 1; //toggle pin 1 (for checking 100 Hz frequency)
	while((DACB.STATUS & 1) == 0); //make sure DAC is ready
	DACB.CH0DATA = wave[i_wave++]; //set next sample in DAC
	if(i_wave == 64)	//restart period if needed
		i_wave = 0;
	
}