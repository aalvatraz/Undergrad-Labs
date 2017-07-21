# Undergrad-Labs
This repository holds code written for several labs of my undergraduate curriculum(EE)  .
Please bear with me on some of the code, it was a learning process.

Of these labs I am particularly proud of the following two:
   1) Digital Design Lab6 (MIPS CPU)
         -Implemented CPU capable of running subset of MIPS instruction set
         
         -Used Controller/Datapath VHDL architecture
         
         -Wrote Sorting and GCD program in Assembly capable of running on the CPU
   
   2) DSP Lab 6 (C callable assembly)
         -Wrote a C callable assembly function to multiply and accumulate FIR Filter taps by incoming audio samples (Filters.asm)
         
         -Took full advantage of circular addressing mode to optimize the calculation
         
         -Was able to calculate a 181 tap FIR BPF at ~300kHz on incoming audio data(41kHz sample rate)
             -the average rate among other students in the class was ~30kHz

# Controls (Spring 2016)
This folder contains a single C file demonstrating various controllers. 
controller.c implements a PID controller which was used to balance a ball on a beam. 
The p-i-d coefficients were calculated using Zeigler-Nichols method.

# Digital Design (Spring 2017)
In this class, we used VHDL to program the DE0 Altera(Now Intel FPGA) board.

   Lab1: Use GUI aid to create .bdf for a simple adder
  
   Lab1a: Create simple adder using VHDL
  
   Lab2: Implement a simple ALU
      -alu_ns: ALU using numeric_std library
      -alu_sla: ALU using std_logic_arith library
      -decoder7seg: Decoder for 7 segment LED display
      -top_level: Uses alu_sla and decoder_7seg to implement the ALU on the DE0 board, using the switches as input and LEDs as output
    
   Lab3: Create various adders in VHDL (Full-adder, Carry look-ahead adder, heirarchical CLA adder)
  
   Lab4: In this lab we learned to build sequential circuits in our VHDL (instead of all combinational) by creating counters.
  
   Lab5: We learned how to build controller/datapath architectures using VHDL. We then used the architecture to make a GCD calculator
  
   Lab6: Built a VGA controller which would load an image from memory and display the RGB image on a monitor
  
   Lab7: Built a MIPS architecture CPU capable of executing a subset of the MIPS instruction set

# Microprocessor Applications (Spring 2016)
This class is an introductory to microcontrollers and microprocessors architecture. These labs were run on a Atmel XMEGA128A1U.

   Lab1:Introduction to Assembly - Wrote simple program to filter out ASCII values in data memory
      
   Lab2: GPIO - Incorporated raster scan keypad as well as LEDs
  
   Lab3: External Interface - Connected Memory Mapped IO to microcontroller
  
   Lab4: Serial Interface & Interrupts - Created serial interface to connect to laptop via UART to USB (ftdi) using interrupts to trigger Rx and Tx events
  
   Lab5: C introduction - Recreated raster scan keypad code in C as well as incorporate 2 Line LCD screen to display captured ADC values using interrupts
  
   Lab6: Timers  - Used timer module to play notes on a piezo buzzer (LoZ Theme Song!)
   
   Lab7: DAC - Used timers along with DAC to generate various waveforms using a LUT
   
   Lab8: DMA - Used keypad to determine DAC output frequency for various waveforms. The DMA handled the memory transfer between the LUT and the DAC register.
  
# Real Time DSP Applications (Fall 2016)
Using a TI TMS320F28335 Delfino DSP (150 MHz) we learned about memory linking, FPU, hardware optimizated arithmetic, FIR/IIR filters, DFT/FFT, circular and ping/pong buffers. 

   Lab2: Assembly & I2C & GPIO - Bit Banged I2C in Assembly to interface with external 2 line LCD. Basic Read/Write of GPIO ports (LEDs/Switches)

   Lab3: FPU - Used FPU instruction set to sort floating point numbers. Implemented Bubble Sort in Assembly.

   Lab4: ADC, DAC, Interrupts, Timers & C - Used external SPI ADC & DAC via McBSP peripheral to get audio IO using timer interrupts

   Lab5: Audio Mixing, Interpolation, Decimation, Echo & Reverb Effect - Implemented using everything from Lab 3

   Lab6: FIR Filter - Apply LPF, HPF, and BPF on incoming audio data using C arithmetic vs Assembly optimization

   Lab7: IIR Filter - Apply LPF, HPF, BPF on incoming audio data using TI math libraries

   Lab8: DFT/FFT - Used DMA triggered ping/pong buffers to recieve audio data, and process DFT/FFT on block of data

   Lab9: Creative Project - Created audio effects "box" using raster scan keypad as input to select echo, reverb, wah-wah, pitch shift, ring modulation, and flanger effects.

