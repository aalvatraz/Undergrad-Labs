/*
 * main.c
 *
 * This is a C-implementation of an 2-stage second order IIR Low Pass Filter
 *
 */

#include<DSP28x_Project.h>
#include<EEL4511.h>
#include "Filters.h"

//pragmas

//defines

//function prototypes
void Init_Timer1(void);

//global variables
volatile Uint16 state = 0;

LPF_IIRcoeff LPF_SOS1 = {0.002612,
                        0.005223,
                        0.002612,
                        -1.894508,
                        0.909282};

LPF_IIRcoeff LPF_SOS2 = {0.004908,
                        0.009817,
                        0.004908,
                        -1.780306,
                        0.794189};

LPF_IIRbuff LPFbuff1 = {0,0,0,0,0};

LPF_IIRbuff LPFbuff2 = {0,0,0,0,0};

//ISR
interrupt void DAC_ISR()
{

	state = 1;

	GpioDataRegs.GPADAT.bit.GPIO0 ^= 1;
	CpuTimer1Regs.TCR.bit.TIF = 1;
}



int main(void)
{
	DisableDog();

	InitPll(10, 3);

	Init_McBSPa_DAC();
	Init_McBSPb_ADC();
	Init_LED();

	Init_Timer1();

	volatile float y1 = 0;
	volatile float y2 = 0;

	while(1)
	{

		if(state == 1)
		{
		    //read ADC
			LPFbuff1.x0 = (float) ( (int32) ADC_in() - 0x7FFF );

			GpioDataRegs.GPATOGGLE.bit.GPIO1 = 1;

			//calculate SOS1
			y1  = (LPFbuff1.x0 * LPF_SOS1.b0);
			y1 += (LPFbuff1.x1 * LPF_SOS1.b1);
			y1 += (LPFbuff1.x2 * LPF_SOS1.b2);
			y1 -= (LPFbuff1.y1 * LPF_SOS1.a1);
			y1 -= (LPFbuff1.y2 * LPF_SOS1.a2);

			//shift values
			LPFbuff1.x2 = LPFbuff1.x1;
			LPFbuff1.x1 = LPFbuff1.x0;
			LPFbuff1.y2 = LPFbuff1.y1;
			LPFbuff1.y1 = y1;

			//feed SOS1 output to SOS2 input
			LPFbuff2.x0 = y1;

			//calculate SOS2
			y2  = (LPFbuff2.x0 * LPF_SOS2.b0);
			y2 += (LPFbuff2.x1 * LPF_SOS2.b1);
			y2 += (LPFbuff2.x2 * LPF_SOS2.b2);
			y2 -= (LPFbuff2.y1 * LPF_SOS2.a1);
			y2 -= (LPFbuff2.y2 * LPF_SOS2.a2);

			//shift values
			LPFbuff2.x2 = LPFbuff2.x1;
			LPFbuff2.x1 = LPFbuff2.x0;
			LPFbuff2.y2 = LPFbuff2.y1;
			LPFbuff2.y1 = y2;

			DAC_out( (Uint16) ( y2 + 0x7FFF ) );

			GpioDataRegs.GPATOGGLE.bit.GPIO1 = 1;
			state = 0;
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
