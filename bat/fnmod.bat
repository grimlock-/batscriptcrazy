@echo off
REM This script is used for modifying filenames in file sets that are named in a number
REM sequence like 1.jpg, 2.jpg, 3.jpg, etc.

REM TODO:
REM     *Test the leading zeros aspect of norm when counting down and going past zero
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
echo Change filenames for large file sets. Primarily for number sequence based
echo file sets (ex: 01.jpg to 99.jpg)
echo.
echo fnmod [options] mode [args]
echo.
echo   PRIMARY MODES
echo     normalize (norm)
echo         Rename all files in the current directory as a number sequence
echo         (def. 1.png to n.png)
echo.
echo     increase(inc) [num]
echo         Rename all files by increasing them by a specified amount
echo         Arguments:
echo             num (optional) - Quantity you want to increase by (default 1)
echo.
echo     decrease(dec) [num]
echo         Rename all files by decreasing them by a specified amount
echo         Arguments:
echo             num (optional) - Quantity you want to decrease by (default 1)
echo.
echo     replace(rep) string1 string2
echo         Replace string1 with string2 in all filenames
echo         Arguments:
echo             string1 (mandatory) - string to get remove (can use wildcards)
echo             string2 (optional) - string to put in its place. Not providing this
echo             argument will simply delete the first string from every file name
echo.
echo     delete(del) string
echo     remove(rem) string
echo         Aliases for calling replace with no 2nd argument
echo.
echo   NOTES
echo       When using increase or decrease mode, make sure the lower numbered files
echo       have enough leading zeros that they have the same amount of digits as the
echo       highest numbered file. Otherwise the script will grab the files in the
echo       wrong order and everything's going to be really messed up
echo.
echo   OPTIONS
echo     -s num (--start)
echo         No leading zeroes. The script will add those as necessary
echo         norm mode:
echo             Start new filename sequence from num instead of 1
echo         inc/dec mode:
echo             Only change filenames greater than or equal to num
echo     -cd (--countdown) [mode: norm]
echo         Normalize filenames by counting down from the starting point instead of
echo         up. So the first file will be the highest number after completion.
echo     -n num (--quantity) [mode: norm]
echo         Stop script after renaming num files
echo     -z (--leading-zeros) [mode: norm]
echo         Include leading zeros in the newly generated filenames
echo     --debug
echo         Verbose output for debugging
echo     --renames
echo         Don't rename any files, just print what commands will be run instead
echo     -h (--help)
echo         Show this help message
exit /B


:normalize
	set pot=no
	REM "zeros" stores a sequence of 0 or more zeros which may be added to the
	REM beginning of each newly generated filename
	set zeros=
	set a=!count!
	if !counting!==up (
		if not !start!==1 (
			set /A a=count+start
			set /A a-=1
		)
		REM Add a 0 for each digit in the highest number
		:digitloop
		set /A a=!a!/10
		if !a! GTR 0 (
			if !_debug!==yes echo Adding 0
			set zeros=!zeros!0
			goto digitloop
		)
		if !_debug!==yes (
			echo Finished adding zeros
			echo Result: !zeros!
			echo.
		)
		REM Remove a 0 for each digit in the starting point
		set a=!start!
		:digitloop2
		if !a! GTR 9 (
			if !_debug!==yes echo Removing 0
			set zeros=!zeros:~1!
			set /A a=!a!/10
			goto digitloop2
		)
		if !_debug!==yes (
			echo Finished removing zeros
			echo Result: !zeros!
			echo.
		)
	)
	
	set n=!start!
	for %%i in (*) do (
		if not %%i==!_me! (
			set ext=%%~xi
			if !leadingzeros!==yes (
				if !_debug!==rens (
					echo "%%i" "!zeros!!n!!ext!"
				) else if !_debug!==yes (
					echo "%%i" "!zeros!!n!!ext!"
				) else (
					ren "%%i" "!zeros!!n!!ext!"
				)
			) else (
				if !_debug!==rens (
					echo ren "%%i" "!n!!ext!"
				) else if !_debug!==yes (
					echo ren "%%i" "!n!!ext!"
				) else (
					ren "%%i" "!n!!ext!"
				)
			)
			
			if not -!qt!-==-- (
				set /A qt=!qt!-1
				if !qt! LEQ 0 exit /B
			)
			
			if !counting!==up (
				set /A n=!n!+!step!
				if not -!zeros!-==-- (
					call :getpot "!n!"
					if !pot!==yes (
						if !zeros!==0 (
							set zeros=
							if !_debug!==yes echo zeros variable unset
						) else (
							if !_debug!==yes echo a zero has been removed
							set zeros=!zeros:~1!
						)
					)
					set pot=no
				)
			) else if !counting!==down (
				call :getpot "!n!"
				if !pot!==yes set zeros=0!zeros!
				set pot=no
				set /A n=!n!-!step!
			)
		)
	)
exit /B

REM This part was originally all inline at the spot where it's currently being
REM called from, but the goto was fucking with the for loop everything is
REM encased inside of and the script would just stop after renaming file 99
:getpot
	set a=%~1
	if !_debug!==yes echo getPOT input is !a!
	:digitloop3
	set /A b=!a!%%10
	if not !b!==0 goto :eof
	set /A a=!a!/10
	if !a! GTR 9 goto digitloop3
	if !a! EQU 1 set pot=yes
goto :eof

:increase
	REM Directory listing in descending order
	for /f "delims=" %%i in ('dir /B /O-n /A-D-H-S') do (
		if not %%i==!_me! (
			set zeros=
			set pot=no
			REM Sets the filename to the variable n
			call :removezeros "%%~ni"
			set ext=%%~xi
			REM Trying to expand both n and step on this line gave a "missing operator." error for some reason
			set /A newnum=n+step
			set /A lowbound=n+1
			REM If renaming adds a digit, take off a leading zero
			for /L %%j in (!lowbound!,1,!newnum!) do (
				set pot=no
				call :getpot "%%j"
				if !pot!==yes (
					if not -!zeros!-==-- (
						set zeros=!zeros:~1!
					)
				)
			)
			if !_debug!==rens (
				if !n! GEQ !start! (
					echo n is !n!
					echo ren "%%i" "!zeros!!newnum!!ext!"
				)
			) else if !_debug!==yes (
				if !n! GEQ !start! (
					echo n is !n!
					echo ren "%%i" "!zeros!!newnum!!ext!"
				)
			) else (
				if !n! GEQ !start! (
					ren "%%i" "!zeros!!newnum!!ext!"
				)
			)
		)
	)
exit /B

:decrease
	for %%i in (*) do (
		if not %%i==!_me! (
			set zeros=
			set pot=no
			REM Sets the filename to the variable n
			call :removezeros "%%~ni"
			set ext=%%~xi
			REM Trying to expand both n and step on this line gave a "missing operator." error for some reason
			set /A newnum=n-step
			set /A lowbound=newnum+1
			for /L %%j in (!lowbound!,1,!n!) do (
				set pot=no
				call :getpot "%%j"
				if !pot!==yes (
					set zeros=0!zeros!
				)
			)
			if !_debug!==rens (
				if !n! GEQ !start! (
					echo n is !n!
					echo ren "%%i" "!zeros!!newnum!!ext!"
				)
			) else if !_debug!==yes (
				if !n! GEQ !start! (
					echo n is !n!
					echo ren "%%i" "!zeros!!newnum!!ext!"
				)
			) else (
				if !n! GEQ !start! (
					ren "%%i" "!zeros!!newnum!!ext!"
				)
			)
		)
	)
exit /B

:replace
	for %%i in (*) do (
		if not %%i==!_me! (
			if !_debug!==yes echo %%i
			set tmpName=%%i
			set tmpName=!tmpName:%find%=!
			if !_debug!==yes echo tmpName: !tmpName!
			if not !tmpName!==%%i (
				set newname=%%i
				set newname=!newname:%find%=%replace%!
				if !_debug!==rens (
					echo ren "%%i" "!newname!"
				) else if !_debug!==yes (
					echo ren "%%i" "!newname!"
				) else (
					ren "%%i" "!newname!"
				)
			) else (
				if !_debug!==yes (
					echo String not found, skipping "%%i"
				)
			)
		)
		if !_debug!==yes echo.
	)

:removezeros
	set name=%~1
	set char=!name:~0,1!
	:zerosloop
	if !char!==0 (
		set name=!name:~1!
		set char=!name:~0,1!
		set zeros=0!zeros!
		goto zerosloop
	)
	set n=!name!
