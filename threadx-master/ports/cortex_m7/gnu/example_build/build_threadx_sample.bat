set BIN_PATH="C:\Program Files (x86)\Atollic\TrueSTUDIO for STM32 9.3.0\ARMTools\bin"
set GCC=%BIN_PATH%\arm-atollic-eabi-gcc.exe

%GCC% -c -g -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16 -mthumb cortexm7_vectors.S
%GCC% -c -g -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16 -mthumb cortexm7_crt0.S
%GCC% -c -g -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16 -mthumb tx_initialize_low_level.S
%GCC% -g -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16 -mthumb -T sample_threadx.ld -ereset_handler -nostartfiles -o sample_threadx.out -Wl,-Map=sample_threadx.map cortexm7_vectors.o cortexm7_crt0.o tx_initialize_low_level.o tx.a
