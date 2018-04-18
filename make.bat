@echo off

REM * Batch makefile for silverware
REM * Place in the project root folder (next to Silverware), make sure you also have keil_v5 tools there.
REM * Usage: ./make.bat
REM * More info:
REM *    http://www.keil.com/support/man/docs/armcc/armcc_chr1359124898004.htm
REM *    http://www.keil.com/support/man/docs/armlink/armlink_pge1362075395210.htm
REM *    http://www.keil.com/support/man/docs/armasm/armasm_dom1361289815333.htm
REM * Created by Phobos

SET OBJDIR=.\silverware\objects
SET KEILDIR=.\armcc\bin

SET SRC=.\silverware\src .\Utilities .\Libraries\STM32F0xx_StdPeriph_Driver\src
SET INC=-I .\silverware\src -I .\Libraries\CMSIS\Device\ST\STM32F0xx\Include -I .\Libraries\CMSIS\Include -I .\Utilities -I .\Libraries\STM32F0xx_StdPeriph_Driver\inc
SET STARTUP=.\Libraries\CMSIS\Device\ST\STM32F0xx\Source\Templates\arm\startup_stm32f031.s

SET CPU=--cpu Cortex-M0
SET OPT=-c %CPU% -D__EVAL -D__MICROLIB -g -O2 --apcs=interwork --split_sections -D__UVISION_VERSION="524" -DUSE_STDPERIPH_DRIVER -DSTM32F031 --fpmode=fast
SET LST=%CPU% --pd "__EVAL SETA 1" -g --apcs=interwork --pd "__MICROLIB SETA 1" --pd "__UVISION_VERSION SETA 524" --xref
SET LINK=%CPU% --library_type=microlib --ro-base 0x08000000 --entry 0x08000000 --rw-base 0x20000000 --entry Reset_Handler --first __Vectors --strict --info summarysizes

SET ARMCC5_ASMOPT=--diag_suppress=9931
SET ARMCC5_CCOPT=--diag_suppress=9931
SET ARMCC5_LINKOPT=--diag_suppress=9931
SET CPU_TYPE=STM32F030F4
SET CPU_VENDOR=STMicroelectronics
SET UV2_TARGET=BWhoop
SET CPU_CLOCK=0x00B71B00
SET ARM_TOOL_VARIANT=mdk_lite
SET ARM_PRODUCT_PATH=%KEILDIR%\..\sw\mappings

if not exist %OBJDIR% mkdir %OBJDIR%

for %%i in (%SRC%) do (
  for /f "usebackq TOKENS=*" %%j in (`dir /b %%i\*.c 2^>nul`) do %KEILDIR%\armcc --c99 %OPT% %INC% -o %OBJDIR%\%%~nj.o %%i\%%~nxj
  for /f "usebackq TOKENS=*" %%k in (`dir /b %%i\*.cpp 2^>nul`) do %KEILDIR%\armcc --cpp %OPT% %INC% -o %OBJDIR%\%%~nk.o %%i\%%~nxk
)
%KEILDIR%\armasm %LST% -o %OBJDIR%\startup_stm32f031.o %STARTUP%

setlocal ENABLEDELAYEDEXPANSION
set objList=
for /f "usebackq TOKENS=*" %%a in (`dir /b %OBJDIR%\*.o 2^>nul`) do set objList=!objList! %OBJDIR%\%%a

%KEILDIR%\armlink %LINK% %objList% -o %OBJDIR%\%UV2_TARGET%.axf
%KEILDIR%\fromelf %OBJDIR%\%UV2_TARGET%.axf --i32combined --output .\%UV2_TARGET%.hex

rmdir /s /q %OBJDIR%