/*
 * Lab7_PartD.c
 *
 * Created: 4/11/2016 9:18:27 AM
 * Author : Adrian
 * Section: 3189
 * TA: Madison Emas
 * Description = DMA Driven Sin wave on DACB CH0
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>

uint16_t sinwave[64]=  {0x0800, 0x08c8, 0x098f, 0x0a52, 0x0b0f, 0x0bc5, 0x0c71, 0x0d12,
						0x0da7, 0x0e2e, 0x0ea6, 0x0f0d, 0x0f63, 0x0fa7, 0x0fd8, 0x0ff5,
						0x0fff, 0x0ff5, 0x0fd8, 0x0fa7, 0x0f63, 0x0f0d, 0x0ea6, 0x0e2e,
						0x0da7, 0x0d12, 0x0c71, 0x0bc5, 0x0b0f, 0x0a52, 0x098f, 0x08c8,
						0x0800, 0x0737, 0x0670, 0x05ad, 0x04f0, 0x043a, 0x038e, 0x02ed,
						0x0258, 0x01d1, 0x0159, 0x00f2, 0x009c, 0x0058, 0x0027, 0x000a,
						0x0000, 0x000a, 0x0027, 0x0058, 0x009c, 0x00f2, 0x0159, 0x01d1,
						0x0258, 0x02ed, 0x038e, 0x043a, 0x04f0, 0x05ad, 0x0670, 0x0737};

uint16_t triwave[64]=  {0x80,0x100,0x180,0x200,0x280,0x300,0x380,0x400,
						0x480,0x500,0x580,0x600,0x680,0x700,0x780,0x800,
						0x87f,0x8ff,0x97f,0x9ff,0xa7f,0xaff,0xb7f,0xbff,
						0xc7f,0xcff,0xd7f,0xdff,0xe7f,0xeff,0xf7f,0xfff,
						0xf7f,0xeff,0xe7f,0xdff,0xd7f,0xcff,0xc7f,0xbff,
						0xb7f,0xaff,0xa7f,0x9ff,0x97f,0x8ff,0x87f,0x800,
						0x780,0x700,0x680,0x600,0x580,0x500,0x480,0x400,
						0x380,0x300,0x280,0x200,0x180,0x100,0x80,0x0};

void init_TC(float freq);
void init_DMA_DAC(uint8_t wavesel);
void init_DAC(void);
void keypad_init(void);
char getKey(void);
void setFreq(float freq);

int main(void)
{
	init_DAC();
	init_DMA_DAC(1);
	keypad_init();
	init_TC(100);
	char key = ' ';
	PMIC.CTRL = 1;
	sei();
    /* Replace with your application code */
    while (1) 
    {
		while( key == ' ')
		{
			key = getKey();
		}
		
		switch(key)
		{
			case '0': 
			setFreq(0);
			break;
			
			case '1':
			setFreq(100);
			break;
			
			case '2' : 
			setFreq(200);
			break;
			
			case '3':
			setFreq(300);
			break;
			
			case '4' : 
			setFreq(400);
			break;
			
			case '5':
			setFreq(500);
			break;
			
			case '6' : 
			setFreq(600);
			break;
			
			case '7':
			setFreq(700);
			break;
			
			case '8':
			setFreq(800);
			break;
			
			case '9':
			setFreq(900);
			break;
			
			case 'A':
			setFreq(1000);
			break;
			
			case 'B':
			TCE0.CTRLA = TC_CLKSEL_DIV1_gc;
			TCE0.PER =  (uint16_t) (((((float) 2000000.0)/1.0)/(1100*64.0))+1);
			break;
			
			case 'C':
			TCE0.CTRLA = TC_CLKSEL_DIV1_gc;
			TCE0.PER =  (uint16_t) (((((float) 2000000.0)/1.0)/(1118*64.0)));
			break;
			
			case 'D':
			TCE0.CTRLA = TC_CLKSEL_DIV1_gc;
			TCE0.PER =  (uint16_t) (((((float) 2000000.0)/1.0)/(1300*64.0)));
			break;
			
			case '#':
			init_DMA_DAC(0);
			break;
			
			case '*':
			init_DMA_DAC(1);
			break;
			
			default:
			break;
		}
		key = ' ';
	}
    }



