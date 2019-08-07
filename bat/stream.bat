@echo off
REM stream.bat
REM Front-end for streamlink to reduce typing and save a stream to file.

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

if not -%1-==-- goto main
:help
echo stream.bat args url
echo --vlc                         Use VLC instead of MPC-HC
echo --file                        Write stream to file
echo -p path (--player)            Use specified player
echo -q string (--quality)         Use argument as quality instead of "best"
echo -o directory (--directory)    Directory to write file to for --file option
echo                               (no trailing slash)
echo -r int (--retry)              Number of times to retry for --file option
echo                               -1 = infinite retries, stop after first exit
echo.
echo With the --file option, this script retries a stream after streamlink
echo successfully exits to try and account for temporary stream outages.
echo This delay is 60 seconds
echo If the next attempt fails the script stops
echo.
echo This script also waits for the -r/retry option, but only after streamlink
echo unsuccessfully exits (leaving an empty file, which this script deletes).
echo This delay is 5 minutes
echo Every time streamlink successfully exits, the script will reset the retry
echo counter for values above 0, but will just stop for a value of -1
echo.
echo The --file option does not save hosted streams for Twitch.tv, though they will
echo be played without this argument
exit /B

:main
set streamlink=!ProgramFiles!\Streamlink\bin\streamlink.exe
set player=!ProgramFiles!\MPC-HC\mpc-hc64.exe
set quality=best
set file=no
set outdir=!HOMEDRIVE!\!HOMEPATH!\Downloads
set retrymax=0
set retrycount=0
set size=0

:argloop
if %1==--vlc (
	set player=!ProgramFiles^(x86^)!\VideoLAN\VLC\vlc.exe
) else if %1==-p (
	if -%2-==-- goto help
	set player=%2
	shift
) else if %1==--player (
	if -%2-==-- goto help
	set player=%2
	shift
) else if %1==--file (
	set file=yes
) else if %1==-q (
	set quality=%2
	shift
) else if %1==--quality (
	set quality=%2
	shift
) else if %1==-o (
	set outdir=%2
	shift
) else if %1==--directory (
	set outdir=%2
	shift
) else if %1==-r (
	echo %2|findstr /r "^-[1-9][0-9]*$ ^[1-9][0-9]*$ ^0$">nul
	if errorlevel 1 (
		echo -r argument must be a number
		echo arg: %2
		exit /B
	)
	set retrymax=%2
	shift
) else if %1==--retry (
	echo %2|findstr /r "^-[1-9][0-9]*$ ^[1-9][0-9]*$ ^0$">nul
	if errorlevel 1 (
		echo --retry argument must be a number
		echo arg: %2
		exit /B
	)
    set retrymax=%2
	shift
) else (
	set url=%1
)
shift
if not -%1-==-- goto argloop

if !file!==no (
	if !retrymax! NEQ 0 (
		echo The --retry option only works with --file
	)
	"!streamlink!" -p "!player!" "!url!" !quality!
	exit /B
)

REM --file option present
:dlstream
set fname=!outdir!\!url:^/=_!_!time:^:=-!.mp4
"!streamlink!" --twitch-disable-hosting --stdout "!url!" "!quality!" > "!fname!"
call :setsize !fname!

REM Successful download
if !size! NEQ 0 (
	set retrycount=0
	REM Stop with -r -1 since it would never end otherwise
	if !retrymax! EQU -1 (
		exit /B
	)
	REM Wait a minute in case it's just a stream hiccup
	timeout 60
	goto dlstream
)

REM Empty download
del "!fname!"
if !retrymax! EQU -1 (
	set /A "retrycount+=1"
	REM 288 * 300sec = 86,400sec = 24hrs
	if !retrycount! GTR 288 (
		exit /B
	)
	timeout 300
	goto dlstream
)
if !retrycount! LSS !retrymax! (
	timeout 300
	set /A "retrycount+=1"
	goto dlstream
)
exit /B


:setsize
set size=%~z1
goto :eof