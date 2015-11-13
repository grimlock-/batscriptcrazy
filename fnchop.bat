@echo off
REM This script removes the first X characters from every filename in the
REM the current directory where X is a user provided number
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

:procDir
	set a=%~1
	if !_debug!==yes (
		echo Directory  : !a!
	)
	
	REM Get filename and extension length
	echo !a!>x & for %%i in (x) do (
		set /A count=%%~zi - 2 & del x
	)
	set /A count=!count!-1
	
	if !_debug!==yes (
		echo Name length: !count!
	)
	
	if !qt! GEQ !count! (
		echo Cannot chop all characters or more than are present, skipping !a:~0,7!...
		echo.
		goto :eof
	)
	
	call set "newName=!a:~%qt%!"
	if !_debug!==yes (
		echo New name   : !newName!
		echo.
	) else if !_hold!==yes (
		echo Directory: !a!
		echo New name : !newName!
		echo.
	) else (
		rename "!a!" "!newName!"
	)
goto :eof

:rprocDir
	set a=%~1
	if !_debug!==yes (
		echo Directory  : !a!
	)
	
	REM Get filename and extension length
	echo !a!>x & for %%i in (x) do (
		set /A count=%%~zi - 2 & del x
	)
	set /A count=!count!-1
	
	if !_debug!==yes (
		echo Name length: !count!
	)
	
	if !qt! GEQ !count! (
		echo Cannot chop all characters or more than are present, skipping !a:~0,7!...
		echo.
		goto :eof
	)
	
	set /A "back_ofst=0-!qt!"
	call set "lose_this=!a:~%back_ofst%!"
	call set "newName=!a:%lose_this%=!"
	
	if !_debug!==yes (
		echo Removing   : !lose_this!
		echo New name   : !newName!
		echo.
	) else if !_hold!==yes (
		echo Directory: !a!
		echo New name : !newName!
		echo.
	) else (
		rename "!a!" "!newName!"
	)
goto :eof

:procFile
	set a=%~1
	if !_debug!==yes (
		echo File        : !a!
	)
	
	REM Get filename and extension length
	echo !a!>x & for %%i in (x) do (
		set /A count=%%~zi - 2 & del x
	)
	set /A count=!count!-1
	echo !ext!>x & for %%i in (x) do (
		set /A extcount=%%~zi - 2 & del x
	)
	set /A extcount=!extcount!-1
	set /A "fnlength=!count!-!extcount!"
	
	if !_debug!==yes (
		echo Name length : !fnlength!
	)

	if !qt! GEQ !fnlength! (
		echo Cannot chop all characters or more than are present, skipping !a:~0,7!...
		echo.
		goto :eof
	)

	call set "newName=!a:~%qt%!"
	if !_debug!==yes (
		echo new filename: !newName!
		echo.
	) else if !_hold!==yes (
		echo old filename: !a!
		echo new filename: !newName!
		echo.
	) else (
		rename "!a!" "!newName!"
	)
goto :eof

:rprocFile
	set a=%~1
	if !_debug!==yes (
		echo File        : !a!
	)

	REM Get filename length and extension length
	echo !a!>x & for %%i in (x) do (
		set /A count=%%~zi - 2 & del x
	)
	set /A count=!count!-1
	echo !ext!>x & for %%i in (x) do (
		set /A extcount=%%~zi - 2 & del x
	)
	set /A extcount=!extcount!-1
	set /A "fnlength=!count!-!extcount!"
	
	if !_debug!==yes (
		echo Name length : !fnlength!
	)

	if !qt! GEQ !fnlength! (
		echo Cannot chop all characters or more than are present, skipping !a:~0,7!...
		echo.
		goto :eof
	)

	REM Back offset -> offset to use to find the substring we want to chop off
	set /A "back_ofst=%extcount%+%qt%"
	set /A "back_ofst=0-!back_ofst!"


	call set "lose_this=!a:~%back_ofst%!"
	call set "newName=!a:%lose_this%=!"
	call set "newName=!newName!!ext!"


	if !_debug!==yes (
		echo Removing    : !lose_this!
		echo new filename: !newName!
		echo.
	) else if !_hold!==yes (
		echo old filename: !a!
		echo new filename: !newName!
		echo.
	) else (
		rename "!a!" "!newName!"
	)
goto :eof

:main
set _me=%~nx0
set _mode=beg
set qt=0
set _debug=no
set _hold=no
set _files=yes
set _directories=no

:argloop
if %1==-e (
	set _mode=end
) else if %1==--end (
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
	set qt=%1
)
shift
if not -%1-==-- goto argloop

REM sanity checks
if -!qt!-==-- goto printHelp
REM Test to see if qt is a number
REM If not, the error level will be set to 1
echo !qt!| findstr /r "^[1-9][0-9]*$">nul
if errorlevel 1 (
	echo Please make the last argument a number
	exit /B
)

if !_debug!==yes (
	if !_mode!==end (
		echo Remove from       : End
	) else (
		echo Remove from       : Beginning
	)
	if !_files!==yes (
		echo Rename files      : YES
	) else (
		echo Rename files      : NO
	)
	if !_directories!==yes (
		echo Rename directories: YES
	) else (
		echo Rename directories: NO
	)
	if !_hold!==yes (
		echo Hold flag         : YES
	) else (
		echo Hold flag         : NO
	)
	echo Quantity          : !qt!
	echo.
)

if !_files!==yes (
	for %%i in (*) do (
		if not %%i==!_me! (
			set ext=%%~xi
			if !_mode!==beg (
				call :procFile "%%i"
			) else (
				call :rprocFile "%%i"
			)
		)
	)
)
if !_directories!==yes (
	for /D %%i in (*) do (
		if !_mode!==beg (
			call :procDir "%%i"
		) else (
			call :rprocDir "%%i"
		)
	)
)
exit /B