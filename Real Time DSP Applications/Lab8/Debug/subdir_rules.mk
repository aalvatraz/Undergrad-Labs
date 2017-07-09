################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
PART3.obj: ../PART3.c $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C2000 Compiler'
	"C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/bin/cl2000" -v28 -ml -mt --float_support=fpu32 --include_path="C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/include" --include_path="C:/ti/controlSUITE/libs/dsp/FPU/v1_40_00_00/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/EEL4511/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_headers/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_common/include" -g --c99 --display_error_number --diag_warning=225 --diag_wrap=off --preproc_with_compile --preproc_dependency="PART3.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '


