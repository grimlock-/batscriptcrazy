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
echo Change file names for number sequence-based file sets (ex. 01.jpg to 99.jpg)
echo.
echo fnmod mode [options]
echo.
echo   PRIMARY MODES
echo     normalize (norm)
echo         Rename all files in the current directory as a number sequence
echo         (def. 1.png to n.png)
echo     increase (inc)
echo         Rename all files by increasing filename numbers by a set amount (def 1)
echo     decrease (dec)
echo         Rename all files by decreasing filename numbers by a set amount (def 1)
echo.
echo   NOTES
echo       When using increase or decrease mode, make sure the lower numbered files
echo       have enough leading zeros that they have the same amount of digits as the
echo       highest numbered file. Otherwise the script will grab the files in the
echo       wrong order and everything's going to be really messed up
echo.
echo   OPTIONS
echo     -s num (--start) [mode: norm]
echo         Start new filename sequence from num instead of 1
echo     -cd (--countdown) [mode: norm]
echo         Normalize filenames by counting down from the starting point instead of
echo         up. So the first file
echo     -n num (--quantity) [mode: norm]
echo         Stop script after renaming num files
echo     -z (--leading-zeros) [mode: norm]
echo         Include leading zeros in the newly generated filenames
echo     -d num (--delta) [modes: inc, dec]
echo         Numerical difference between all newly named files (def 1)
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
				) else (
					ren "%%i" "!zeros!!n!!ext!"
				)
			) else (
				if !_debug!==rens (
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
	for /f "delims=" %%i in ('dir /B /O-n /A-D-H-S') do (
		if not %%i==!_me! (
			set zeros=
			set pot=no
			REM Sets the filename to the variable n
			call :removezeros "%%i"
			set ext=%%~xi
			REM Trying to expand both n and step on this line gave a "missing operator." error for some reason
			set /A newnum=n+step
			set /A lowbound=n+1
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
				echo ren "%%i" "!zeros!!newnum!!ext!"
			) else (
				ren "%%i" "!zeros!!newnum!!ext!"
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
			call :removezeros "%%i"
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
				echo ren "%%i" "!zeros!!newnum!!ext!"
			) else (
				ren "%%i" "!zeros!!newnum!!ext!"
			)
		)
	)
exit /B

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
set mode=
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
) else if %1==-d (
	set step=%2
	shift
) else if %1==--delta (
	set step=%2
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
) else (
	set mode=%1
)
shift
if not -%1-==-- goto argloop

if !_debug!==yes (
	echo Operating mode : !mode!
	echo Starting at    : !start!
	echo Step quantity  : !step!
	echo Counting       : !counting!
	echo Leading zeros  : !leadingzeros!
)

REM sanity checks
if -!mode!-==-- goto printHelp
if !mode!==norm set _validmode=1
if !mode!==normalize (
	set mode=norm
	set _validmode=1
)
if !mode!==inc set _validmode=1
if !mode!==increase (
	set mode=inc
	set _validmode=1
)
if !mode!==dec set _validmode=1
if !mode!==decrease (
	set mode=dec
	set _validmode=1
)
if !_validmode!==0 goto printHelp
REM If any variable isn't a number, the error level will be set to 1
echo !step!| findstr /r "^[1-9][0-9]*$">nul
echo !start!| findstr /r "^[1-9][0-9]*$">nul
if not -!qt!-==-- echo !qt!| findstr /r "^[1-9][0-9]*$">nul
if errorlevel 1 goto printHelp

for %%i in (*) do (
	if not %%i==!_me! (
		if not !mode!==norm (
			echo %%~ni| findstr /r "^[0-9][0-9]*$">nul
			if errorlevel 1 (
				echo Every filename in the directory must be a number unless normalize mode is chosen
				exit /B
			)
		)
		if -!_firstfile!-==-- set _firstfile=%%~ni
		set _lastfile=%%~ni
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
)
goto printHelp