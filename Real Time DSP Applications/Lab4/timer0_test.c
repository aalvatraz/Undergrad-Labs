


#include<DSP28x_Project.h>
#include<EEL4511.h>


void Init_Timer2(void);
void Init_Timer1(void);
void Init_Timers(void);

interrupt void Timer1_ISR()
{
	GpioDataRegs.GPADAT.bit.GPIO0 ^= 1;
	CpuTimer1Regs.TCR.bit.TIF = 1;
}

interrupt void Timer2_ISR()
{
	GpioDataRegs.GPADAT.bit.GPIO1 ^= 1;
	CpuTimer2Regs.TCR.bit.TIF = 1;
}


int main(void) {

	DisableDog();

	//75MHz
	InitPll(10,2);

	//Init_McBSPb_ADC();
	//Init_McBSPa_DAC();
	//Init_LCD();
	Init_LED();

	//Init_Timer1();
	//Init_Timer2();
	Init_Timers();

	EINT;

	StartCpuTimer2();
	StartCpuTimer1();

while(1){

	}
}

void Init_Timers(void)
{
	EALLOW;
	InitCpuTimers();

	ConfigCpuTimer( &CpuTimer2 , 75 , 200);
	ConfigCpuTimer( &CpuTimer1 , 75 , 22);



	SysCtrlRegs.PCLKCR3.bit.CPUTIMER2ENCLK |= 1;
	PieVectTable.TINT2 = Timer2_ISR;

	PieVectTable.XINT13 = Timer1_ISR;
	SysCtrlRegs.PCLKCR3.bit.CPUTIMER1ENCLK |= 1;
	PieCtrlRegs.PIECTRL.bit.ENPIE = 1;


	IER |= M_INT14;
IER |= M_INT13;
	EINT;


}

void Init_Timer2(void)
{
	EALLOW;
	//InitCpuTimers();





	IER |= M_INT14;

	EINT;

	//StartCpuTimer2();

}

