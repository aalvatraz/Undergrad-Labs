/*
 * Filters.h
 *
 *  Created on: Oct 29, 2016
 *      Author: Adrian
 */

#ifndef FILTERS_H_
#define FILTERS_H_

extern Uint16 FIRFilter( volatile float* data, volatile float* taps, Uint16 taps_size);
extern Uint16 FIRFilter2( volatile float* data, Uint16 data_size, volatile float* taps, Uint16 taps_size);

#endif /* FILTERS_H_ */
