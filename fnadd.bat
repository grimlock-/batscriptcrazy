@echo off
REM This script takes a string as an argument and adds it to the filename for
REM each file and directory in the current directory
if not -%1-==-- goto :main

:printHelp
echo Add a string of text to each file in the current directory
echo.
echo fnadd [app] [options] text
echo.
echo   [app]    Append provided text to the end of each file instead of the
echo            beginning
echo.
echo   OPTIONS:
echo     -d          Don't rename anything, just print out the new filenames
REM echo     -nd         Disable operation on directories
REM echo     -nf         Disable operation on files
exit /B

:addToFile
set a=%~1
if !_debug!==yes (
	echo Processing file: !a!
	echo Adding         : !_addme!
)
echo !a!>x & for %%i in (x) do (
	set /A count=%%~zi - 2 & del x
)
set /A count=!count!-1
set /A fnlength=!count!-4

set "newFile=!_addme!!a!"

if !_debug!==yes (
	echo New filename   : !newFile!
) else (
	REM Add a check to make sure the file exists
	rename "!a!" "!newFile!"
)
echo.
goto :eof

:appendToFile
set a=%~1
if !_debug!==yes (
	echo Processing file: !a!
	echo Appending      : !_addme!
)
set "ext=!a:~-4,4!"
echo !a!>x & for %%i in (x) do (
	set /A count=%%~zi - 2 & del x
)
set /A count=!count!-1
set /A fnlength=!count!-4

call set newFile=!a:~0,%fnlength%!
set "newFile=!newFile!!_addme!!ext!"

if !_debug!==yes (
	echo New filename   : !newFile!
) else (
	REM Add a check to make sure the file exists
	rename "!a!" "!newFile!"
)
echo.
goto :eof

:main
setlocal enabledelayedexpansion
if errorlevel 1 (
	echo Unable to enable delayed variable expansion
	exit /B
)

set a=
set _addme=
set _mode=beg
set _debug=no
set _files=yes
set _directories=yes

for %%i in (%*) do (
	if %%i==app (
		set _mode=end
	) else if %%i==-d (
		set _debug=yes
	) else if %%i==-nf (
		set _files=no
	) else if %%i==-nd (
		set _directories=no
	) else if not %%i==%0 (
		set _addme=%%~i
	)
)

if -!_addme!-==-- goto :printHelp

for %%i in (*) do (
	if not %%i==%0 (
		if !_mode!==beg (
			call :addToFile "%%i"
		) else if !_mode!==end (
			call :appendToFile "%%i"
		)
	)
)
exit /B