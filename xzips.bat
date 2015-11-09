@echo off
REM Extract the contents of every zip file in the current directory into
REM seperate directories
setlocal EnableDelayedExpansion
if errorlevel 1 (
	echo Unable to enable Delayed variable expansion
	exit /B
)

set debug=no
set destination=%cd%
set single_dir=no

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
) else if %1==here (
	set single_dir=yes
	set destination=.
	goto loopend
) else if %1==-h (
	goto printHelp
) else if %1==--help (
	goto printHelp
)
shift
if not -%1-==-- goto argloop

:loopend
REM Add trailing slash if necessary
if not !destination:~-1!==\ (
	if not !destination:~-1!==/ (
		set destination=!destination!\
	)
)


REM "xzips.bat -sd"
REM In this situation a new directory should be created to hold the contents
REM of all the archives since extracting everything to the current directory
REM might clutter it up. All archives' contents can be extracted to the housing
REM directory with "xzips -sd -od ." or with the shorthand "xzips here"
if !single_dir!==yes (
	if "!destination!" == "%cd%\" (
		set destination=!destination!archives\
	)
)

for %%i in (*) do (
	set _procfile=no
	if %%~xi==.zip set _procfile=yes
	if %%~xi==.rar set _procfile=yes
	if %%~xi==.tar set _procfile=yes
	if %%~xi==.gz set _procfile=yes
	if %%~xi==.7z set _procfile=yes
	if !_procfile!==yes (
		if !single_dir!==no (
			set tmp_dst=!destination!%%~ni
			if !debug!==yes (
				echo 7z.exe x -r -o"!tmp_dst!" "%%i"
			) else (
				call 7z.exe x -r -o"!tmp_dst!" "%%i"
			)
		) else (
			if !debug!==yes (
				echo 7z.exe x -r -o"!destination!" "%%i"
			) else (
				call 7z.exe x -r -o"!destination!" "%%i"
			)
		)
	)
)
exit /B

:printHelp
echo Extracts the contents of every zip file in the current directory
echo.
echo xzips [options] [here]
echo.
echo   OPTIONS
echo   -d, --debug
echo       Don't extract any archives, print the command to the console instead
echo   -sd, --single-directory
echo       Extract all archives to the same directory
echo   -od dir (--output-directory)
echo       Directory to output the archive contents to
echo   here
echo       Shorthand for "-sd -od .", effectively extracting every archive's
echo       contents to the current directory
echo   -h, --help
echo       Print this message
echo.
echo If no options are specified, the contents of each zip file will be stored
echo in their own new directory named after the archive.
echo The -sd option will consolidate the contents of all archives into just the
echo output directory (current directory if not specified). If -sd is the only
echo option specified a new directory will be created to hold the archives'
echo contents.
echo "xzips -sd -od ." or "xzips here" can be used to store all archive
echo contents in the current directory