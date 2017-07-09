# Undergrad-Labs
This repository holds code written for several labs of my undergraduate curriculum.

# Controls
This folder contains a single C file demonstrating various controllers. 
controller.c implements a PID controller which was used to balance a ball on a beam. 
The p-i-d coefficients were calculated using Zeigler-Nichols method.

# Digital Design
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

# Microprocessor Applications
This class is an introductory to microcontrollers and microprocessors architecture. These labs were run on a Atmel XMEGA128A1U.

   Lab1:Introduction to Assembly
      -Wrote simple program to filter out ASCII values in data memory
  
   Lab2:
  
   Lab3:
  
   Lab4:
  
   Lab5:
  
   Lab6:
  
# Real Time DSP Applications
Using a TI TMS320F28335 Delfino DSP (150 MHz), we learned about memory linking, FPU, hardware optimizated arithmetic, FIR/IIR filters, DFT/FFT, and ping/pong buffers. 
   Lab1:

   Lab2:

   Lab3:

   Lab4:

   Lab5:

   Lab6:

   Lab7:

   Lab8:

   Lab9:

