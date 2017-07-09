/*
 * Part2.c
 *
 * This is a basic sound in/sound out program which I use to sample at different rates by varying the timer period cycle.
 *
 */
#include <DSP28x_Project.h>
#include <EEL4511.h>

void Init_Timer1(void);
volatile Uint16 x = 0;


interrupt void DAC_ISR()
{
	x = ADC_in();

    DAC_out( x );
	GpioDataRegs.GPADAT.bit.GPIO0 ^= 1;
	CpuTimer1Regs.TCR.bit.TIF = 1;
}


int main(void) {

	DisableDog();

	//75MHz
	InitPll(10,3);

	Init_McBSPb_ADC();
	Init_McBSPa_DAC();
	Init_LED();
	Init_SWITCH();

	Init_Timer1();

	while(1);

}

void Init_Timer1(void)
{
	EALLOW;
	InitCpuTimers();

	ConfigCpuTimer( &CpuTimer1 , 150 , 22);

	PieVectTable.XINT13 = DAC_ISR;
	PieCtrlRegs.PIECTRL.bit.ENPIE = 1;

	IER |= M_INT13;

	EINT;

	StartCpuTimer1();

}
