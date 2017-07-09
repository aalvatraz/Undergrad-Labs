/*
 * Filters.h
 *
 *  Created on: Oct 29, 2016
 *      Author: Adrian
 */

#ifndef FILTERS_H_
#define FILTERS_H_

typedef struct {

    float b0;
    float b1;
    float b2;
    float a1;
    float a2;

}LPF_IIRcoeff;

typedef struct {

    float x0;
    float x1;
    float x2;
    float y1;
    float y2;

}LPF_IIRbuff;

extern Uint16 FIRFilter( volatile float* data, volatile float* taps, Uint16 taps_size);
extern Uint16 FIRFilter2( volatile float* data, Uint16 data_size, volatile float* taps, Uint16 taps_size);

//extern float IIR_MAC(LPF_IIRcoeff* coeff, LPF_IIRbuff* buff);
//extern float IIR_MAC(float* coeff, float* buff);



#endif /* FILTERS_H_ */