goto :eof

:main
set _debug=no
set _me=%~nx0
set _validmode=0
set start=1
set step=1
set count=0
set counting=up
set leadingzeros=no

:argloop
if %1==-s (
	set start=%2
	shift
) else if %1==--start (
	set start=%2
	shift
) else if %1==-n (
	set qt=%2
	shift
) else if %1==--quantity (
	set qt=%2
) else if %1==-cd (
	set counting=down
) else if %1==--countdown (
	set counting=down
) else if %1==-z (
	set leadingzeros=yes
) else if %1==--leading-zeros (
	set leadingzeros=yes
) else if %1==--debug (
	set _debug=yes
) else if %1==--renames (
	set _debug=rens
) else if %1==normalize (
	set mode=norm
) else if %1==norm (
	set mode=norm
) else if %1==increase (
	set mode=inc
	if not -%2-==-- (
		set step=%2
		shift
	)
) else if %1==inc (
	set mode=inc
	if not -%2-==-- (
		set step=%2
		shift
	)
) else if %1==decrease (
	set mode=dec
	if not -%2-==-- (
		set step=%2
		shift
	)
) else if %1==dec (
	set mode=dec
	if not -%2-==-- (
		set step=%2
		shift
	)
) else if %1==replace (
	set mode=rep
	if -%2-==-- (
		goto printHelp
	)
	set find=%~2
	if not -%3-==-- (
		set replace=%3
	)
	shift
	shift
) else if %1==rep (
	set mode=rep
	if -%2-==-- (
		goto printHelp
	)
	set find=%~2
	if not -%3-==-- (
		set replace=%3
	)
	shift
	shift
) else if %1==del (
	set mode=rep
	if -%2-==-- (
		goto printHelp
	)
	set find=%~2
	shift
) else if %1==--delete (
	set mode=rep
	if -%2-==-- (
		goto printHelp
	)
	set find=%~2
	shift
) else if %1==rem (
	set mode=rep
	if -%2-==-- (
		goto printHelp
	)
	set find=%~2
	shift
) else if %1==remove (
	set mode=rep
	if -%2-==-- (
		goto printHelp
	)
	set find=%~2
	shift
) else if %1==-h (
	goto printHelp
) else if %1==--help (
	goto printHelp
) else (
	echo Unrecognized option: %1
	goto printHelp
)
shift
if not -%1-==-- goto argloop

if !_debug!==yes (
	echo Operating mode   : !mode!
	echo Starting at      : !start!
	echo Step quantity    : !step!
	echo Counting         : !counting!
	echo Leading zeros    : !leadingzeros!
	echo Text to remove   : !find!
	echo Replacement text : !replace!
)

REM sanity checks
if -!mode!-==-- goto printHelp
if !mode!==norm set _validmode=1
if !mode!==inc set _validmode=1
if !mode!==dec set _validmode=1
if !mode!==rep set _validmode=1
if !_validmode!==0 goto printHelp
REM If any of these variables isn't a number (no leading zeros), the error level will be set to 1
echo !step!| findstr /r "^[1-9][0-9]*$">nul
echo !start!| findstr /r "^[1-9][0-9]*$">nul
if not -!qt!-==-- echo !qt!| findstr /r "^[1-9][0-9]*$">nul
if errorlevel 1 goto printHelp

REM Get file count
for %%i in (*) do (
	if not %%i==!_me! (
		if !mode!==inc (
			echo %%~ni| findstr /r "^[0-9][0-9]*$">nul
			if errorlevel 1 (
				echo Every filename in the directory must be a number for increase mode
				exit /B
			)
		) else if !mode!==dec (
			echo %%~ni| findstr /r "^[0-9][0-9]*$">nul
			if errorlevel 1 (
				echo Every filename in the directory must be a number for decrease mode
				exit /B
			)
		)
		set /A count+=1
	)
)

if !_debug!==yes (
	echo Number of files: !count!
	echo.
)

if !mode!==norm (
	goto normalize
) else if !mode!==inc (
	goto increase
) else if !mode!==dec (
	goto decrease
) else if !mode!==rep (
	goto replace
)
goto printHelp