/*
 * main.c
 */
#include <DSP28x_Project.h>
#include <EEL4511.h>

void Init_Timer1(void);

interrupt void DAC_ISR()
{
	DAC_out( ADC_in() );
	CpuTimer1Regs.TCR.bit.TIF = 1;
}


int main(void) {
	
	DisableDog();

	//75MHz
	InitPll(10,2);

	Init_McBSPb_ADC();
	Init_McBSPa_DAC();
	Init_LCD();

	Init_Timer1();

	while(1);
}

void Init_Timer1(void)
{
	EALLOW;
	InitCpuTimers();

	ConfigCpuTimer( &CpuTimer1 , 75 , 100);

	PieVectTable.XINT13 = DAC_ISR;
	PieCtrlRegs.PIECTRL.bit.ENPIE = 1;

	IER |= M_INT13;

	EINT;

	StartCpuTimer1();

}

