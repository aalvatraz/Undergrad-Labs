/*
 *  PART2.c
 *
 *  Created on: Nov 11, 2016
 *      Author: Adrian
 *
 *      This file uses block processing with DMA
 *      to achieve sound in sound out
 *
 */

//includes
#include<DSP28x_Project.h>
#include<EEL4511.h>
#include<math.h>

//defines

//pragmas
#pragma DATA_SECTION( ping_1  , "DMARAML4" )
#pragma DATA_SECTION( pong_1  , "DMARAML4" )
#pragma DATA_SECTION( ping_2  , "DMARAML5" )
#pragma DATA_SECTION( pong_2  , "DMARAML5" )
#pragma DATA_SECTION( garbage , "DMARAML5" )

//function prototypes
void Init_Timer1(void);
void Init_DMA(void);

//global variables
volatile Uint32 ping_1[BUFFER_SIZE] = {0};
volatile Uint32 pong_1[BUFFER_SIZE] = {0};
volatile Uint16 ping_2[BUFFER_SIZE] = {0};
volatile Uint16 pong_2[BUFFER_SIZE] = {0};
volatile Uint32 garbage= 0x0BADFADE;
volatile Uint16 program_state = 0;
volatile Uint16 ready = 0;
volatile Uint16 count = 0;

interrupt void Timer1_ISR(void)
{
    EALLOW;
    GpioDataRegs.GPADAT.bit.GPIO0 ^= 1;

}

interrupt void MRB_ISR (void)
{
    EALLOW;
    GpioDataRegs.GPADAT.bit.GPIO2 ^= 1;
    PieCtrlRegs.PIEACK.all = PIEACK_GROUP6;
}

interrupt void DMA_CH3 (void)
{
    EALLOW;
    PieCtrlRegs.PIEACK.all = PIEACK_GROUP7;
}

interrupt void DMA_CH2(void)
{
    while(ready)
    {

        if(program_state == 0)
        {
            DMACH2AddrConfig( (volatile Uint16*) &ping_1[0] + 1 , (volatile Uint16*) &McbspbRegs.DRR2.all );
            DMACH3AddrConfig( (volatile Uint16*) &McbspaRegs.DXR1 , (volatile Uint16*) &ping_2[0] );
        }
        else if(program_state == 1)
        {
            DMACH2AddrConfig( (volatile Uint16*) &pong_1[0] + 1 , (volatile Uint16*) &McbspbRegs.DRR2.all );
            DMACH3AddrConfig( (volatile Uint16*) &McbspaRegs.DXR1 , (volatile Uint16*) &pong_2[0] );
        }

        program_state ^= 1;

        EALLOW;
        GpioDataRegs.GPADAT.bit.GPIO1 ^= 1;
        PieCtrlRegs.PIEACK.all = PIEACK_GROUP7;
        ready = 0;

    }

}

int main(void)
{
    DisableDog();

    InitPll(10,3);

    Init_McBSPa_DAC();
    Init_McBSPb_ADC();
    Init_LED();

    Init_DMA();

    Init_Timer1();

    while(1)
    {
        while(!ready)
        {
            GpioDataRegs.GPADAT.bit.GPIO3 ^= 1;

            if(program_state == 0)
            {

                for(int i = 0; i < BUFFER_SIZE; i++)
                {
                    ping_2[i] = (Uint16) ((ping_1[i] >> 2) & 0xFFFF);
                }

            }
            else if(program_state == 1)
            {

                for(int i = 0; i < BUFFER_SIZE; i++)
                {
                   pong_2[i] = (Uint16) ((pong_1[i] >> 2) & 0xFFFF);
                }

            }

           ready = 1;
           GpioDataRegs.GPADAT.bit.GPIO3 ^= 1;
        }



    }

}

void Init_Timer1(void)
{
    EALLOW;
    InitCpuTimers();

    ConfigCpuTimer( &CpuTimer1 , 150 , 22);

    PieVectTable.XINT13 = Timer1_ISR;
    PieCtrlRegs.PIECTRL.bit.ENPIE = 1;

    IER |= M_INT13;

    EINT;

    StartCpuTimer1();
}


void Init_DMA(void)
{
    EALLOW;

    SysCtrlRegs.HISPCP.all = 0;                 //Hi-Speed Clk = SYSCLK
    SysCtrlRegs.PCLKCR3.bit.DMAENCLK = 1;       // DMA Clock

    DMAInitialize();

    //setup DMA1 (triggered on Timer1 overflow)
    DMACH1AddrConfig( (volatile Uint16*) &McbspbRegs.DXR2 , (volatile Uint16*) &garbage + 1 );
    DMACH1BurstConfig( 1, -1, 1 ); //send 2 words per burst, decrement source addr, increment dest addr by 1 (32 bits little endian)
    DMACH1TransferConfig( 0, 0, 0 );
    DMACH1WrapConfig( 0, 0, 0, 0 );
    DMACH1ModeConfig( DMA_TINT1, 1, 0, 1, 0, 0, 0, 0, 0, 0 );

    //setup DMA2 (triggered on McBSPB RRDY flag)
    DMACH2AddrConfig( (volatile Uint16*) &pong_1[0] + 1 , (volatile Uint16*) &McbspbRegs.DRR2);
    DMACH2BurstConfig( 1, 1, -1 ); //send 2 words per burst, increment source addr, decrement dest addr by 1 (32 bits little endian)
    DMACH2TransferConfig( BUFFER_SIZE - 1, 0, 3 );  //get N = BUFFER_SIZE ADC values, wrap to same McBSP vals, increment Dest by 3
    DMACH2WrapConfig( 0, 0, BUFFER_SIZE - 1, 0 );
    DMACH2ModeConfig(DMA_MREVTB, 1, 0, 1, 0, 0, 0, 0, 1, 1 );

    //setup DMA3 (triggered on Timer1 overflow)
    DMACH3AddrConfig( (volatile Uint16*) &McbspaRegs.DXR1, (volatile Uint16*) &pong_2[0] );
    DMACH3BurstConfig( 0, 0, 0 );
    DMACH3TransferConfig( BUFFER_SIZE - 1, 1, 0 );
    DMACH3WrapConfig( 0xFFFF, 0, 0, 0 );
    DMACH3ModeConfig( DMA_TINT1, 1, 0, 1, 0, 0, 0, 0, 1, 1 );


    EALLOW;
    PieCtrlRegs.PIEIER7.bit.INTx1 = 1; //enable McBSPB RRDY int
    PieCtrlRegs.PIEIER7.bit.INTx2 = 1; //enable DMACH2 int
    PieCtrlRegs.PIEIER7.bit.INTx3 = 1; //enable DMACH2 int
    PieCtrlRegs.PIEIER6.bit.INTx3 = 1; //enable McBSPB RRDY int
    PieCtrlRegs.PIEIFR6.bit.INTx3 = 1;

    PieVectTable.MRINTB = MRB_ISR;
    PieVectTable.DINTCH2 = DMA_CH2;
    PieVectTable.DINTCH3 = DMA_CH3;

    IER |= M_INT6;   //enable McBSPB RRDY interrupt
    IER |= M_INT7;  //enable "buffer full" interrupt DMACH2

    StartDMACH1();
    StartDMACH2();
    StartDMACH3();
}

