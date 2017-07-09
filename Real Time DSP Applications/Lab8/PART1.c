/*
 * main.c
 */
//includes
#include<DSP28x_Project.h>
#include<EEL4511.h>
#include<math.h>
#include<stdio.h>
#include "fpu_rfft.h"

//defines
#define RFFT_STAGES     8
#define RFFT_SIZE       (1 << RFFT_STAGES)

#define F_PER_SAMPLE        45454.5L/(float)RFFT_SIZE  //Internal sampling rate is 45.4kHz


//pragmas
#pragma DATA_SECTION( audio , "DMARAML4" );
#pragma DATA_SECTION(rfft,"DMARAML5");
#pragma DATA_SECTION(RFFTmagBuff,"DMARAML5");
#pragma DATA_SECTION(RFFToutBuff,"DMARAML6");
#pragma DATA_SECTION(RFFTF32Coef,"DMARAML6");

//function prototypes
void Init_Timer1(void);

//global variables
volatile Uint16 program_state = 0;
volatile float audio[BUFFER_SIZE] = {0};
volatile Uint32 audio_head = 0;

RFFT_F32_STRUCT rfft;

float RFFToutBuff[RFFT_SIZE];                   //Calculated FFT result
float RFFTF32Coef[RFFT_SIZE];                   //Coefficient table buffer
float RFFTmagBuff[RFFT_SIZE/2+1];               //Magnitude of frequency spectrum

interrupt void DAC_ISR(void)
{

    audio[audio_head++] = ( (float) ADC_in() - 0x7FFF) ;

      if( audio_head >= BUFFER_SIZE )
    {
        audio_head = 0;
        program_state = 1;
        StopCpuTimer1();
    }

}

int main(void) {

    DisableDog();
    InitPll(10, 3);

    //Init_SRAM();
    Init_LCD();
    Init_LED();
    Init_McBSPb_ADC();
    Init_McBSPa_DAC();

    Init_Timer1();

    uint16_t i,j;
    float freq;

    audio[0] = 0;

    rfft.FFTSize   = RFFT_SIZE;              //Real FFT size
    rfft.FFTStages = RFFT_STAGES;           //Real FFT stages
    rfft.InBuf     = (float*)&audio[0];       //Input buffer
    rfft.OutBuf    = &RFFToutBuff[0];          //Output buffer
    rfft.MagBuf    = &RFFTmagBuff[0];          //Magnitude output buffer
    rfft.CosSinBuf = &RFFTF32Coef[0];       //Twiddle factor


    RFFT_f32_sincostable(&rfft);            //Calculate twiddle factor

   //Clean up output buffer
   for (i=0; i < RFFT_SIZE; i++)
   {
        RFFToutBuff[i] = 0;
   }

   //Clean up magnitude buffer
   for (i=0; i < RFFT_SIZE/2 + 1; i++)
   {
        RFFTmagBuff[i] = 0;
   }
	
	while(1){

	    switch(program_state)
	    {
            case 0:

                StartCpuTimer1();
                while(!program_state);  //wait until buffer full

            break;

            case 1:

                GpioDataRegs.GPADAT.bit.GPIO0 = 1;

                RFFT_f32u(&rfft);                 //calculate rfft
                RFFT_f32_mag(&rfft);                 //calculate rfft

                j = 1;
                freq = RFFTmagBuff[1];

                for(i=2;i<RFFT_SIZE/2;i++)
                {
                    //Looking for the maximum value of spectrum magnitude
                    if(RFFTmagBuff[i] > freq)
                    {
                        j = i;
                        freq = RFFTmagBuff[i];
                    }
                }

                freq =  F_PER_SAMPLE * (float)j; //Convert normalized digital frequency to analog frequency
                GpioDataRegs.GPADAT.bit.GPIO0 = 0;

                program_state = 2;

            break;

            case 2:

                LCD_clear();
                char max_freq[10] = {0};
                char* hz = "Hz";

                sprintf(max_freq, "%u", (Uint16) freq);

                LCD_string(max_freq);
                LCD_string(hz);

                program_state = 0;

            break;

            default: break;
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

   // StartCpuTimer1();
}
