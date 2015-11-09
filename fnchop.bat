@echo off
REM This Script removes the first X characters from every filename in the
REM the current directory where X is a user provided integer
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
if not -%1-==-- goto :main

:printHelp
echo Removes num characters from all filenames in the current directory
echo.
echo fnchop [options] num
echo.
echo   num
echo       Specifies how many characters to chop off
echo.
echo   OPTIONS
echo     -e, --end
echo         Removes characters from end of filename instead of beginning
echo     -nd, --no-directories (NOT YET IMPLEMENTED)
echo         Disable operation on directories
echo     -nf, --no-files (NOT YET IMPLEMENTED)
echo         Disable operation on files
echo     -h, --hold
echo         Don't rename anything, just print out the new filenames
echo     -d, --debug
echo         "hold" flag and some more verbose output
echo     --help
echo         Print this message
exit /B

:procDir
REM TODO - everything

:rprocDir
REM TODO - everything

:procFile
set a=%~1
if !_debug!==yes (
	echo file:         !a!
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
	echo new filename: !_newName!
) else if !_hold!==yes (
	echo new filename: !_newName!
) else (
	REM Add a check to make sure the file exists
	rename "!a!" "!_newName!"
)


echo.
goto :eof




:rprocFile
set a=%~1
if !_debug!==yes (
	echo file:         !a!
	echo extension:    !_ext!
)

REM Get filename length and extension length
echo !a!>x & for %%i in (x) do (
	set /A count=%%~zi - 2 & del x
)
set /A count=!count!-1
echo !_ext!>x & for %%i in (x) do (
	set /A extcount=%%~zi - 2 & del x
)
set /A extcount=!extcount!-1
set /A "_fnlength=!count!-!extcount!"

if !_qt! GEQ !_fnlength! (
	echo Cannot chop more characters than are present, skipping !a:~0,12!...
	goto :eof
)

REM Back offset -> offset to use to find the substring we want to chop off
set /A "back_ofst=%extcount%+%_qt%"
set /A "back_ofst=0-!back_ofst!"


call set "lose_this=!a:~%back_ofst%!"
call set "_newName=!a:%lose_this%=!"
call set "_newName=!_newName!!_ext!"


if !_debug!==yes (
	echo new filename: !_newName!
) else if !_hold!==yes (
	echo new filename: !_newName!
) else (
	REM Add a check to make sure the file exists
	rename "!a!" "!_newName!"
)

echo.

goto :eof




:main
set a=
set _self=%~nx0
set _mode=beg
set _qt=0
set _debug=no
set _hold=no
set _files=yes
set _directories=yes

:argloop
if %1==-e (
	set _mode=end
) else if %1==--end (
	set _mode=end
) else if %1==-h (
	set _hold=yes
) else if %1==--hold (
	set _hold=yes
) else if %1==-nf (
	set _files=no
) else if %1==-no-files (
	set _files=no
) else if %1==-nd (
	set _directories=no
) else if %1==--no-directories (
	set _directories=no
) else if %1==--d (
	set _debug=yes
) else if %1==--debug (
	set _debug=yes
) else if %1==--help (
	goto :printHelp
) else (
	set _qt=%1
)
shift
if not -%1-==-- goto argloop

REM Test to see if _qt is a number
REM If not, the error level will be set to 1
echo !_qt!| findstr /r "^[1-9][0-9]*$">nul
if errorlevel 1 (
	echo Please make the last argument a number
	exit /B
)

if !_debug!==yes (
	if !_mode!==end (
		echo Remove from: End
	) else (
		echo Remove from: Beginning
	)
	if !_hold!==yes (
		echo Hold flag  : YES
	) else (
		echo Hold flag  : NO
	)
	echo Quantity   : !_qt!
)

for %%i in (*) do (
	if not %%i==!_self! (
		set attributes=%%~ai
		set dir_attr=!attributes:~0,1!
		if /I "!dir_attr!"=="d" echo %%i is a directory
	
		set _ext=%%~xi
		if !_mode!==beg (
			call procFile "%%i"
		) else (
			call rprocFile "%%i"
		)
	)
)
exit /B