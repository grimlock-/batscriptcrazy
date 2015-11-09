@echo off
REM This script takes a string as an argument and adds it to the name for
REM every file and directory in the current directory
setlocal EnableDelayedExpansion
if errorlevel 1 (
	echo Unable to enable delayed variable expansion
	exit /B
)
setlocal EnableExtensions
if errorlevel 1 (
	echo Unable to enable Command extensions
	exit /B
)
if not -%1-==-- goto :main

:printHelp
echo Add a string of text to each file in the current directory
echo.
echo fnadd [app] [options] text
echo.
echo   text
echo       What to add to each filename
echo.
echo   OPTIONS:
echo     -a, --append
echo         Append text to the end of each file instead of the beginning
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

:addToDir
REM TODO - everything

:appendToDir
REM TODO - everything

:addToFile
set a=%~1
if !_debug!==yes (
	echo Processing file: !a!
	echo Adding         : !_addme!
)
set "newFile=!_addme!!a!"

if !_debug!==yes (
	echo New filename   : !newFile!
) else if !_hold!==yes (
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

REM Get filename length and extension length
echo !a!>x & for %%i in (x) do (
	set /A count=%%~zi - 2 & del x
)
set /A count=!count!-1
echo !_ext!>x & for %%i in (x) do (
	set /A extcount=%%~zi - 2 & del x
)
set /A extcount=!extcount!-1
set /A fnlength=!count!-!extcount!

call set newFile=!a:~0,%fnlength%!
set "newFile=!newFile!!_addme!!_ext!"

if !_debug!==yes (
	echo New filename   : !newFile!
) else if !_hold!==yes (
	echo New filename   : !newFile!
) else (
	REM Add a check to make sure the file exists
	rename "!a!" "!newFile!"
)
echo.
goto :eof

:main
set a=
set _self=%~nx0
set _addme=
set _mode=beg
set _debug=no
set _hold=no
set _files=yes
set _directories=yes

:argloop
if %1==-a (
	set _mode=end
) else if %1==--append (
	set _mode=end
) else if %1==-d (
	set _debug=yes
) else if %1==--debug (
	set _debug=yes
) else if %1==-nf (
	set _files=no
) else if %1==-no-files (
	set _files=no
) else if %1==-nd (
	set _directories=no
) else if %1==--no-directories (
	set _directories=no
) else if %1==-h (
	set _hold=yes
) else if %1==--hold (
	set _hold=yes
) else if %1==--help (
	goto printHelp
) else (
	set _addme=%%~i
)
shift
if not -%1-==-- goto argloop

REM sanity check
if -!_addme!-==-- goto printHelp

if !_debug!==yes (
	if !_mode!==end (
		echo Add to     : End
	) else (
		echo Add to     : Beginning
	)
	if !_files!==no (
		echo Files      : NO
	) else (
		echo Files      : YES
	)
	if !_directories!==no (
		echo Directories: NO
	) else (
		echo Directories: NO
	)
	echo Text to Add: !_addme!
)

for %%i in (*) do (
	if not %%i==!_self! (
		set attributes=%%~ai
		set dir_attr=!attributes:~0,1!
		if /I "!dir_attr!"=="d" echo %%i is a directory
		
		set _ext=%%~xi
		if !_mode!==beg (
			call addToFile "%%i"
		) else if !_mode!==end (
			call appendToFile "%%i"
		)
	)
)
exit /B