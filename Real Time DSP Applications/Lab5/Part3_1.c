/*
 *Part3.c
 *
 *This file  samples audio and then allows you to play it back at different frequencies, determined by your switches.
 */


#include<DSP28x_Project.h>
#include<EEL4511.h>

#pragma DATA_SECTION( buf , "Buffer")

void Init_Timer1( int sysclk, unsigned int period);

volatile circBuff_16 buf = { 0, 0, {0} };
volatile Uint16 state = 0;

interrupt void DAC_ISR()
{

	if(state == 1)						//fill buffer if state = 0
		buf.buffer[buf.head++] = ADC_in();
	else if (state == 2)								//else if 2, play sample
		DAC_out( buf.buffer[buf.head++] );

	if (buf.head >= BUFFER_SIZE)
	{
		buf.head = 0;
		state = 0;
		StopCpuTimer1();
	}

	CpuTimer1Regs.TCR.bit.TIF = 1;
}

int main()
{
	DisableDog();

	//75MHz
	InitPll(10,2);

	EALLOW;
	GpioCtrlRegs.GPAMUX1.bit.GPIO0 = 0;
	GpioCtrlRegs.GPADIR.bit.GPIO0 = 1;

	Init_McBSPb_ADC();
	Init_McBSPa_DAC();
	Init_SRAM();
	Init_LED();
	Init_SWITCH();

	Init_Timer1(75, 22);

	Uint16 switches = 0;

	while(1)
	{
		switches = SWITCH_read() & 0x000F;

		switch(switches)
		{
		case 0:
			state = 1; //record
			ConfigCpuTimer( &CpuTimer1 , 75 , 22);  //f=44100
			StartCpuTimer1();
			while( state == 1);  //wait until finished recording
		break;

		case 1:
			state = 2; //playback
			ConfigCpuTimer( &CpuTimer1 , 75 , 125);  //f=8k
			StartCpuTimer1();
			while( state == 2);  //wait until finished playing
		break;

		case 2:
			state = 2; //playback
			ConfigCpuTimer( &CpuTimer1 , 75 , 100);  //f=10k
			StartCpuTimer1();
			while( state == 2);  //wait until finished playing
		break;

		case 3:
			state = 2; //playback
			ConfigCpuTimer( &CpuTimer1 , 75 , 67);  //f=15k
			StartCpuTimer1();
			while( state == 2);  //wait until finished playing
		break;

		case 4:
			state = 2; //playback
			ConfigCpuTimer( &CpuTimer1 , 75 , 50);  //f=20k
			StartCpuTimer1();
			while( state == 2);  //wait until finished playing
		break;

		case 5:
			state = 2; //playback
			ConfigCpuTimer( &CpuTimer1 , 75 , 40);  //f=25k
			StartCpuTimer1();
			while( state == 2);  //wait until finished playing
		break;

		case 6:
			state = 2; //playback
			ConfigCpuTimer( &CpuTimer1 , 75 , 33);  //f=30k
			StartCpuTimer1();
			while( state == 2);  //wait until finished playing
		break;

		case 7:
			state = 2; //playback
			ConfigCpuTimer( &CpuTimer1 , 75 , 25);  //f=40k
			StartCpuTimer1();
			while( state == 2);  //wait until finished playing
		break;

		default:
		break;

		}
	}
}

void Init_Timer1(int sysclk,  unsigned int period)
{
	EALLOW;
	InitCpuTimers();

	ConfigCpuTimer( &CpuTimer1 , sysclk , period);

	PieVectTable.XINT13 = DAC_ISR;
	PieCtrlRegs.PIECTRL.bit.ENPIE = 1;

	IER |= M_INT13;

	EINT;

}
