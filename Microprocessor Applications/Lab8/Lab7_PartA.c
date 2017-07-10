/*
 * Lab7_PartA.c
 *
 * Created: 4/7/2016 9:11:18 PM
 * Author : Adrian
 * Section: 3189
 * TA: Madison Emas
 * Description = DAC Output on DACB CH0 (PB2)
 */ 

#include <avr/io.h>

void init_DAC(void);
void set_DAQ(float voltage);

int main(void)
{
	init_DAC();
	set_DAC(1.7);
    /* Replace with your application code */
    while (1) 
    {
    }
}

void init_DAC(void)
{
	PORTB_DIRCLR = PIN0_bm; //set AREFB as 2.5V input
	PORTB_DIRSET = PIN2_bm; //set DACB0 to output
	DACB.CTRLC = DAC_REFSEL_AREFB_gc;
	DACB.CTRLB = DAC_CHSEL_SINGLE_gc; //rest not really needed
	DACB.CTRLA = DAC_CH0EN_bm | DAC_ENABLE_bm; //enable DAC
}

void set_DAC(float voltage)
{
	if(voltage < 0 || voltage > 2.5)
		return;
	while((DACB.STATUS & 1) == 0);
	//DACB.CTRLA &= !DAC_CH0EN_bm | !DAC_ENABLE_bm ; //disable DAC
	DACB.CH0DATA = (uint16_t) (( 0xFFF*voltage)/2.5); //set data
	//DACB.CTRLA =  DAC_CH0EN_bm | DAC_ENABLE_bm; //enable DAC again;
}