@ECHO OFF
REM set /p="ss\r\nss ss"|clip
if NOT defined TEMPVARI01 (
    set "TEMPVARI01=true"
    start conhost.exe %0
    exit /b 0
)
SETLOCAL ENABLEDELAYEDEXPANSION
chcp 65001 >NUL
MODE 120,30 >NUL
REM echo 
CALL :RESET
CALL :DRAWLOGO
CALL :ASKPROMPT "Chip Name" CHIP_NAME "Name/ID of the chip to be configured in this project."
CALL :ASKPROMPT "Number of the pins" CHIP_PINNO "Number of the pins for !CHIP_NAME!. Min 2, Max 64."
SET "TEMPVARI01="
for /f "delims=0123456789" %%i in ("!CHIP_PINNO!") do set "TEMPVARI01=%%i"
if defined TEMPVARI01 SET "CHIP_PINNO=40"
IF !CHIP_PINNO! LSS 2 SET "CHIP_PINNO=2"
IF !CHIP_PINNO! GTR 64 SET "CHIP_PINNO=64"
SET /A TEMPVARI01=!CHIP_PINNO! %% 2
IF !TEMPVARI01! EQU 1 SET /A CHIP_PINNO+=1
REM ECHO !CHIP_PINNO!
REM SET TEMPVARI01=1
REM :LOOP01
FOR /L %%I IN (1,1,!CHIP_PINNO!) DO SET "CHIP_PIN%%I=Desc %%I"
SET /A "TEMPVARI02=(!CHIP_PINNO! / 2) + 18"
IF !CHIP_PINNO! GEQ 28 (
	FOR /L %%I IN (30,1,!TEMPVARI02!) DO MODE 120,%%I >NUL & BREAK
) ELSE (
	FOR /L %%I IN (30,-1,!TEMPVARI02!) DO MODE 120,%%I >NUL & BREAK

)
GOTO DRAWDIP

