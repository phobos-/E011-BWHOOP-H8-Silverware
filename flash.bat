@echo off

REM * Batch flashing tool for silverware
REM * Place in the project root folder (next to Silverware), make sure you also have openocd there.
REM * Usage: ./flash.bat [firmware.bin/elf/hex] - by default using bwhoop.hex
REM * Created by Phobos

set DIR=.\openocd-0.10.0\bin-x64

set PROGRAMMER=interface/stlink-v2.cfg
set TARGET=target/stm32f0x.cfg

if "%1"=="" (
  set FILE=bwhoop.hex
  set EXT=.hex
) else (
  set FILE=%1
  set EXT=%~x1
)

IF "%EXT%"==".bin" (
  %DIR%\openocd -f %PROGRAMMER% -f %TARGET% -c "program %FILE% 0x08000000 verify reset; shutdown"
) ELSE IF "%EXT%"==".elf" (
  %DIR%\openocd -f %PROGRAMMER% -f %TARGET% -c "program %FILE% verify reset; shutdown"
) ELSE IF "%EXT%"==".hex" (
  %DIR%\openocd -f %PROGRAMMER% -f %TARGET% -c "program %FILE% verify reset; shutdown"
) ELSE (
  echo File with this extension cannot be flashed - %FILE%
)