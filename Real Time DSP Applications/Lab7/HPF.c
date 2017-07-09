/*
 * HPF.c
 *
 *  Created on: Nov 10, 2016
 *      Author: Adrian
 */

#include<DSP28x_Project.h>
#include<EEL4511.h>
#include "iir.h"

//pragmas

//defines

//function prototypes
void Init_Timer1(void);

//global variables
volatile Uint16 state = 0;
long dbuffer[(IIR32_BPF_NBIQ << 1)];
int32 dbuffer_head = 0;
const long coeff[5*IIR32_BPF_NBIQ] = IIR32_BPF_COEFF;
IIR5BIQ32 HPF = IIR5BIQ32_DEFAULTS;

//ISR
interrupt void DAC_ISR()
{

    state = 1;

    GpioDataRegs.GPADAT.bit.GPIO0 ^= 1;
    CpuTimer1Regs.TCR.bit.TIF = 1;
}

//main
int main(void)
{
    DisableDog();

    InitPll(10, 3);

    Init_McBSPa_DAC();
    Init_McBSPb_ADC();
    Init_LED();

    Init_Timer1();

    //Initialize TI IIR16Filter
    HPF.dbuffer_ptr= dbuffer;
    HPF.coeff_ptr = (long *) coeff;
    HPF.qfmat = IIR32_BPF_QFMAT;
    HPF.nbiq = IIR32_BPF_NBIQ;
    HPF.isf = IIR32_BPF_ISF;
    HPF.init(&HPF);

    while(1)
    {

        if(state == 1)
        {

            HPF.input = (int32) ( (int32) ADC_in() - 0x7FFF );

            GpioDataRegs.GPATOGGLE.bit.GPIO1 = 1;

            HPF.calc(&HPF);

            DAC_out( (Uint16) (  ((float)HPF.output32) + 0x7FFF ) );

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

