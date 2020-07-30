@echo off
setlocal EnableDelayedExpansion


for /f "tokens=4 delims=. " %%i in ('ver') do set "winver=%%i"
if "%winver%" lss "10" (echo Warning: possible incompatible Windows version 1>&2 & echo.)


set "char1=%~1"
set "char1=%char1:~0,1%"
if /i "%char1%"=="r" (goto rgbtohex)
if /i "%char1%"=="h" (goto hextorgb)
goto help


:rgbtohex
call :getesc

if "%~2"=="" goto missingparam

set "hexvalue=%~2"
for /f "tokens=1 delims=1234567890abcdefABCDEF" %%A in ("%hexvalue%") do (
	echo Invalid hexadecimal value
	goto exit
)


echo.%hexvalue% > "%TMP%\hex2rgb.len"
for %%A in ("%TMP%\hex2rgb.len") do set /a hex2rgb_len=%%~zA-3


if "%hex2rgb_len%" neq "6" (echo Invalid hexadecimal value & set xt=1 & goto exit)

set R=%hexvalue:~0,2%
set G=%hexvalue:~2,2%
set B=%hexvalue:~4,2%


for %%R in ("%R%" "%G%" "%B%") do if "%%~R" geq 256 (echo Invalid hexadecimal value & set xt=1 & goto exit)


set /a R_=0x%R%
set /a G_=0x%G%
set /a B_=0x%B%

echo.RGB: !R_!, !G_!, !B_!
echo %ESCchar%[38;2;%R_%;%G_%;%B_%mExample text%escchar%[0;00m
goto exit


:hextorgb

call :getesc
if "%~2"=="" goto missingparam
if "%~5" neq "" goto toomanyparam
if "%~4" neq "" (goto split_spaces) else goto split_commas
:splitted
for /f "tokens=1 delims=1234567890" %%A in ("%R%!G!%B%") do (
	echo Invalid RGB value
	goto exit
)

if %R% equ 0 set "R_=00" & set "R=000" & goto h2r_skipr

cmd /c exit %R%
set h1=%=ExitCode%
for /f "delims=" %%R in ('echo.%h1:~-2%') do set "R_=%%R"

:h2r_skipr
if %G% equ 0 set "G_=00" & set "G=000" & goto h2r_skipr
cmd /c exit %G%
set h2=%=ExitCode%
for /f "delims=" %%G in ('echo.%h2:~-2%') do set "G_=%%G"

:h2r_skipr
if %B% equ 0 set "B_=00" & set "B=000" & goto h2r_skipb
cmd /c exit %B%
set h3=%=ExitCode%
for /f "delims=" %%B in ('echo.%h3:~-2%') do set "B_=%%B"
:h2r_skipb
echo.Hex: !R_!!G_!!B_!
echo %ESCchar%[38;2;%R%;%G%;%B%mExample text%escchar%[0;00m
goto exit

:help
echo.
echo Syntax:
echo.
echo HexRGBConvert [rgb ^| hex] [hex ^| r,g,b]
echo.
echo Examples:
echo.
echo HexRGBConvert rgb F4A6C5
echo Will display the RGB of 'F4A6C5'
echo.
echo HexRGBConvert hex 152,85,245
echo Will display the hexadecimal of the RGB value '152,85,245'
echo.
echo Note: The console color printing uses ANSI escape sequences
echo       and may be not compatible with your Windows version.
echo.
echo.
echo Copyright (c) 2020 anic17 Software
goto exit


:exit
endlocal & exit /B %xt%


:missingparam
echo Required parameter missing. See 'HexRGBConvert --help' for help.
endlocal & exit /B 1

:toomanyparam
echo Received too many parameters. See 'HexRGBConvert --help' for help.
endlocal & exit /B 1

:getesc
for /f "delims=/" %%e in ('"prompt /$E/ & for %%e in (1) do rem"') do set "ESCchar=%%e"
goto :EOF

:split_spaces
set "R=%~2"
set "G=%~3"
set "B=%~4"
goto splitted

:split_commas
for /f "tokens=1-3 delims=," %%A in ('echo.%~2') do (
	set "R=%%A"
	set "G=%%B"
	set "B=%%C"
)
goto splitted