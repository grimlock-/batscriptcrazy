@echo off
REM Grab the contents of every directory in the current one or in the directory specified
REM by argument one and move them up on directory
setlocal EnableDelayedExpansion
if errorlevel 1 (
	echo Unable to enable Delayed variable expansion
	exit /B
)

set target=*
set debug=no

for %%i in (%*) do (
	if %%i==--debug (
		set debug=yes
	) else if %%i==-d (
		set debug=yes
	) else (
	    set target=%%i
	)
)

if !debug!==yes (
    echo Target directory: !target!
)

for /D %%i in (!target!) do (
    if !debug!==yes (
	    set tmp=%%i
        echo move "!tmp!\*" "!tmp!\.."
    ) else (
	    move "%%i\*" "%%i\.."
	)
)
exit /B

::BUGS
::When a target's only contents are more directories, this error is generated
::"The filename, directory name, or volume label syntax is incorrect."