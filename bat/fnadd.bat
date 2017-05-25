@echo off
REM This script takes a string as an argument and adds it to the name of
REM every file or directory in the current directory
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
echo Add a string of text to the name of each file in the current directory
echo.
echo fnadd [options] text
echo.
echo   text
echo       What to add to each filename
echo.
echo   OPTIONS:
echo     -a, --append
echo         Append text to the end of each file instead of the beginning
echo     -d, --directories
echo         Operate on directories in addition to files
echo     -D, --directories-only
echo         Operate on directories instead of files
echo     -h, --hold
echo         Don't rename anything, just print out the new filenames
echo     --debug
echo         "hold" flag and some more verbose output
echo     --help
echo         Print this message
exit /B

:addToDir
	set a=%~1
	if !_debug!==yes (
		echo Directory name: !a!
		echo Adding        : !addme!
	)
	set "newFolder=!addme!!a!"

	if !_debug!==yes (
		echo New name      : !newFolder!
		echo.
	) else if !_hold!==yes (
		echo Old directory name: !a!
		echo New directory name: !newFolder!
		echo.
	) else (
		rename "!a!" "!newFolder!"
	)
goto :eof

:appendToDir
	set a=%~1
	if !_debug!==yes (
		echo Directory name: !a!
		echo Adding        : !addme!
	)
	set "newFolder=!a!!addme!"

	if !_debug!==yes (
		echo New name      : !newFolder!
		echo.
	) else if !_hold!==yes (
		echo Old directory name: !a!
		echo New directory name: !newFolder!
		echo.
	) else (
		rename "!a!" "!newFolder!"
	)
goto :eof

:addToFile
	set a=%~1
	if !_debug!==yes (
		echo Processing file: !a!
		echo Adding         : !addme!
	)
	set "newFile=!addme!!a!"

	if !_debug!==yes (
		echo New filename   : !newFile!
		echo.
	) else if !_hold!==yes (
		echo Old filename: !a!
		echo New filename: !newFile!
		echo.
	) else (
		rename "!a!" "!newFile!"
	)
goto :eof

:appendToFile
	set a=%~1
	if !_debug!==yes (
		echo Processing file: !a!
		echo Appending      : !addme!
	)
	set newFile=%~n1!addme!%~x1

	if !_debug!==yes (
		echo New filename   : !newFile!
		echo.
	) else if !_hold!==yes (
		echo Old filename: !a!
		echo New filename: !newFile!
		echo.
	) else (
		rename "!a!" "!newFile!"
	)
goto :eof

:main
set _me=%~nx0
set addme=
set _mode=beg
set _debug=no
set _hold=no
set _files=yes
set _directories=no

:argloop
if %1==-a (
	set _mode=end
) else if %1==--append (
	set _mode=end
) else if %1==-d (
	set _directories=yes
) else if %1==--directories (
	set _directories=yes
) else if %1==-D (
	set _directories=yes
	set _files=no
) else if %1==--directories-only (
	set _directories=yes
	set _files=no
) else if %1==-h (
	set _hold=yes
) else if %1==--hold (
	set _hold=yes
) else if %1==--debug (
	set _debug=yes
) else if %1==--help (
	goto printHelp
) else (
	set addme=%~1
)
shift
if not -%1-==-- goto argloop

REM sanity check
if -!addme!-==-- goto printHelp

REM Print options
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
		echo Directories: YES
	)
	echo Text to Add: !addme!
	echo.
)

if !_files!==yes (
	for %%i in (*) do (
		if not %%i==!_me! (
			if !_mode!==beg (
				call :addToFile "%%i"
			) else if !_mode!==end (
				call :appendToFile "%%i"
			)
		)
	)
)
if !_directories!==yes (
	for /D %%i in (*) do (
		if !_mode!==beg (
			call :addToDir "%%i"
		) else (
			call :appendToDir "%%i"
		)
	)
)
exit /B