/*
 * Lab 4 Quiz
 *
 * 1. Create a floating point voltage buffer of size 128 in external sram using the linker and correct pragmas
 * 2. Read in values from the ADC at 200Hz
 * 3. Calculate range of the 32 most recent numbers
 * 4. Output that range to the lcd with 3 sigfigs
 */

#include <DSP28x_Project.h>
#include "adrian.h"

//define specific data location for floatbuff (see 28335_RAM_lnk.cmd)
#pragma DATA_SECTION( floatbuff , "FloatBuffer")

void Init_Timer1(void);
void Init_SRAM(void);
void store_val( float value);
float find_range(void);

volatile float floatbuff[128] = { 0 };
volatile Uint16 float_buffp = 0;
volatile float range;

interrupt void Quiz_ISR()
{
	float new = word2float( ADC_in() );

	//store new in data section
	//store_val( new );
	floatbuff[ float_buffp ] = new;
	range = find_range();
	LCD_home();
	LCD_float(range);
	if(float_buffp == 127){
		float_buffp = 0;
	}
	else{
		float_buffp++;
	}

	if ((float_buffp & 1))
		DAC_out(0xFFFF);
	else
		DAC_out(0x0000);

	CpuTimer1Regs.TCR.bit.TIF = 1;

}

int main(void)
{
	DisableDog();

	//75MHz
	InitPll(10,2);

	Init_McBSPb_ADC();
	Init_McBSPa_DAC();
	Init_LCD();
	Init_SRAM();
	Init_Timer1();

	while(1);
}

void Init_Timer1(void)
{
	EALLOW;
	InitCpuTimers();

	ConfigCpuTimer( &CpuTimer1 , 75 ,5);

	PieVectTable.XINT13 = Quiz_ISR;
	PieCtrlRegs.PIECTRL.bit.ENPIE = 1;

	IER |= M_INT13;

	EINT;

	StartCpuTimer(&CpuTimer1);
}

void Init_SRAM(void)
{
	EALLOW;
	GpioCtrlRegs.GPAMUX2.all |= 0xFC000000;
	GpioCtrlRegs.GPBMUX1.all |= 0xFFFFFCF0;
	GpioCtrlRegs.GPCMUX1.all |= 0xFFFFFFFF;
	GpioCtrlRegs.GPCMUX2.all |= 0xFFFF;
	SysCtrlRegs.PCLKCR3.bit.XINTFENCLK = 1;
}

void store_val(float value)
{
	floatbuff[ float_buffp ] = value;
}

float find_range(void)
{
	Uint32 temp_buffp = 0 ;
	float max_dat = -1.0;
	float min_dat = 5.0;

	//NO LOOP AROUND
	if( float_buffp >= 32 )
	{
		//GET HIGHEST VALUE
		for(temp_buffp = (float_buffp - 32) ; temp_buffp < 32 ; temp_buffp++)
		{
			if (floatbuff[temp_buffp] > max_dat)
			{
				max_dat = floatbuff[temp_buffp];
			}
		}

		//GET LOWEST VALUE
		for(temp_buffp = (float_buffp - 32) ; temp_buffp < 32 ; temp_buffp++)
			{
				if (floatbuff[temp_buffp] < min_dat)
				{
					min_dat = floatbuff[temp_buffp];
				}
			}
	}
	else  //LOOP AROUND
	{
		//GET HIGHEST VALUE
		for(temp_buffp = 127 - (32 - float_buffp); temp_buffp < 128 ; temp_buffp++)
			{
				if (floatbuff[temp_buffp] > max_dat)
				{
					max_dat = floatbuff[temp_buffp];
				}
			}

		for(temp_buffp = 0 ; temp_buffp < float_buffp ; temp_buffp++);
			{
				if (floatbuff[temp_buffp] > max_dat)
				{
					max_dat = floatbuff[temp_buffp];
				}
			}

		//GET LOWEST VALUE
		for(temp_buffp = 127 - (32 - float_buffp) ; temp_buffp < 128 ; temp_buffp++)
			{
				if (floatbuff[temp_buffp] < min_dat)
				{
					min_dat = floatbuff[temp_buffp];
				}
			}
		for(temp_buffp = 0 ; temp_buffp < float_buffp ; temp_buffp++)
			{
				if (floatbuff[temp_buffp] < min_dat)
				{
					min_dat = floatbuff[temp_buffp];
				}
			}
	}

	return (max_dat - min_dat);
}