void init_TC(float freq)
{
	PORTE_DIR = PIN1_bm;
	
	TCE0.CTRLA = TC_CLKSEL_DIV2_gc; //divide clock by 256
	TCE0.CTRLB = 0x0;
	TCE0.CTRLC = 0;
	TCE0.CTRLD = 0;
	TCE0.CTRLE = 0;
	TCE0.INTCTRLA = 1;
	TCE0.INTCTRLB = 0;
	TCE0.PER =  (uint16_t) (((((float) 2000000.0)/2.0)/(freq*64.0)));
}

void init_DMA_DAC(uint8_t wavesel)
{
	DMA.CTRL = 0;
	DMA.CTRL = DMA_RESET_bm;
	
	DMA.CH0.CTRLA = DMA_CH_BURSTLEN_2BYTE_gc | DMA_CH_REPEAT_bm | DMA_CH_SINGLE_bm;
	DMA.CH0.CTRLB = 0;
	DMA.CH0.ADDRCTRL = DMA_CH_SRCRELOAD_BLOCK_gc | DMA_CH_SRCDIR_INC_gc | DMA_CH_DESTRELOAD_BURST_gc | DMA_CH_DESTDIR_INC_gc;
	DMA.CH0.TRIGSRC = DMA_CH_TRIGSRC_TCE0_OVF_gc;
	DMA.CH0.TRFCNT = 128;
	DMA.CH0.REPCNT = 0;
	
	if(wavesel == 0)
	{
		DMA.CH0.SRCADDR0 = (uint8_t) (&triwave);
		DMA.CH0.SRCADDR1 = (uint8_t) ((uint32_t)&triwave >> 8);
		DMA.CH0.SRCADDR2 = (uint8_t) ((uint32_t)&triwave >> 16);
	
	}
	else
	{
		DMA.CH0.SRCADDR0 = (uint8_t) (&sinwave);
		DMA.CH0.SRCADDR1 = (uint8_t) ((uint32_t)&sinwave >> 8);
		DMA.CH0.SRCADDR2 = (uint8_t) ((uint32_t)&sinwave >> 16);
	}
	
	DMA.CH0.DESTADDR0 = (uint8_t) (&DACB.CH0DATA);
	DMA.CH0.DESTADDR1 = (uint8_t) ((uint32_t)&DACB.CH0DATA >> 8);
	DMA.CH0.DESTADDR2 = (uint8_t) ((uint32_t)&DACB.CH0DATA >> 16);
	
	DMA.CTRL = DMA_ENABLE_bm;
	DMA.CH0.CTRLA |= DMA_CH_ENABLE_bm;
}

void init_DAC(void)
{
	PORTB_DIRCLR = PIN0_bm; //set AREFB as 2.5V input
	PORTB_DIRSET = PIN2_bm; //set DACB0 to output
	DACB.CTRLC = DAC_REFSEL_AREFB_gc; //set AREFB
	DACB.CTRLB = DAC_CHSEL_SINGLE_gc; //rest not really needed
	DACB.CTRLA = DAC_CH0EN_bm | DAC_ENABLE_bm; //enable DAC
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

void setFreq(float freq)
{
	if(freq == 0)
		TCE0.CTRLA = 0;
	else
	{
		TCE0.CTRLA = TC_CLKSEL_DIV2_gc;
		TCE0.PER =  (uint16_t) (((((float) 2000000.0)/2.0)/(freq*64.0)));
	}
	
}

ISR(TCE0_OVF_vect)
{
	//C clears the flag for us
}