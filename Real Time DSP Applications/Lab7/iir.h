// TI File $Revision: /main/2 $
// Checkin $Date: Thu Jan  6 15:14:02 2011 $
// =====================================================================================
//  This software is licensed for use with Texas Instruments C28x
//  family DSCs.  This license was provided to you prior to installing
//  the software.  You may review this license by consulting a copy of
//  the agreement in the doc directory of this library.
// -------------------------------------------------------------------------------------
//          Copyright (C) 2010-2011 Texas Instruments, Incorporated.
//                          All Rights Reserved.
//======================================================================================
/*===================================================================
File name   :   IIR.H                   
                    
Originator  :   YU CAI (ASP)
                Texas Instruments
Description:  
Header file containing  object definitions, proto type declaration and 
default object initializers for FFT modules.
===================================================================
History:
-------------------------------------------------------------------
20-3-2000   Release Rev 1.0                                                  
--------------------------------------------------------------------*/
//######################################################################################
// $TI Release: C28x Fixed Point Library v1.01 $
// $Release Date: January 11,2011 $
//######################################################################################

#ifndef __IIR_H__
#define __IIR_H__
#define     NULL    0

 
/*----------------------------------------------------------------
Define the structure of the IIR5BIQ16 Filter Module 
-----------------------------------------------------------------*/
typedef struct { 
    void (*init)(void *);   /* Ptr to Init funtion           */
    void (*calc)(void *);   /* Ptr to calc fn                */  
    int *coeff_ptr;         /* Pointer to Filter coefficient */
    int *dbuffer_ptr;       /* Delay buffer ptr              */
    int nbiq;               /* No of biquad                  */
    int input;              /* Latest Input sample           */
    int isf;                /* Input Scale Factor            */ 
    int qfmat;              /* Q format of coeff             */
    int output;             /* Filter Output                 */
    }IIR5BIQ16;    


/*---------------------------------------------------------------
Define the structure of the IIR5BIQ32 Filter Module
-----------------------------------------------------------------*/
typedef struct {
    void (*init)(void *);   /* Ptr to init fn                */
    void (*calc)(void *);   /* Ptr to calc fn                */ 
    long *coeff_ptr;        /* Pointer to Filter coefficient */
    long *dbuffer_ptr;      /* Delay buffer ptr              */
    long nbiq;               /* No of biquad                  */
    long input;              /* Latest Input sample           */
    long isf;               /* Input Scale Factor            */ 
    long output32;          /* Filter Output (Q30)           */
    int output16;           /* Filter Output (Q14)           */
    int qfmat;              /* Q format of coeff             */
    }IIR5BIQ32;            
 
/*---------------------------------------------------------------
Define a Handles for the Filter Modules
-----------------------------------------------------------------*/
typedef IIR5BIQ16     *IIR5BIQ16_handle;
typedef IIR5BIQ32     *IIR5BIQ32_handle;    
        
          
#define IIR5BIQ16_DEFAULTS { (void (*)(void *))IIR5BIQ16_init,\
             (void (*)(void *))IIR5BIQ16_calc,\
             (int *)NULL,   \
             (int *)NULL,   \
             0,             \
             0,             \
             0,             \
             0,             \
             0}    

#define IIR5BIQ32_DEFAULTS { (void (*)(void *))IIR5BIQ32_init,\
             (void (*)(void *))IIR5BIQ32_calc, \
             (long *)NULL,   \
             (long *)NULL,   \
             0,             \
             0,             \
             0,             \
             0,             \
             0,             \
             0}                           


/*-------------------------------------------------------------
 Prototypes for the functions
---------------------------------------------------------------*/
void IIR5BIQ16_calc(void *);
void IIR5BIQ32_calc(void *);

/******** Sample IIR co-efficients ****************************/
 
void IIR5BIQ16_init(IIR5BIQ16 *);
void IIR5BIQ32_init(IIR5BIQ32 *);

/* LPF co-efficients for IIR16 module	*/
// these coefficients are good
#define IIR16_COEFF {\
            -6406,14469,7,13,7,\
            -7402,15456,10654,21308,10654}

#define IIR16_ISF   129
#define IIR16_NBIQ  2
#define IIR16_QFMAT 13


/* LPF co-efficients for IIR32 module	*/
#define IIR32_COEFF {\
            -419792166,948232560,433246,866491,433246,\
            -485066396,1012931567,698212694,1396425388,698212694}

#define IIR32_ISF   8421739
#define IIR32_NBIQ  2
#define IIR32_QFMAT 29
 
#endif 

/* BPF co-efficients for IIR32 module   */
#define IIR32_BPF_COEFF {\
            -516258,1032994,198,395,198,\
            -517414,1030439,762,1523,762,\
            -517933,1037505,1690,3380,1690,\
            -520628,1041745,948021,-1896042,948021,\
            -521580,1031786,39325,-78650,39325,\
            -523131,1044870,580435549,-1160871097,580435549}

#define IIR32_BPF_ISF   774
#define IIR32_BPF_NBIQ  6
#define IIR32_BPF_QFMAT 19


