/*
 * Lab7_PartC.c
 *
 * Created: 4/9/2016 1:05:34 AM
 * Author : Adrian
 * Section: 3189
 * TA: Madison Emas
 * Description = DMA Driven Sin wave on DACB CH0
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>

uint16_t wave[64]= {0x0800, 0x08c8, 0x098f, 0x0a52, 0x0b0f, 0x0bc5, 0x0c71, 0x0d12,
					0x0da7, 0x0e2e, 0x0ea6, 0x0f0d, 0x0f63, 0x0fa7, 0x0fd8, 0x0ff5,
					0x0fff, 0x0ff5, 0x0fd8, 0x0fa7, 0x0f63, 0x0f0d, 0x0ea6, 0x0e2e,
					0x0da7, 0x0d12, 0x0c71, 0x0bc5, 0x0b0f, 0x0a52, 0x098f, 0x08c8,
					0x0800, 0x0737, 0x0670, 0x05ad, 0x04f0, 0x043a, 0x038e, 0x02ed,
					0x0258, 0x01d1, 0x0159, 0x00f2, 0x009c, 0x0058, 0x0027, 0x000a,
					0x0000, 0x000a, 0x0027, 0x0058, 0x009c, 0x00f2, 0x0159, 0x01d1,
					0x0258, 0x02ed, 0x038e, 0x043a, 0x04f0, 0x05ad, 0x0670, 0x0737};

volatile int i_wave = 0;

void init_TC(float freq);
void init_DMA_DAC(void);
void init_DAC(void);

int main(void)
{
	init_DAC();
	init_TC(100);
	init_DMA_DAC();
	
	PMIC.CTRL = PMIC_LOLVLEN_bm; //enable low&med level interrupts
	sei(); //enable global interrupts
    while (1);
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

void init_DMA_DAC(void)
{
	DMA.CTRL = 0;
	DMA.CTRL = DMA_RESET_bm;
	
	DMA.CH0.CTRLA = DMA_CH_BURSTLEN_2BYTE_gc | DMA_CH_REPEAT_bm | DMA_CH_SINGLE_bm;
  	DMA.CH0.CTRLB = 0;
	DMA.CH0.ADDRCTRL = DMA_CH_SRCRELOAD_BLOCK_gc | DMA_CH_SRCDIR_INC_gc | DMA_CH_DESTRELOAD_BURST_gc | DMA_CH_DESTDIR_INC_gc;
	DMA.CH0.TRIGSRC = DMA_CH_TRIGSRC_TCE0_OVF_gc;
	DMA.CH0.TRFCNT = 128;
	DMA.CH0.REPCNT = 0;
	
	DMA.CH0.SRCADDR0 = (uint8_t) (&wave);
	DMA.CH0.SRCADDR1 = (uint8_t) ((uint32_t)&wave >> 8);
	DMA.CH0.SRCADDR2 = (uint8_t) ((uint32_t)&wave >> 16);
	
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

ISR(TCE0_OVF_vect)
{
	//It is necessary to clear this flag in hardware
	//because it only gets cleared if DMA writes to the TCE0 registers
	//C clears the flag for us by setting this interrupt
}