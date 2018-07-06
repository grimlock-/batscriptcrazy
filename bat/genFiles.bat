@echo off
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
REM			:x,z1,c:					Counter [leading zeroes, maximum/constant]
REM			:vn,sX,eX,iX,zX,nX:		Variable-number  [start, end, increment, leading zeroes, change num every nth iteration]
REM			:rs,asdf,3:				Repeating-string  [string to repeat, max num of repeats]

:printHelp
echo Create large quantities of files and optionally specify a naming convention
echo.
echo Usage:
echo genFiles [options] number
echo.
echo The simplest way to use this script is to provide a number and it will then
echo create that number of empty text files. These files will be named in typical
echo windows fashion for new text files, "New Text Document (X)" with X incrementing
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
echo both before and after the token definition. A printout of all allowed tokens and
echo their parameters can be provided with the "--tokens" option
echo.
echo Example:    genFiles -p "category:vn,n100:section:vn,n20:" -e xml 300
echo.
echo You can also specify the content of all generated files in one of two ways:
echo     1) Use the -c option to specify the content of all files on the command line
echo     2) Use the -cf option to specify a file that each generated file will be a
echo        copy of
echo If used with the -e option, nearly any quantity of copies of a single file can
echo be made.
echo.
echo Example:    genFiles -p "unit:x,2:" -cf template.doc 300
echo                 Will generate 300 Microsoft Word documents as copies of
echo                 template.doc file with filenames from unit001.doc to unit300.doc
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
echo    --debug [number]
echo        Don't create any files and print information detailing scipt actions.
echo        Higher numbers will result in more information being printed to the
echo        console. Defaults to level 1
echo.
echo    --tokens
echo        List all supported tokens and their parameters
echo.
echo    --help
echo        Print this message
exit /B

:printTokens
echo genFiles Tokens
echo.
echo x  - File Counter (ARGUMENTS NOT IMPLEMENTED)
echo        Inserts the file's number into the pattern (ex: 1 for the 1st file
echo        generated, 2 for the 2nd file, 3 for the 3rd, etc.)
echo            z - Leading Zeroes [int]
echo                Specifies a quantity of leading zeroes that should be inserted
echo                before the file counter
echo            c/m - Max or Constant leading zeroes [char]
echo                Constant leading zeroes will result in the specified number of
echo                leading zeros always being inserted before the file counter.
echo                Max leading zeroes results in starting with the specified
echo                number of leading zeroes and removing one every time a new digit
echo                is added to the file counter. For example, the following pattern
echo                        :x,z2,m:
echo                when executed with a file count of 300 will result in two leading
echo                zeroes for the first 9 files, one zero up to file 99, and none
echo                for the remaining files.
echo                If unspecified, defaults to minimal
echo.
echo.
echo NOT YET IMPLEMENTED
echo.
echo vn - Variable Number
echo          s - Starting number [int]
echo          e - Ending number [int]
echo              After reaching the ending number it loops back to the starting num
echo          i - Increment value [int]
echo          z - Leading Zeroes [int]
echo          n - Increment delay [int]
echo              Only increment
echo.
echo rs - Repeating String
echo          String
echo          Repeats [int]
echo.
echo Examples:
echo.
echo     :x,z1,c:					Counter [leading zeroes, max/constant]
echo     :vn,sX,eX,iX,zX,nX:		Variable-number  [start, end, increment, leading zeroes, change num every nth iteration]
echo     :rs,asdf,3:				Repeating-string  [string to repeat, max num of repeats]
exit /B

