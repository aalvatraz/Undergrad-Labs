/*
 * Quiz7.c
 *
 *  Created on: Nov 10, 2016
 *      Author: Adrian
 */

#include<DSP28x_Project.h>
#include<EEL4511.h>
#include<math.h>

//defines

//function prototypes
void Init_Timers(void);

//global variables
volatile Uint16 state = 0;
volatile float F = 0;
volatile float Q = 0.8;
volatile Uint16 program_state = 0;
volatile Uint16 F_state = 0;
volatile Uint16 F_i = 100;
volatile float x0 = 0;
volatile float y0 = 0;
volatile float Yl_0 = 0;      //lowpass outputs
volatile float Yl_1 = 0;
volatile float Yh_0 = 0;      //highpass outputs
volatile float Yb_0 = 0;      //bandpass outputs
volatile float Yb_1 = 0;

//interrupts
interrupt void frequency(void)
{
   if (!F_state)
       F = 2*sinf( ( 3.14 * F_i++ ) / 45454 );
   else
       F = 2*sinf( ( 3.14 * F_i-- ) / 45454 );

   if(F_i == 3000)
       F_state = 1;
   else if (F_i == 100)
       F_state = 0;

   //toggle Gpio
   GpioDataRegs.GPADAT.bit.GPIO1 ^= 1;
}


interrupt void wah(void)
{
    program_state = 1;
    //toggle Gpio
    GpioDataRegs.GPADAT.bit.GPIO0 ^= 1;
}

int main(void)
{
    DisableDog();

    InitPll(10, 3);

    Init_McBSPa_DAC();
    Init_McBSPb_ADC();
    Init_LED();

    Init_Timers();

    while(1)
    {
        if(program_state == 1)
        {
            x0 = ( (float) ADC_in() ) - 0x7FFF;

            GpioDataRegs.GPADAT.bit.GPIO2 ^= 1;

            //state control IIR calculation
            Yh_0 = x0 - Yl_1 - ( Q * Yb_1 );
            Yb_0 = ( F * Yh_0 ) + Yb_1;
            Yl_0 = ( F * Yb_0 ) + Yl_1;

            //move values
            Yl_1 = Yl_0;
            Yb_1 = Yb_0;


            y0 = (0.5 * x0) + (0.5 * Yb_0);

            DAC_out( (Uint16) (y0 + 0x7FFF ) );

            GpioDataRegs.GPADAT.bit.GPIO2 ^= 1;

            program_state = 0;

        }
    }

}




void Init_Timers(void)
{
    EALLOW;
    InitCpuTimers();

    ConfigCpuTimer( &CpuTimer2 , 150 , 90);  //5800 values in 1 second
    ConfigCpuTimer( &CpuTimer1 , 150 , 22);   //45454Hz sampling frequency

    PieVectTable.TINT2 = frequency;
    PieVectTable.XINT13 = wah;

    PieCtrlRegs.PIECTRL.bit.ENPIE = 1;

    IER |= M_INT14;
    IER |= M_INT13;

    EINT;

    StartCpuTimer1();
    StartCpuTimer2();


}
