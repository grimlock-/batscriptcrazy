@echo off
REM Extract the contents of every zip file in the current directory into
REM seperate directories

REM 7z.exe must be accessible from the "Path" environment variable

setlocal EnableDelayedExpansion
if errorlevel 1 (
	echo Unable to enable Delayed variable expansion
	exit /B
)

set debug=no
set destination=%~dp0
set single_dir=no
set _slash=\

if -%1-==-- goto loopend

:argloop
if %1==--debug (
	set debug=yes
) else if %1==-d (
	set debug=yes
) else if %1==--single-directory (
	set single_dir=yes
) else if %1==-sd (
	set single_dir=yes
) else if %1==--output-directory (
	set destination=%~2
	shift
) else if %1==-od (
	set destination=%~2
	shift
) else if %1==-h (
	goto printHelp
) else if %1==--help (
	goto printHelp
)
shift
if not -%1-==-- goto argloop

REM Add trailing slash if necessary
if not !destination:~-1!==\ (
	if not !destination:~-1!==/ (
		set destination=!destination!\
	)
)

REM Situation: execute "xzips.bat -sd"
REM A new directory should be created to hold the contents of all the archives
REM since extracting everything to the current directory might clutter it up.
REM An "extract all here" can be done with "xzips.bat -sd -od ."
if !single_dir!==yes (
	if "!destination!" == "%~dp0" (
		set destination=!destination!archives\
	)
)

:loopend
for %%i in (*) do (
	if %%~xi==.zip (
		if !single_dir!==no (
			set tmp_dst=!destination!%%~ni
			if !debug!==yes (
				echo 7z.exe x -r -o"!tmp_dst!" %%i
			) else (
				call 7z.exe x -r -o"!tmp_dst!" %%i
			)
		) else (
			if !debug!==yes (
				echo 7z.exe x -r -o"!destination!" %%i
			) else (
				call 7z.exe x -r -o"!destination!" %%i
			)
		)
	)
)
exit /B

:printHelp
echo Extracts the contents of every zip file in the current directory
echo.
echo xzips [options]
echo.
echo   -d, --debug
echo       Don't extract any archives, print the command to the console instead
echo   -sd, --single-directory
echo       Extract all archives to the same directory
echo   -od dir (--output-directory)
echo       Directory to output the archive contents to
echo   -h, --help
echo       Print this message
echo.
echo If no options are specified, the contents of each zip file will be stored
echo in their own new directory named after the archive.
echo The -sd option will consolidate the contents of all archives into just the
echo output directory (current directory if not specified). If -sd is the only
echo option specified a new directory will be created to hold the archives'
echo contents.
echo "xzips -sd -od ." can be used to store everything in the current directory