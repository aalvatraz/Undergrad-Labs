/*
 *Part1.c
 *
 *This file samples data at 44.1kHz when switch[0] is true. Mixes audio when switch[1] = true and pays audio back when switch[2] is true.
 */


#include<DSP28x_Project.h>
#include<EEL4511.h>

#pragma DATA_SECTION( buf , "Buffer")

void Init_Timer1( int sysclk, unsigned int period);

volatile circBuff_16 buf = { 0, 0, {0} };
volatile Uint16 state = 1;
volatile Uint16 avg = 0;


interrupt void DAC_ISR()
{
	//GpioDataRegs.GPADAT.bit.GPIO0 ^= 1;

	switch(state)
	{
	case 1:
		//sample adc
		buf.buffer[buf.head++] = ADC_in();

	break;

	case 2:
		//mix buffer
		avg = ADC_in();
		avg >>= 1;
		avg += buf.buffer[buf.head] >> 1;
		buf.buffer[buf.head]= avg;
		buf.head++;

	break;

	case 3:
		//playback
		DAC_out( buf.buffer[buf.head++] );

	break;

	default:
	break;

	}

	if (buf.head >= BUFFER_SIZE)
	{
		buf.head = 0;
		state = 0;
		StopCpuTimer1();
	}

	//GpioDataRegs.GPADAT.all = (GpioDataRegs.GPADAT.all & 0x00) | SWITCH_read();

	CpuTimer1Regs.TCR.bit.TIF = 1;
}

int main()
{
	DisableDog();

	//75MHz
	InitPll(10,3);

	EALLOW;
	GpioCtrlRegs.GPAMUX1.bit.GPIO0 = 0;
	GpioCtrlRegs.GPADIR.bit.GPIO0 = 1;

	Init_McBSPb_ADC();
	Init_McBSPa_DAC();
	Init_SRAM();
	Init_LED();
	Init_SWITCH();

	Init_Timer1(150, 22);


	Uint16 MIXED = 0;
	Uint16 switches = 0;

	while(1)
	{
		switches = SWITCH_read() & 0x000F;

		if(switches == 1)
		{
			state = 1;
			StartCpuTimer1();
			while( state == 1 );    //wait until buffer is full
			GpioDataRegs.GPADAT.bit.GPIO0 = 1;
			MIXED = 0;

			while( (switches & 1) )   //as long as switch[0] = 1
			{
				switches = SWITCH_read() & 0x000F;

				if (switches == 3 && !MIXED)
				{
					GpioDataRegs.GPADAT.bit.GPIO0 = 0;
					state = 2;
					StartCpuTimer1();
					while( state == 2 ); //wait until buffer is fully mixed
					GpioDataRegs.GPADAT.bit.GPIO0 = 1;
					MIXED = 1;
				}

				if ( ( (switches & 8) >> 3) ) //if switch[3] = 1
				{
					GpioDataRegs.GPADAT.bit.GPIO0 = 0;
					state = 3;
					StartCpuTimer1();
					while( state == 3 );
				}
			}
		}

		if ( ( (switches & 8) >> 3) ) //if switch[3] = 1
			{
				GpioDataRegs.GPADAT.bit.GPIO0 = 0;
				state = 3;
				StartCpuTimer1();
				while( state == 3 );
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
