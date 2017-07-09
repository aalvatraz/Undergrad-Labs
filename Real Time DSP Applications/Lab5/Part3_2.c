/*
 * Part3_2.c
 *
 *  Created on: Oct 20, 2016
 *      Author: Adrian
 *
 *  This file samples data into a buffer. It can then interpolate that data into another buffer as well as decimate it (2 different ways) into other buffers.
 *  It can also play the data out at various frequencies.
 */

#include<DSP28x_Project.h>
#include<EEL4511.h>


#define INTERPOL_MAX 262143
#define DATA_MAX 131072
#define DECIMATE1_MAX 65536
#define DECIMATE2_MAX 26213

#pragma DATA_SECTION( interpol , "Buffer")
#pragma DATA_SECTION( data , "Buffer2")
#pragma DATA_SECTION( decimate1 , "Buffer3")
#pragma DATA_SECTION( decimate2 , "Buffer4")

void Init_Timer1( int sysclk, unsigned int period);

volatile Uint16 data[131072] = {0} ;
volatile Uint16 interpol[262143] = {0} ;
volatile Uint16 decimate1[65536] = {0} ;
volatile Uint16 decimate2[26213] = {0} ;
volatile Uint16 state = 0;
volatile Uint32 data_p = 0;

interrupt void DAC_ISR()
{

	switch(state)
	{
	case 1:
		//record at 20k
		data[data_p++] = ADC_in();
		if(data_p >= DATA_MAX)
		{
			data_p = 0;
			state = 0;
			StopCpuTimer1();
		}
	break;

	case 2:
		//data 20k playback
		DAC_out( data[data_p++] );
		if(data_p >= DATA_MAX)
		{
			data_p = 0;
			state = 0;
			StopCpuTimer1();
		}
	break;

	case 3:
	case 4:
		//interpolate 40k play back
		DAC_out( interpol[data_p++] );
		if(data_p >= INTERPOL_MAX)
		{
			data_p = 0;
			state = 0;
			StopCpuTimer1();
		}
	break;

	case 5:
		//decimate
	break;

	case 6:
	case 7:
		//decimate1 20k playback
		DAC_out( decimate1[data_p++] );
		if(data_p >= DECIMATE1_MAX)
		{
			data_p = 0;
			state = 0;
			StopCpuTimer1();
		}
	break;

	case 8:
		//decimate2
	break;

	case 9:
	case 10:
		//decimate2 10k playback
		DAC_out( decimate2[data_p++] );
		if(data_p >= DECIMATE2_MAX)
		{
			data_p = 0;
			state = 0;
			StopCpuTimer1();
		}
	break;

	default: break;
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
	Uint16 avg = 0;

	while(1)
	{
		switches = SWITCH_read() & 0x000F;
		data_p = 0;

		switch(switches)
		{
		case 1:
			//record at 20k
			state = 1;
			ConfigCpuTimer(&CpuTimer1, 75, 50);
			StartCpuTimer1();
			while( state == 1 );
		break;

		case 3:
			//data playback at 20k
			state = 2;
			ConfigCpuTimer(&CpuTimer1, 75, 50);
			StartCpuTimer1();
			while( state == 2 );
		break;

		case 4:
			//interpolate
			for(data_p = 0; data_p < DATA_MAX ; data_p++)
			{
				interpol[2*data_p] = data[data_p];
				avg = (data[data_p] >> 1) + (data[data_p + 1] >> 1) ;
				interpol[(2*data_p) + 1] = avg;
			}
		break;

		case 5:
			//play interpol @ 20k
			state = 3;
			ConfigCpuTimer(&CpuTimer1, 75, 50);
			StartCpuTimer1();
			while( state == 3 );
		break;

		case 7:
			//play interpol @ 40k
			state = 4;
			ConfigCpuTimer(&CpuTimer1, 75, 25);
			StartCpuTimer1();
			while( state == 4 );
		break;

		case 8:
			//decimate 1
			for(data_p = 0; data_p < DECIMATE1_MAX ; data_p++)
			{
				decimate1[data_p] = data[2*data_p];
			}
		break;

		case 9:
			//play decimate1 @ 10kHz
			state = 6;
			ConfigCpuTimer(&CpuTimer1, 75, 100);
			StartCpuTimer1();
			while( state == 6 );
		break;

		case 11:
			//play decimate1@ 20kHz
			state = 7;
			ConfigCpuTimer(&CpuTimer1, 75, 50);
			StartCpuTimer1();
			while( state == 7 );
		break;

		case 12:
			//decimate2
			for(data_p = 0; data_p < DECIMATE2_MAX ; data_p++)
			{
				decimate2[data_p] = data[5*data_p];
			}
		break;

		case 13:
			//play decimate2@ 10kHz
			state = 9;
			ConfigCpuTimer(&CpuTimer1, 75, 100);
			StartCpuTimer1();
			while( state == 9 );
		break;

		case 15:
			//play decimate2@ 20kHz
			state = 10;
			ConfigCpuTimer(&CpuTimer1, 75, 50);
			StartCpuTimer1();
			while( state == 10 );
		break;

		default: break;
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

