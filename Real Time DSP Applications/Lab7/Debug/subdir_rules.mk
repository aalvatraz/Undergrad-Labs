################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
F2833x_Register_Defines.obj: ../F2833x_Register_Defines.asm $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C2000 Compiler'
	"C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/bin/cl2000" -v28 -ml -mt --float_support=fpu32 --include_path="C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_headers/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_common/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/EEL4511/include" -g --c99 --display_error_number --diag_warning=225 --diag_wrap=off --preproc_with_compile --preproc_dependency="F2833x_Register_Defines.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

Filters.obj: ../Filters.asm $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C2000 Compiler'
	"C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/bin/cl2000" -v28 -ml -mt --float_support=fpu32 --include_path="C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_headers/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_common/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/EEL4511/include" -g --c99 --display_error_number --diag_warning=225 --diag_wrap=off --preproc_with_compile --preproc_dependency="Filters.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

TI_IIRasm.obj: ../TI_IIRasm.c $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C2000 Compiler'
	"C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/bin/cl2000" -v28 -ml -mt --float_support=fpu32 --include_path="C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_headers/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_common/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/EEL4511/include" -g --c99 --display_error_number --diag_warning=225 --diag_wrap=off --preproc_with_compile --preproc_dependency="TI_IIRasm.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

iir5biq16.obj: ../iir5biq16.asm $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C2000 Compiler'
	"C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/bin/cl2000" -v28 -ml -mt --float_support=fpu32 --include_path="C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_headers/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_common/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/EEL4511/include" -g --c99 --display_error_number --diag_warning=225 --diag_wrap=off --preproc_with_compile --preproc_dependency="iir5biq16.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

iir5biq32.obj: ../iir5biq32.asm $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C2000 Compiler'
	"C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/bin/cl2000" -v28 -ml -mt --float_support=fpu32 --include_path="C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_headers/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_common/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/EEL4511/include" -g --c99 --display_error_number --diag_warning=225 --diag_wrap=off --preproc_with_compile --preproc_dependency="iir5biq32.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '


