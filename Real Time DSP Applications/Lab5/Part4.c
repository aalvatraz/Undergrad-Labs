/*
 * Part4.c
 *
 * This file adds variable reverb or echo to a real time signal being input to the DSP via the ADC.
 */
#include <DSP28x_Project.h>
#include <EEL4511.h>

#pragma DATA_SECTION( audio , "Buffer")

#define ECHO_GAIN 0.5
#define REV_GAIN 0.25
#define Fs 44100.0
#define Ts_us 22

void Init_Timer1(void);

volatile Uint16 state = 0;
volatile circBuff_16 audio = { 0, 0, {0} };
volatile Uint32 offset = 0;
volatile Uint16 effect = 0;
volatile Uint16 switches = 0;

interrupt void DAC_ISR()
{
	switches = ( SWITCH_read() & 0x000F );

	if( !(switches & 8) )
	{
		state = 1;
		offset = (Uint32) ((0.01 * Fs)*((float) (switches & 7)) + (.01 * Fs));
	}
	else if ( (switches & 8) )
	{
		state = 2;
		offset = (Uint32) ((0.25 * Fs)*((float) (switches & 7)) + (0.25 * Fs));
	}

	switch(state)
	{

	//reverb
	case 1:
		audio.buffer[audio.head] = ADC_in();
		audio.tail = find_tail(audio.head, offset);
		effect = (Uint16) ( ( ( (1.0 - REV_GAIN) * (float) audio.buffer[ audio.head ]) ) + (REV_GAIN)*( (float) audio.buffer[ audio.tail ] ) );
		DAC_out( effect );
		audio.head++;
	break;

	//echo
	case 2:
		effect = ADC_in();
		audio.tail = find_tail(audio.head, offset);
		audio.buffer[audio.head] = (Uint16) ( ( (1.0 - ECHO_GAIN)*( (float) effect) ) + (ECHO_GAIN)*( (float) audio.buffer[ audio.tail ] ) );
		DAC_out( audio.buffer[audio.head] );
		audio.head++;
	break;

	default:
	break;
	}

	if (audio.head >= BUFFER_SIZE)
		{
			audio.head = 0;
		}

	CpuTimer1Regs.TCR.bit.TIF = 1;
}


int main(void) {

	DisableDog();

	//75MHz
	InitPll(10,2);

	Init_McBSPb_ADC();
	Init_McBSPa_DAC();
	Init_SWITCH();
	Init_SRAM();

	Init_Timer1();



	while(1)
	{
		/*
		switches = ( SWITCH_read() & 0x000F );

		if( !(switches & 8) )
		{
			state = 1;
			offset = (Uint32) ((0.01 * Fs)*((float) (switches & 7)) + (.01 * Fs));
		}
		else if ( (switches & 8) )
		{
			state = 2;
			offset = (Uint32) ((0.25 * Fs)*((float) (switches & 7)) + (0.25 * Fs));
		}
*/
	}

}

void Init_Timer1(void)
{
	EALLOW;
	InitCpuTimers();

	ConfigCpuTimer( &CpuTimer1 , 75 , Ts_us);

	PieVectTable.XINT13 = DAC_ISR;
	PieCtrlRegs.PIECTRL.bit.ENPIE = 1;

	IER |= M_INT13;

	EINT;

	StartCpuTimer1();

}
