@echo off
REM This script takes a string as an argument and adds it to the name of
REM every file or directory in the current directory

REM IDEAS
REM   *Allow user to specify an array of strings to be cycled through when
REM    creating filenames
REM       -Counter that only increments after a complete pass through the array
REM       -or instead of a string array, specify a number range
REM   *What I really need to do is set up a system for specifying a naming
REM    convention. Like having the user specify a single unit/entity (number,
REM    character, string) and then add modifiers to it (add string to end or
REM    beginning of filename, increment number after each file by specified
REM    amount or multiply by a given number, repeat some character x number of
REM    times)
REM        -And I mean implementing this as a user-provided string kind of like
REM         regular expressions, not some hideous assortment of 50 command line
REM         options

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

REM Use Cases:
REM 	- 0010.txt, 0020.txt, 0030.txt, 0040.txt...
REM 	- string1.txt, string2.txt, string3.txt, string4.txt...
REM 	- string2.txt, string4.txt, string6.txt, string8.txt...
REM 	- x.txt, xx.txt, xxx.txt, xxxx.txt, xxxxx.txt...
REM 	- x.txt, xxx.txt, xxxxx.txt, xxxxxxx.txt, xxxxxxxxx.txt...
REM 	- cat1file1.json, cat1file2.json, cat1file3.json, cat2file1.json, cat2file2.json, cat2file3.json....

REM Tokens:
REM			:x,1:					Counter [leading zeroes]
REM			:vn,sX,eX,iX,zX,nX:		Variable-number  [start, end, increment, leading zeroes, change num every nth iteration]
REM			:rn,236,3:				Repeating-number  [num to repeat, max num of repeats]
REM			:rs,asdf,3:				Repeating-string  [string to repeat, max num of repeats]

:printHelp
echo Create large quantities of files and optionally specify a naming convention
echo.
echo Usage:
echo genFiles [options] number
echo.
echo The simplest way to use this script is to provide a number and it will then
echo create that number of empty text files. These files will be named in typical
echo windows fashion for new textfiles, "New Text Document (X)" with X incrementing
echo with each file created to ensure a unique filename.
echo.
echo Example:    genFiles 50
echo.
echo To name each file something other than "New Text Document", you can use the -p
echo option to specify a string that will be used in every filename.
echo.
echo Example:    genFiles -p "another text doc" 50
echo.
echo In addition to specifying a string constant to be included in each filename, you
echo can include tokens to signify dynamic elements such as a number that changes for
echo each file, or a number/string that repeats a varying number of times. All tokens
echo and their parameters must be separated from the rest of the pattern with a colon
echo both before and after the token definition.
echo.
echo Example:    genFiles -p "category:vn,n100:section:vn,n20:" -e xml 300
echo.
echo ======================================TODO======================================
echo                           Finish writing the help page                          
echo ================================================================================
echo.
echo.
echo ARGUMENTS:
echo.
echo    number
echo        The quantity of files that will be created
echo.
echo    -p string (--pattern)
echo        Filename pattern for newly generated files
echo.
echo    -e, --extension
echo        Extension for the new files
echo.
echo    -c string (--content)
echo        Content of each newly created file
echo.
echo    -cf file (--content-file)
echo        File who's contents each newly created file will contain
echo.
echo    --disable-counter
echo        Don't add "(X)" to the end of each filename
echo.
echo    --debug
echo        Don't create any files, just output the properties of the pattern
echo.
echo    --help
echo        Print this message
exit /B

REM TODO - Function explanation
REM Expects first character to be a colon, 
:parsetoken
	REM if !_debug!==yes (
		REM echo.
		REM echo ---parsetoken start---
		REM echo Arg 1: %1
	REM )
	set a=%~1
	set first=!a:~0,1!
	if not !first!==: (
		echo Cannot parse token: %1
		exit /B
	)

	set b=1
	:gettoken
	call set c=!a:~%b%,1!
REM	echo Char: !c!
	if not !c!==: (
		set /A "b+=1"
		goto gettoken
	)
	set /A "b-=1"
	call set token=!a:~1,%b%!
