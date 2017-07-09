/*
 * Quiz.c
 *
 *  Created on: Oct 20, 2016
 *      Author: Adrian
 */


#include<DSP28x_Project.h>
#include<EEL4511.h>
#include "hammingWindow.h"

#define DELAY_MAX 1024

#pragma DATA_SECTION( audio , "Buffer")

void Init_Timers(void);

volatile circBuff_16 audio = { 0, 0, {0} };
volatile Uint16 delay1 = 0;
volatile Uint16 delay2 = 512;
volatile Uint16 switches = 0;
volatile Uint32 tail2 = 0;
volatile Uint16 effect = 0;

interrupt void capture(void)
{
	GpioDataRegs.GPADAT.bit.GPIO1 ^= 1;

	audio.buffer[audio.head] = ADC_in();

	if (audio.head > delay1)
			audio.tail = audio.head - delay1;
		else
			audio.tail = (BUFFER_SIZE - (delay1 - audio.head)) - 1;

	if (audio.head > delay2)
				tail2 = audio.head - delay2;
			else
				tail2 = (BUFFER_SIZE - (delay2 - audio.head)) - 1;

	effect = (Uint16) ( ( ( ( hamming[ delay1 ]) * (float) audio.buffer[audio.tail]) ) + ( hamming[ delay2 ])*( (float) audio.buffer[ tail2 ] ) );
	DAC_out( effect );

	audio.head++;

	if (audio.head >= BUFFER_SIZE)
	{
		audio.head = 0;
	}

	//reset interrupt flag
	CpuTimer1Regs.TCR.bit.TIF = 1;
}

interrupt void delay(void)
{
	GpioDataRegs.GPADAT.bit.GPIO0 ^= 1;

	if( delay1 >= DELAY_MAX )
	{
		delay1 = 0;
	}
	else delay1++;

	if( delay2 >= DELAY_MAX )
	{
		delay2 = 0;
	}
	else delay2++;

	//reset interrupt flag
	CpuTimer2Regs.TCR.bit.TIF = 1;
}


int main(void)
{
	DisableDog();

		//75MHz
		InitPll(10,3);

		Init_McBSPb_ADC();
		Init_McBSPa_DAC();
		Init_LED();
		Init_SRAM();

		Init_Timers();

		StartCpuTimer2();
		StartCpuTimer1();

		while(1){
		}
}





void Init_Timers(void)
{
	EALLOW;
	InitCpuTimers();

	ConfigCpuTimer( &CpuTimer2 , 150 , 200);
	ConfigCpuTimer( &CpuTimer1 , 150 , 23);

	PieVectTable.TINT2 = delay;
	PieVectTable.XINT13 = capture;

	PieCtrlRegs.PIECTRL.bit.ENPIE = 1;

	IER |= M_INT14;
	IER |= M_INT13;

	EINT;


}
