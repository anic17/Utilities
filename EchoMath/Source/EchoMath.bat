@echo off
if /i "%~1"=="--help" goto help
if /i "%~1"=="/?" goto help
if /i "%~1"=="-h" goto help

setlocal EnableDelayedExpansion

if defined __operation__ set __operation__=
if defined piped_operation set piped_operation=

set /p "piped_operation="
if "%piped_operation%"=="" (echo Required parameter or pipe missing & endlocal & exit /B)
for /f "tokens=1 delims=()1234567890x+-*/%% " %%A in ("%piped_operation%") do (echo Not an operation & exit /B)

set "piped_operation=%piped_operation:x=*%"
set /a "__operation__=%piped_operation%"
echo.!__operation__!

endlocal & exit /B %errorlevel%

:help
echo.
echo Syntax:
echo.
echo echo operation ^| %~n0
echo %~n0 --help
echo.
echo Examples:
echo.
echo echo (2+4)*5 ^| %~n0
echo Will return 30: (2 + 4) = 6 and 6 * 5 = 30
echo.
echo echo 1648/16 | %~n0
echo Will return 103: 1 648 / 16 = 103
echo.
echo %~n0 --help
echo Shows this help
echo.
echo.
echo Copyright (c) 2020 anic17 Software
endlocal & exit /B %errorlevel%