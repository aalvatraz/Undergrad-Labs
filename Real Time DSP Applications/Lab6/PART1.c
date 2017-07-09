/*
 * PART1.c
 *
 * This program implements the lowpass filter for Lab6
 * using a for-loop.
 *
 * Filter Coefficients generated with matlab.
 */
#include<DSP28x_Project.h>
#include<EEL4511.h>

#pragma DATA_SECTION( audio , "ChipMEM")

void Init_Timers(void);

volatile circBuff_f audio = { 0, 0, {0} };
volatile float outputF = 0.0;
volatile Uint16 output16 = 0;
volatile Uint16 state = 0;

Filter LPF = {0, {0.008275,
				0.009130,
				0.013588,
				0.018919,
				0.025016,
				0.031684,
				0.038687,
				0.045725,
				0.052458,
				0.058560,
				0.063696,
				0.067589,
				0.070015,
				0.070845,
				0.070015,
				0.067589,
				0.063696,
				0.058560,
				0.052458,
				0.045725,
				0.038687,
				0.031684,
				0.025016,
				0.018919,
				0.013588,
				0.009130,
				0.008275} };

volatile int taps_p = 0;



void Init_Timer1(void);

interrupt void DAC_ISR()
{
	//store ADC value

		audio.buffer[audio.head] = (float) ADC_in();
		audio.head = ( ( audio.head + 1 ) & (BUFFER_SIZE - 1) );
		state = 1;

	GpioDataRegs.GPADAT.bit.GPIO0 ^= 1;
	CpuTimer1Regs.TCR.bit.TIF = 1; //not needed
}


int main(void) {

	DisableDog();

	//150MHz
	InitPll(10,3);

	Init_McBSPb_ADC();
	Init_McBSPa_DAC();
	Init_LED();

	Init_Timer1();

	while(1)
	{

		if(state == 1)
		{
			outputF = 0;

			for(LPF.point = 0 ; LPF.point < 26; LPF.point++)
			{
				//return index position
				audio.tail = ( ( audio.head - LPF.point ) & (BUFFER_SIZE - 1) );
				outputF += ( ( audio.buffer[ audio.tail  ] ) * LPF.coeff[LPF.point] );
			}

			state = 0;

			GpioDataRegs.GPADAT.bit.GPIO1 ^= 1;
			DAC_out((Uint16) outputF);
		}

	}

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
