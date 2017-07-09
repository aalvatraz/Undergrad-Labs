/*
 * TI_IIRasm.c
 *
 *  Created on: Nov 9, 2016
 *      Author: Adrian
 *
 *      This program uses the TI IIR filter implementation to calculate a Low Pass filter
 *      on data received from the ADC. The coefficients were determined using TI's eziir16.m
 *      script and are found in iir.h.
 *
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
int dbuffer[(IIR16_NBIQ << 1)];
const int coeff[5*IIR16_NBIQ] = IIR16_COEFF;
IIR5BIQ16 LPF = IIR5BIQ16_DEFAULTS;

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
    LPF.dbuffer_ptr= dbuffer;
    LPF.coeff_ptr = (int *) coeff;
    LPF.qfmat = IIR16_QFMAT;
    LPF.nbiq = IIR16_NBIQ;
    LPF.isf = IIR16_ISF;
    LPF.init(&LPF);

    while(1)
    {

        if(state == 1)
        {

            LPF.input = (int16) ( (int16) ADC_in() - 0x7FFF );

            GpioDataRegs.GPATOGGLE.bit.GPIO1 = 1;

            LPF.calc(&LPF);

            DAC_out( (Uint16) (  ((float)LPF.output*2) + 0x7FFF ) );

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
