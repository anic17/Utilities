@echo off
setlocal EnableDelayedExpansion

set curfile=%~0

if "%~1"=="/?" (goto help)
if "%~1"=="-?" (goto help)
if "%~1"=="--?" (goto help)
if /i "%~1"=="-h" (goto help)
if /i "%~1"=="-help" (goto help)
if /i "%~1"=="/help" (goto help)
if /i "%~1"=="--help" (goto help)

if "%~1"=="" goto help
if "%~2"=="" goto error
if "%~3"=="" goto error
if "%~4"=="" goto error
if "%~5"=="" goto error


if "%~7" neq "" (
	if "%~8"=="" goto error
)


if /i "%~1"=="info" (set msgtype=64)
if /i "%~1"=="error" (set msgtype=16)
if /i "%~1"=="question" (set msgtype=32)
if /i "%~1"=="alert" (set msgtype=48)
if /i "%~1"=="nothing" (set msgtype=0)



if "%~2"=="ontop" (set /a msgtype=%msgtype%+4096)
if "%~2"=="normal" (set /a msgtype=%msgtype%+0)


if "%~6"=="" set /a msgtype=%msgtype%+0
if /i "%~6"=="OkCancel" (set /a msgtype=%msgtype%+1)
if /i "%~6"=="YesNo" (set /a msgtype=%msgtype%+4)
if /i "%~6"=="Ok" (set /a msgtype=%msgtype%+0)
if /i "%~6"=="YesNoCancel" (set /a msgtype=%msgtype%+3)
if /i "%~6"=="RetryCancel" (set /a msgtype=%msgtype%+5)
if /i "%~6"=="AbortIgnoreRetry" (set /a msgtype=%msgtype%+2)



set "action=%~8"
if "%action%"=="{RunMsgBox}" (set action=WScript.exe %TMP%\msgbox.vbs)


if /i "%~7"=="" set clickbutton=Ok
if /i "%~7"=="Ok" set clickbutton=Ok
if /i "%~7"=="Yes" set clickbutton=Yes
if /i "%~7"=="No" set clickbutton=No
if /i "%~7"=="Retry" set clickbutton=Retry
if /i "%~7"=="Ignore" set clickbutton=Ignore
if /i "%~7"=="Cancel" set clickbutton=Cancel
if /i "%~7"=="Abort" set clickbutton=Abort


if "%~3"=="wait" goto wait
if "%~3"=="continue" goto continue
goto continue


:wait
echo btn=msgbox("%~4",%msgtype%,"%~5") > "%TMP%\msgbox.vbs"
echo Set objShell = createObject("WScript.Shell") >> "%TMP%\msgbox.vbs"
echo If btn = vb%clickbutton% Then >> "%TMP%\msgbox.vbs"
echo 	objShell.Run "%action%" >> "%TMP%\msgbox.vbs"
echo End If >> "%TMP%\msgbox.vbs"

start /wait WScript.exe "%TMP%\msgbox.vbs"
goto :buttons

:continue

echo btn=msgbox("%~4",%msgtype%,"%~5") > "%TMP%\msgbox.vbs"

::Action
echo Set objShell = createObject("WScript.Shell") >> "%TMP%\msgbox.vbs"
echo If btn = vb%clickbutton% Then >> "%TMP%\msgbox.vbs"
echo 	objShell.Run "%action%" >> "%TMP%\msgbox.vbs"
echo End If >> "%TMP%\msgbox.vbs"

start WScript.exe "%TMP%\msgbox.vbs"
goto :buttons


:error
if exist "%TMP%\msgbox.vbs" del "%TMP%\msgbox.vbs" /Q>nul
if exist "%TMP%\null.vbs" del "%TMP%\null.vbs" /Q>nul
set errorlevel=1
exit /B


:help
echo.
echo Usage:
echo.
echo msgbox [error/question/alert/info/nothing] [ontop/normal] [wait/continue] "Message text" "Title text" 
echo [Ok/OkCancel/YesNo/YesNoCancel/RetryCancel/AbortIgnoreRetry] [Ok/Yes/No/Retry/Ignore/Cancel/Abort]
echo "[command]"
echo.
echo.
echo Examples:
echo.
echo msgbox info ontop continue "Command completed successfully" "Information"
echo Will make an information message box that always will be on top and it won't stop CMD.exe
echo.
echo.
echo msgbox question normal wait "Do you like chips" "Form" YesNo Yes "C:\givechips.bat"
echo Will make a question message box that will wait until the user answers, with the buttons 'Yes' and 'No'
echo and if 'Yes' is clicked it will run the file 'C:\givechips.bat'
echo.
echo.
echo msgbox error normal wait "Error in My Program" "Error!" RetryCancel Retry "C:\WINDOWS\System32\cmd.exe /k echo Test"
echo Will make an error message box that will wait until the user answers, with the buttons 'Retry' and 
echo 'Cancel'. If clicked on 'Retry', it will run the file 'C:\WINDOWS\System32\cmd.exe' with arguments '/k echo Test'
echo To run messagebox another time type in command "{RunMsgBox}"
echo.
echo.
echo.
echo Copyright (c) 2020 anic17 Software
echo.
echo http://github.com/anic17

goto :EOF


:buttons
if exist "%TMP%\msgbox.vbs" del "%TMP%\msgbox.vbs" /Q>nul
if exist "%TMP%\msgbox.vbs" del "%TMP%\null.vbs" /Q>nul
set errorlevel=0
goto :EOF


