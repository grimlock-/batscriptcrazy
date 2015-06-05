@echo off
REM Grab the contents of every directory in the current one or in the directory specified
REM by argument one and move them up on directory
Setlocal EnableDelayedExpansion
if errorlevel 1 (
	echo Unable to enable Delayed variable expansion
	exit /B
)

set target=*

if not -%1-==-- set target=%1
for /D %%i in (!target!) do (
    move "%%i\..\*" "%%i\.."
)
exit /B