/*
 * controller.c
 *
 * Created: 11/15/2015 12:28:55 AM
 *  Author: OOTBIII
 */ 

#include "Controller.h"

#define ADJUSTMENT 0

#define pi 3.141592
#define Fs 50

//student position controller is written in this function
void PIDControllerLoop()
{
	pidVars.prev = pidVars.current;	//set previous value for next iteration
	pidVars.current = getCurrentEncCnt();  //set current encoder value from motor (position in ticks)
	pidVars.error = pidVars.des - pidVars.current;  //set current error value
	
	if (pidVars.error > deadZone - ADJUSTMENT || pidVars.error < -deadZone + ADJUSTMENT) {	//only add in integral term to sum if error is outside +/- threshold
		pidVars.integrand += (pidVars.errorPrev + pidVars.error)/(controllerFreq*2); //compute integral term using trapezoidal approximation, add to running total
	}
	else {
		pidVars.integrand = 0;
	}
	
		//compute derivative from slope of secant line
	pidVars.derivative = (pidVars.current - pidVars.prev)*controllerFreq; 
	
		//calculate gain value to apply from error, derivative, and integral
	int32_t value =	  pidVars.kp*pidVars.error
					- pidVars.kd*pidVars.derivative
					+ pidVars.ki*pidVars.integrand; 

	
	if(value <= -motorMaxEffort) {	//value is below lower-bound motor effort threshold
		pidVars.output = -motorMaxEffort+1;	//output max motor effort counterclockwise
		motorEffort(CCW, motorMaxEffort+1);
	}
	else if(value < 0) {	//value is above lower-bound motor effort threshold, and negative
		pidVars.output = -value; //output abs(value) counterclockwise
		motorEffort(CCW, pidVars.output);
	}
	else if (value < motorMaxEffort) { //value is positive, but below upper-bound motor effort threshold
		pidVars.output = value; //output value clockwise
		motorEffort(CW, pidVars.output);
	}
	else  {	//value is above max motor effort threshold
		pidVars.output = motorMaxEffort-1;	//output max motor effort clockwise
		motorEffort(CW, motorMaxEffort-1);
	}
	
	pidVars.errorPrev = pidVars.error; //set previous error for next iteration

	sendPID_message(pidVars.current,pidVars.des,pidVars.output); //send output to MatLab
}

//student rpm controller is written in this function
void IIRControllerLoop()
{
	iirVars.prev = iirVars.current;
	iirVars.current = getCurrentEncCnt();
	
	iirVars.gain = -1;	
	
	iirVars.error[2] = iirVars.error[1];
	iirVars.error[1] = iirVars.error[0];
	
	iirVars.output[2] = iirVars.output[1];
	iirVars.output[1] = iirVars.output[0];
			
	iirVars.sample[3] = iirVars.sample[2];
	iirVars.sample[2] = iirVars.sample[1];
	iirVars.sample[1] = iirVars.sample[0];
	iirVars.sample[0] = (iirVars.current - iirVars.prev)*Fs*60/1800;
	iirVars.sample[0] = (iirVars.sample[3] + iirVars.sample[2] + iirVars.sample[1] + iirVars.sample[0])/4;
	
	iirVars.error[0] = iirVars.des - iirVars.sample[0];
	
	/*
	//LAG CONTROLLER
	iirVars.output[0]   = (-1)*iirVars.output[2];
	iirVars.output[0]  += 2*iirVars.output[1];
	iirVars.output[0]  -= 14.4*iirVars.error[0];
	iirVars.output[0]  -= .0069*iirVars.error[1];
	iirVars.output[0]  += 14.4*iirVars.error[2];
	//*/
 
	//TUNED LAG CONTROLLER
	iirVars.output[0]   = (-1)*iirVars.output[2];
	iirVars.output[0]  += 2*iirVars.output[1];
	iirVars.output[0]  -= 3*iirVars.error[0];
	iirVars.output[0]  -= .007*iirVars.error[1];
	iirVars.output[0]  += 3*iirVars.error[2];
	//*/
	
	/*
	//LEAD CONTROLLER Fs = 50Hz
	iirVars.output[0]   = .6038*iirVars.output[2];
	iirVars.output[0]  += .3962*iirVars.output[1];
	iirVars.output[0]  += 2.4*iirVars.error[0];
	iirVars.output[0]  += 1.259*iirVars.error[1];
	iirVars.output[0]  -= 1.141*iirVars.error[2];
	//*/
	
	/*
	//LEAD CONTROLLER Fs = 100Hz
	iirVars.output[0]   = .9276*iirVars.output[2];
	iirVars.output[0]  += .07244*iirVars.output[1];
	iirVars.output[0]  += 1.602*iirVars.error[0];
	iirVars.output[0]  += .4834*iirVars.error[1];
	iirVars.output[0]  -= 1.118*iirVars.error[2];
	//*/
	
	/*
	//TUNED LEAD CONTROLLER Fs = 100Hz
	iirVars.output[0]   = .8116*iirVars.output[2];
	iirVars.output[0]  += .1884*iirVars.output[1];
	iirVars.output[0]  += 2.045*iirVars.error[0];
	iirVars.output[0]  += 0.6536*iirVars.error[1];
	iirVars.output[0]  -= 1.391*iirVars.error[2];
	//*/
	
	int16_t tempOutput = iirVars.output[0];
				   
	
	if(tempOutput <= -motorMaxEffort) {	//value is below lower-bound motor effort threshold
		tempOutput = -motorMaxEffort+1;	//output max motor effort counterclockwise
		motorEffort(CW, motorMaxEffort+1);
	}
	else if(tempOutput < 0) {	//value is above lower-bound motor effort threshold, and negative
		tempOutput = -tempOutput; //output abs(value) counterclockwise
		motorEffort(CW, tempOutput);
	}
	else if (tempOutput < motorMaxEffort) { //value is positive, but below upper-bound motor effort threshold
		tempOutput = tempOutput; //output value clockwise
		motorEffort(CCW, tempOutput);
	}
	else  {	//value is above max motor effort threshold
		tempOutput = motorMaxEffort-1;	//output max motor effort clockwise
		motorEffort(CCW, motorMaxEffort-1);
	}
	
	sendIIR_message(iirVars.sample[0], iirVars.des, tempOutput);
}

//This function should be created by students.  The purpose is for them to insert
//a method to change the desired position based off the gyro data.
void equateGyroDatatToPosition(int32_t gyroData) {
	changeDesPID(900-gyroValToPos(gyroData));
}