REM TODO - Function explanation
REM Expects first character to be a colon
:parsetoken
	if !_debuglvl! GTR 2 (
		echo ---parsetoken start---
		echo Arg 1: %1
	)
	set a=%~1
	set first=!a:~0,1!
	if not !first!==: (
		echo Cannot parse token: %1
		exit /B
	)

	set b=1
	:gettoken
	call set c=!a:~%b%,1!
	if !_debuglvl! GTR 2 echo Char: !c!
	if not !c!==: (
		set /A "b+=1"
		goto gettoken
	)
	set /A "b-=1"
	call set token=!a:~1,%b%!
	if !_debuglvl! GTR 2 echo Token "!token!"
	set /A "b+=2"
	call set "patternTemp=!patternTemp:~%b%!"
	call set /A "length-=%b%"
	set i=1
	
	if !_debuglvl! GTR 2 echo FOR loop start. Analyzing "!token!"
	for /F "tokens=1* delims=," %%j in ("!token!") do (
		if %%j==x (
			if !_debuglvl! GTR 1 echo Found token for file counter. Currently on file #!fileNum!
			set fname=!fname!!fileNum!
			if not -%%k-==-- (
				if !_debuglvl! GTR 2 echo Argument for file counter token: %%k
			)
			if !_debuglvl! GTR 1 echo Filename is now "!fname!"
		) else if %%j==vn (
			if !_debuglvl! GTR 1 echo Found token for variable number
		) else if %%j==rn (
			if !_debuglvl! GTR 1 echo Found token for repeating number
		) else if %%j==rs (
			if !_debuglvl! GTR 1 echo Found token for repeating string
		) else (
			if !_debuglvl! GTR 1 echo Unrecognized token "%%j"
		)
		if !_debuglvl! GTR 2 echo Iteration #!i!
		set /A "i+=1"
	)
	if !_debuglvl! GTR 2 (
		echo FOR loop end
		echo ---parsetoken end---
	)
goto :eof

:main
set fileNum=1
set numFiles=0
set pattern=New Text Document
set ext=txt
set counter=yes
set contentFile=no
set _debuglvl=0


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
	set content=%~2
	shift
) else if %1==--content (
	set content=%~2
	shift
) else if %1==-ct (
	set content=%~2
	set contentFile=yes
	shift
) else if %1==--content-template (
	set content=%2
	set contentFile=yes
	shift
) else if %1==--disable-counter (
	set counter=no
) else if %1==--debug (
	if not -%3-==-- (
		set _debuglvl=%2
		echo !_debuglvl!| findstr /r "^[1-9][0-9]*$">nul
		if errorlevel 1 (
			set _debuglvl=1
			set errorlevel=0
		) else (
			shift
		)
	) else (
		set _debuglvl=1
	)
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
if !_debuglvl! GTR 0 (
	echo.
	echo Debug level                   : !_debuglvl!
	echo Number of files to create     : !numFiles!
	echo Filename pattern specification: !pattern!
	echo Contents of each file         : !content!
	echo Extension for new files       : !ext!
	echo Use counter in filename       : !counter!
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
if !_debuglvl! GTR 2 echo Char: !char!
if !char!==: (
	if !_debuglvl! GTR 1 (
		echo Found Semicolon at offset !i!
		call echo Adding !patternTemp:~0,%i%! to filename
	)
	set /A "i-=1"
	call set fname=!patternTemp:~0,%i%!
	if !_debuglvl! GTR 1 echo Filename is now "!fname!"
	set /A "i+=i"
	call set patternTemp=!patternTemp:~%i%,%length%!
	call set /A "length-=%i%"
	
	call :parsetoken "!patternTemp!"
	if !_debuglvl! GTR 1 echo Remaining pattern: !patternTemp!
)
set /A "i+=1"
if !i! LEQ !length! (
	if !_debuglvl! GTR 2 (
		echo Finished character "!i!" of "!length!", continuing pattern processing
	)
	goto parsepattern
) else (
	if !length! GTR 0 (
		call set fname=!fname!!patternTemp!
	)
)




if !counter!==yes set fname=!fname! (!fileNum!)
set fname=!fname!.!ext!


if !_debuglvl! GTR 0 (
	echo copy "!content!" "!fname!"
	if !_debuglvl! GTR 1 echo.
	if !_debuglvl! GTR 2 echo.
) else if not exist !fname! (
	if -!content!-==-- (
		copy NUL "!fname!"
	) else if !contentFile!==no (
		echo !content! > "!fname!"
	) else (
		copy "!content!" "!fname!"
	)
) else (
	echo File "!fname:~0,53!" already exists!
)

set /a "fileNum+=1"
if !fileNum! LEQ !numFiles! goto mainloop
exit /B