:DRAWDIP
CALL :DRAWLOGO
ECHO !CHIP_NAME! Pinout !WRITEORNOT!
ECHO.
ECHO 			 .--__--.
SET /A "TEMPVARI01=!CHIP_PINNO! / 2"
SET "TEMPVARI02=!CHIP_PINNO!"
FOR /L %%I IN (1,1,!TEMPVARI01!) DO ( 
	
	REM ECHO 	%%I	S!TEMPVARI02!
	CALL :STRLENFIT TEMPVARI03 2 0 %%I
	CALL :STRLENFIT TEMPVARI04 2 0 !TEMPVARI02!
	CALL :STRLENFIT TEMPVARI05 23 B !CHIP_PIN%%I!
	CALL :DELAYEDWRAP TEMPVARI06 CHIP_PIN!TEMPVARI02%!
	ECHO !TEMPVARI05! -^|!TEMPVARI03!  !TEMPVARI04!^|- !TEMPVARI06!
	REM echo 			`------'
	SET /A TEMPVARI02-=1
)
timeout 0 >nul
echo 			 '------'
ECHO 	[7m[←↑↓→][27m_Move Cursor	[7m[ENTER][27m_Edit chosen label	[7m[X][27m_Copy to clipboard with markdown characters
ECHO.
ECHO 	[7m[S][27m_Save as .txt	[7m[C][27m_Copy to clipboard		[101m[93m[7m[N][27m_New[0m

:LOOP2
CALL :GETCONSOLECURSORPOS !CURSORPOS! TEMPVARI04
CALL :STRLENFIT TEMPVARI03 2 0 !CURSORPOS!
ECHO [!TEMPVARI04!H[7m!TEMPVARI03![27m
powershell "exit($Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode)"
CALL :GETCONSOLECURSORPOS !CURSORPOS! TEMPVARI04
CALL :STRLENFIT TEMPVARI03 2 0 !CURSORPOS!
ECHO [!TEMPVARI04!H[27m!TEMPVARI03!
IF !ERRORLEVEL! GEQ 37 IF !ERRORLEVEL! LEQ 40 (
	REM SET /A "TEMPVARI01=!CHIP_PINNO! / 2"
	SET "TEMPVARI07="
	IF !ERRORLEVEL! EQU 37 SET /A TEMPVARI07=!CHIP_PINNO! - !CURSORPOS! + 1
	IF !ERRORLEVEL! EQU 39 SET /A TEMPVARI07=!CHIP_PINNO! - !CURSORPOS! + 1
	
	IF !CURSORPOS! LEQ !TEMPVARI01! (
		IF !ERRORLEVEL! EQU 38 SET /A CURSORPOS-=1
		IF !ERRORLEVEL! EQU 40 SET /A CURSORPOS+=1
		IF !CURSORPOS! LSS 1 SET "TEMPVARI07=!TEMPVARI01!"
		IF !CURSORPOS! GTR !TEMPVARI01! SET "TEMPVARI07=1"
	) ELSE (
		IF !ERRORLEVEL! EQU 38 SET /A CURSORPOS+=1
		IF !ERRORLEVEL! EQU 40 SET /A CURSORPOS-=1
		IF !CURSORPOS! LEQ !TEMPVARI01! SET "TEMPVARI07=!CHIP_PINNO!"
		IF !CURSORPOS! GTR !CHIP_PINNO! SET /A "TEMPVARI07=!TEMPVARI01! + 1"
	)
	IF DEFINED TEMPVARI07 SET "CURSORPOS=!TEMPVARI07!"	
)
IF !ERRORLEVEL! EQU 13 (
	CALL :ASKPROMPT "Label for pin !CURSORPOS!" CHIP_PIN!CURSORPOS! "A label for this specific pin."
	GOTO DRAWDIP
)
IF !ERRORLEVEL! EQU 67 (
	SET "TEXTPATH=1!TEMP!\!RANDOM!!RANDOM!.TXT"
	REM SET "WRITEORNOT=^>"!TEXTPATH:~1!""
	REM PAUSE
	REM ECHO !WRITEORNOT!
	REM PAUSE
	REM SET "COPYORNOT=1"
	
	CALL :WRITETEXT "!TEXTPATH:~1!"
	REM TYPE "!TEMPVARI01!"|clip
)
GOTO LOOP2
REM pause

:DRAWLOGO
CLS
ECHO [0mDIPPP, Dual Inline Package Pinout Picker		[4mCopyright 2025 [93mHeeminTV[24m
ECHO.

echo 	[97m██████╗ ██╗██████╗ ██████╗ ██████╗ 

echo 	██╔══██╗██║██╔══██╗██╔══██╗██╔══██╗

echo 	[37m██║  ██║██║██████╔╝██████╔╝██████╔╝

echo 	██║  ██║██║██╔═══╝ ██╔═══╝ ██╔═══╝ 

echo 	[90m██████╔╝██║██║     ██║     ██║     

echo 	╚═════╝ ╚═╝╚═╝     ╚═╝     ╚═╝    

ECHO [0m
GOTO :EOF

:ASKPROMPT
echo [15;30H[100m[93m╠═════════════╩════════════════════════════════════════════╗

echo [16;30H║                                                          ║

echo [17;30H║                                                          ║

echo [18;30H║                                                          ║

echo [19;30H║                                                          ║

echo [20;30H╚══════════════════════════════════════════[7m[ENTER][27m_CONFIRM═╝

ECHO [14;30H║    DIPPP    ║

echo [13;30H╔═════════════╗

ECHO [16;32H%~1
ECHO [19;32H[40m                                                        [100m ║
ECHO [19;33H[40m[90m!%~2![100m
ECHO [17;32H  [33m%~3[93m
SET /P "%~2=[19;33H[40m"
GOTO :EOF

:RESET
SET "CHIP_NAME=AX5208C"
SET "CHIP_PINNO=40"
SET "CURSORPOS=1"
SET "WRITEORNOT="




GOTO :EOF

REM :FILLBLANK VARINAME FILLWITH HOWFILL
REM :strLen_Loop
REM if not "!%1:~%%!"=="" set /A TEMPVARI10+=1 & goto :FILLBLANK

:STRLENFIT
set "STRLENFIT_TEMPVAR1=%1"
set "STRLENFIT_TEMPVAR2=%2"
set "STRLENFIT_TEMPVAR6=%3"
shift
shift
shift

set "STRLENFIT_TEMPVAR3="
:STRLENFIT_combineArgs
if "%~1"=="" goto :STRLENFIT_processString
set "STRLENFIT_TEMPVAR3=!STRLENFIT_TEMPVAR3!%~1 "
shift
goto :STRLENFIT_combineArgs

:STRLENFIT_processString
set "STRLENFIT_TEMPVAR3=!STRLENFIT_TEMPVAR3:~0,-1!"
for /l %%a in (0,1,64) do if not "!STRLENFIT_TEMPVAR3:~%%a,1!" == "" set /a STRLENFIT_TEMPVAR4+=1

if !STRLENFIT_TEMPVAR4! gtr !STRLENFIT_TEMPVAR2! (
	set "!STRLENFIT_TEMPVAR1!=!STRLENFIT_TEMPVAR3!
) else (
	set "!STRLENFIT_TEMPVAR1!=!STRLENFIT_TEMPVAR3!"
    set /a STRLENFIT_TEMPVAR5=STRLENFIT_TEMPVAR2 - STRLENFIT_TEMPVAR4
    for /l %%i in (1,1,!STRLENFIT_TEMPVAR5!) do IF "!STRLENFIT_TEMPVAR6!" EQU "0" ( 
		set "!STRLENFIT_TEMPVAR1!=0!%STRLENFIT_TEMPVAR1%!"
	) ELSE IF "!STRLENFIT_TEMPVAR6!" EQU "B" ( 
		set "!STRLENFIT_TEMPVAR1!= !%STRLENFIT_TEMPVAR1%!"
	) ELSE set "!STRLENFIT_TEMPVAR1!=!%STRLENFIT_TEMPVAR1%! "
)
set "STRLENFIT_TEMPVAR1="
set "STRLENFIT_TEMPVAR2="
set "STRLENFIT_TEMPVAR3="
set "STRLENFIT_TEMPVAR4="
set "STRLENFIT_TEMPVAR5="
set "STRLENFIT_TEMPVAR6="
GOTO :EOF

:DELAYEDWRAP
SET "%~1=!%~2!"
GOTO :EOF

:GETCONSOLECURSORPOS
REM 13 27
REM PAUSE
IF !CURSORPOS! LEQ !TEMPVARI01! (
	SET /A "%~2=!CURSORPOS! + 12"
	SET "%~2=!%~2!;27"	
) ELSE (
	REM PAUSE
	REM PAUSE
	REM ECHO DUMB
	SET /A "%~2=!CHIP_PINNO! - !CURSORPOS! + 1"
	SET /A "%~2=!%~2! + 12"
	SET "%~2=!%~2!;31"	
)
GOTO :EOF

REM :WRITETEXT
:WRITETEXT
ECHO !CHIP_NAME! Pinout !WRITEORNOT! >"%~1"
ECHO. >"%~1"
ECHO 			 .--__--. >"%~1"
SET /A "TEMPVARI01=!CHIP_PINNO! / 2"
SET "TEMPVARI02=!CHIP_PINNO!"
FOR /L %%I IN (1,1,!TEMPVARI01!) DO ( 
	
	REM ECHO 	%%I	S!TEMPVARI02!
	CALL :STRLENFIT TEMPVARI03 2 0 %%I
	CALL :STRLENFIT TEMPVARI04 2 0 !TEMPVARI02!
	CALL :STRLENFIT TEMPVARI05 23 B !CHIP_PIN%%I!
	CALL :DELAYEDWRAP TEMPVARI06 CHIP_PIN!TEMPVARI02%!
	ECHO !TEMPVARI05! -^|!TEMPVARI03!  !TEMPVARI04!^|- !TEMPVARI06! >"%~1"
	REM echo 			`------'
	SET /A TEMPVARI02-=1
)
echo 			 '------' >"%~1"
start "%~1"
goto :eof