################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
F2833x_Register_Defines.obj: ../F2833x_Register_Defines.asm $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C2000 Compiler'
	"C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/bin/cl2000" -v28 -ml -mt --float_support=fpu32 --opt_for_speed=3 --fp_mode=strict --include_path="C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_headers/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/EEL4511/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_common/include" -g --c99 --display_error_number --diag_warning=225 --diag_wrap=off --preproc_with_compile --preproc_dependency="F2833x_Register_Defines.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

Filters.obj: ../Filters.asm $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C2000 Compiler'
	"C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/bin/cl2000" -v28 -ml -mt --float_support=fpu32 --opt_for_speed=3 --fp_mode=strict --include_path="C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_headers/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/EEL4511/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_common/include" -g --c99 --display_error_number --diag_warning=225 --diag_wrap=off --preproc_with_compile --preproc_dependency="Filters.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

PART1_asm.obj: ../PART1_asm.c $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C2000 Compiler'
	"C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/bin/cl2000" -v28 -ml -mt --float_support=fpu32 --opt_for_speed=3 --fp_mode=strict --include_path="C:/ti/ccsv6/tools/compiler/c2000_15.12.3.LTS/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_headers/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/EEL4511/include" --include_path="C:/ti/controlSUITE/device_support/f2833x/v141/DSP2833x_common/include" -g --c99 --display_error_number --diag_warning=225 --diag_wrap=off --preproc_with_compile --preproc_dependency="PART1_asm.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '


