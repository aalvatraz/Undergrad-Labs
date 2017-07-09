/*
 * main.c
 */

#include<DSP28x_Project.h>
#include<EEL4511.h>
#include<math.h>
#include "hammingWindow.h"

#define Fs 45454
#define DELAY_MAX 1024
#define Echo_Delay 50000
#define Rev_Delay 40


#pragma DATA_SECTION( audio , "SRAM")

volatile circBuff_16 audio = {0, 0, {0}};
volatile Uint16 key = '0';
volatile Uint16 effect = 0;
volatile Uint16 Fla_delay[128] = {135,130,125,120,116,111,106,102,97,93,89,84,
                                80,77,73,69,66,63,60,57,54,52,50,48,46,44,
                                43,42,41,40,40,40,40,40,41,42,43,44,46,48,
                                50,52,54,57,60,63,66,69,73,77,80,84,89,93,
                                97,102,106,111,116,120,125,130,135,140,135,
                                130,125,120,116,111,106,102,97,93,89,84,80,
                                77,73,69,66,63,60,57,54,52,50,48,46,44,43,
                                42,41,40,40,40,40,40,41,42,43,44,46,48,50,
                                52,54,57,60,63,66,69,73,77,80,84,89,93,97,
                                102,106,111,116,120,125,130,135,140};
volatile Uint32 Fla_i = 0;
volatile Uint32 Fla_state = 0;
volatile Uint32 F_state = 0;
volatile float x0 = 0;
volatile float y0 = 0;
volatile float Yl_0 = 0;      //lowpass outputs
volatile float Yl_1 = 0;
volatile float Yh_0 = 0;      //highpass outputs
volatile float Yb_0 = 0;      //bandpass outputs
volatile float Yb_1 = 0;
volatile Uint16 F_i = 100;
volatile float F = 0;
volatile float Q = 0.8;

void Init_Timers(void);

interrupt void capture(void)
{
    audio.buffer[audio.head] = ADC_in();

    GpioDataRegs.GPADAT.bit.GPIO0 = 1;
    switch(key)
    {
    case '0':
        DAC_out( (Uint16) audio.buffer[audio.head] );
    break;

    case '1': //echo
        audio.buffer[audio.head] = (Uint16) ( ( (0.6)*( (float) audio.buffer[audio.head]) ) + (0.4)*( (float) audio.buffer[ (audio.head - Echo_Delay) & (BUFFER_SIZE-1) ] ) );
        DAC_out(audio.buffer[audio.head]);
    break;

    case '2': //reverb
        effect = (Uint16) ( ( ( (0.6) * (float) audio.buffer[ audio.head ] ) ) + (0.4)*( (float) audio.buffer[ (audio.head - Rev_Delay) & (BUFFER_SIZE-1) ] ) );
        DAC_out(effect);
    break;

    case '3': //flang
        effect = ( ( ( (0.6) * (float) audio.buffer[ audio.head ] ) ) + (0.4)*( (float) audio.buffer[ (audio.head - Fla_delay[Fla_i]) & (BUFFER_SIZE-1) ] ) );
        DAC_out(effect);
    break;

    case '4': //wah-wah
        x0 = ( (float) audio.buffer[ audio.head ] ) - 0x7FFF;

       //state control IIR calculation
       Yh_0 = x0 - Yl_1 - ( Q * Yb_1 );
       Yb_0 = ( F * Yh_0 ) + Yb_1;
       Yl_0 = ( F * Yb_0 ) + Yl_1;

       //move values
       Yl_1 = Yl_0;
       Yb_1 = Yb_0;


       y0 = (0.5 * x0) + (0.5 * Yb_0);

       DAC_out( (Uint16) (y0 + 0x7FFF ) );
    break;

    case '5': //ring mod
        effect = ((float) audio.buffer[ audio.head ] - 0x7FFF)*(sinf(2*3.14*audio.head/(Fs/75))) ;
        DAC_out( (Uint16) (effect + 0x7FFF));
    break;
    default: break;
    }

    audio.head = ( ( audio.head + 1 ) & (BUFFER_SIZE - 1) );
    GpioDataRegs.GPADAT.bit.GPIO0 = 0;

}

interrupt void delay(void)
{
    //wah-wah
    if (!F_state)
        F = 2*sinf( ( 3.14 * F_i++ ) / 45454 );
    else
        F = 2*sinf( ( 3.14 * F_i-- ) / 45454 );

    if(F_i == 3000)
        F_state = 1;
    else if (F_i == 100)
        F_state = 0;


    //flanger
    if( !(F_i % 200) )
    {
//    if(Fla_state == 0)
//        Fla_delay++;
//    else if(Fla_state == 1)
//        Fla_delay--;
//
//    if(Fla_delay == 100)
//        Fla_state = 1;
//    else if(Fla_delay == 0)
//        Fla_state = 0;

        Fla_i = (Fla_i + 1) & 127;
    }

}

int main(void) {
	
    DisableDog();

    InitPll(10,3);

    Init_LCD();
    Init_LED();
    Init_McBSPa_DAC();
    Init_McBSPb_ADC();
    Init_SWITCH();
    keypad_init();
    Init_SRAM();

    char state = 0;

    Init_Timers();

    LCD_clear();
    LCD_string("None");

	while(1)
	{


	    while(state == 0)
	        state = getKey();

	    switch(state)
	    {
	        case '0': //none
              LCD_clear();
              LCD_string("None");
              key = state;
          break;

	       case '1': //echo
	           LCD_clear();
	           LCD_string("Echo");
	           key = state;
	       break;

	       case '2': //reverb
	           LCD_clear();
               LCD_string("Reverb");
               key = state;
	       break;

	       case '3': //flang
	           LCD_clear();
	           LCD_string("Flanger");
	           key = state;
	       break;

	       case '4': //wah-wah
	           LCD_clear();
	           LCD_string("Wah-Wah");
	           key = state;
	       break;

	       case '5': //ring modulation
              LCD_clear();
              LCD_string("Ring Mod");
              key = state;
          break;

	       default: break;
	    }
	    state = 0;
	}
}


void Init_Timers(void)
{
    EALLOW;
    InitCpuTimers();

    ConfigCpuTimer( &CpuTimer2 , 150 , 100);
    ConfigCpuTimer( &CpuTimer1 , 150 , 22);

    PieVectTable.TINT2 = delay;
    PieVectTable.XINT13 = capture;

    PieCtrlRegs.PIECTRL.bit.ENPIE = 1;

    IER |= M_INT14;
    IER |= M_INT13;

    StartCpuTimer1();
    StartCpuTimer2();

    EINT;

}
