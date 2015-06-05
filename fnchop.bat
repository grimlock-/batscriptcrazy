@echo off
REM This Script removes the first X characters from every filename in the
REM the current directory where X is a user provided integer

if not -%1-==-- (
	goto :main
)

:outHelp
echo Removes X characters from all filenames in the current directory
echo.
echo fnchop [end] [debug] number
echo.
echo   [end]    Removes characters from end of filename instead of beginning
echo   [debug]  Don't rename anything, just print out the new filenames
echo   number   Specifies how many characters to chop off
exit /B


:procFile
set a=%~1
if(!_debug!==yes) (
	echo !a!
)

echo !a!>x & for %%i in (x) do (
	set /A count=%%~zi - 2 & del x
)
set /A count=!count!-1
set /A _fnlength=!count!-4
REM echo count is !count!
REM call echo %count%

if !_qt! GEQ !_fnlength! (
	echo Cannot chop more characters than are present, skipping !a:~0,12!...
	goto :eof
)

call set "_newName=!a:~%_qt%!"
if !_debug!==yes (
	echo !_newName!
) else (
	REM Add a check to make sure the file exists
	rename "!a!" "!_newName!"
)


echo.
goto :eof




:rprocFile
set a=%~1
if(!_debug!==yes) (
	echo !a!
)

echo !a!>x & for %%i in (x) do (
	set /A count=%%~zi - 2 & del x
)
set /A count=!count!-1
set /A _fnlength=!count!-4

if !_qt! GEQ !_fnlength! (
	echo Cannot chop more characters than are present, skipping !a:~0,12!...
	goto :eof
)

set "_ext=!a:~-4,4!"
REM Back offset -> offset to use to find the substring we want to chop off
set /A "back_ofst=4+%_qt%"
set /A "back_ofst=0-!back_ofst!"


call set "lose_this=!a:~%back_ofst%!"
call set "_newName=!a:%lose_this%=!"
call set "_newName=!_newName!!_ext!"


if !_debug!==yes (
	echo new filename: !_newName!
) else (
	REM Add a check to make sure the file exists
	rename "!a!" "!_newName!"
)

echo.

goto :eof




:main
setlocal EnableDelayedExpansion
if errorlevel 1 (
	echo Unable to enable Delayed variable expansion
	exit /B
)
setlocal EnableExtensions
if errorlevel 1 (
	echo Unable to enable Command extensions
	exit /B
)

set _mode=beg
set _qt=0
set _debug=no
set a=

for %%i in (%*) do (
	if %%i==end (
		set _mode=end
	) else if %%i==help (
		goto :outHelp
	) else if %%i==debug (
		set _debug=yes
	) else (
		set _qt=%%i
	)
)

REM Test to see if _qt is a number
REM If not, the error level will be set to 1
echo !_qt!| findstr /r "^[1-9][0-9]*$">nul

if errorlevel 1 (
	echo Please make the last argument a number
	exit /B
)

if(!_debug!==yes) (
	echo Mode set to !_mode!
	echo Quantity = !_qt!
)

for %%i in (*) do (
	REM Process every file that isn't this batch file
	if not %%i==%~nx0 (
		if !_mode!==beg (
			call :procFile "%%i"
		) else (
			call :rprocFile "%%i"
		)
	)
)
exit /B