REM	echo Token [!token!]
	set /A "b+=2"
	call set "patternTemp=!patternTemp:~%b%!"
	REM Recalculate length
	echo !patternTemp!>x & for %%j in (x) do (
		set /A length=%%~zj - 2 & del x
	)
	set /A length=!length!-1
	set i=0
	
REM	echo FOR loop start
	for /F "delims=," %%j in ("!token!") do (
		if %%j==x (
REM			if !_debug!==yes echo Found token for file counter
			set fname=!fname!!fileNum!
		) else if %%j==vn (
			if !_debug!==yes echo Found token for variable number
		) else if %%j==rn (
			if !_debug!==yes echo Found token for repeating number
		) else if %%j==rs (
			if !_debug!==yes echo Found token for repeating string
		)
	)
	REM echo FOR loop end
	REM echo ---parsetoken end---
	REM echo.
goto :eof

:main
set fileNum=1
set numFiles=0
set pattern=New Text Document
set ext=txt
set counter=yes
set content=NUL
set contentFile=no
set _debug=no


:argloop
if %1==-p (
	set pattern=%~2
	shift
) else if %1==--pattern (
	set pattern=%~2
	shift
) else if %1==-e (
	set ext=%1
) else if %1==--extension (
	set ext=%1
) else if %1==-c (
	set content=%2
	shift
) else if %1==--content (
	set content=%2
	shift
) else if %1==-ct (
	set content=%2
	set contentFile=yes
	shift
) else if %1==--content-template (
	set content=%2
	set contentFile=yes
	shift
) else if %1==--disable-counter (
	set counter=no
) else if %1==--debug (
	set _debug=yes
) else if %1==--help (
	goto printHelp
) else (
	set numFiles=%1
)
shift
if not -%1-==-- goto argloop




REM Sanity checks
REM Make sure variable isn't empty
if -!numFiles!-==-- goto printHelp
REM Test to see if numFiles is a number
echo !numFiles!| findstr /r "^[1-9][0-9]*$">nul
if errorlevel 1 (
	echo Please make the last argument a number
	exit /B
)
REM numFiles must be greater than zero
if !numFiles! LEQ 0 goto printHelp


REM Print options
if !_debug!==yes (
	echo Number of files to create     : !numFiles!
	echo Filename pattern specification: !pattern!
	echo Contents of each file         : !content!
	echo Extension for new files       : !ext!
	echo Use counter                   : !counter!
	echo.
)

:mainloop
set patternTemp=!pattern!
echo !patternTemp!>x & for %%i in (x) do (
	set /A length=%%~zi - 2 & del x
)
set /A length=!length!-1
set i=0
set fname=

:parsepattern
call set char=!patternTemp:~%i%,1!
if !char!==: (
REM	if !_debug!==yes echo Found Semicolon
	set /A "i-=1"
	call set fname=!patternTemp:~0,%i%!
	set /A "i+=i"
	call set patternTemp=!patternTemp:~%i%,%length%!
	REM Recalculate length
	echo !patternTemp!>x & for %%j in (x) do (
		set /A length=%%~zj - 2 & del x
	)
	set /A length=!length!-1
	
	call :parsetoken !patternTemp!
)
set /A "i+=1"
REM echo Finished processing character !i!
if !i! LEQ !length! ( 
	goto parsepattern
) else (
	if !length! GTR 0 (
		call set fname=!fname!!patternTemp!
	)
)




if !counter!==yes set fname=!fname! (!fileNum!)
set fname=!fname!.!ext!

@echo on
if !_debug!==yes (
	echo copy "!content!" "!fname!"
) else if not exist !fname! (
	if !contentFile!==no (
		echo !content:^"=! > "!fname!"
	) else (
		copy "!content!" "!fname!"
	)
) else (
	echo File "!fname:~0,53!" already exists!
)
@echo off


set /a "fileNum+=1"
if !fileNum! LEQ !numFiles! goto mainloop
exit /B