/*
 * main.c
 */
#include <DSP28x_Project.h>
#include "adrian.h"

void Init_Timer1(void);


interrupt void DAC_ISR()
{
	volatile Uint16 isr_state;
	isr_state &= 0x1;
	isr_state ^= 1;
	LCD_home();

	if (isr_state){
	DAC_out(0xFFFF);
	}
	else{
		DAC_out(0x0000);
	}

	volatile Uint16 input = ADC_in();
	volatile float voltage = word2float(input);
	LCD_float(voltage);
	CpuTimer1Regs.TCR.bit.TIF = 1;

}

int main(void)
{
  	DisableDog();

	//75MHz
	InitPll(10,2);

	Init_McBSPb_ADC();
	Init_McBSPa_DAC();
	Init_LCD();

//	Init_Timer1();

	while(1);


}



void Init_Timer1(void)
{
	EALLOW;
	InitCpuTimers();

	ConfigCpuTimer( &CpuTimer1 , 75 , 100000);

	PieVectTable.XINT13 = DAC_ISR;
	PieCtrlRegs.PIECTRL.bit.ENPIE = 1;

	IER |= M_INT13;

	EINT;

	StartCpuTimer(&CpuTimer1);

}
