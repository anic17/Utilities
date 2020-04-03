@echo off

::Program to create custom messageboxes
::Original source code:
::
::Copyright (c) 2020 anic17 software


::Set current file to variable 'curfile'
set curfile=%~0



::Check if first parameter is help and then show help
if "%~1"=="" goto help
if "%~1"=="/?" (goto help)
if "%~1"=="-?" (goto help)
if "%~1"=="--?" (goto help)
if /i "%~1"=="-h" (goto help)
if /i "%~1"=="-help" (goto help)
if /i "%~1"=="/help" (goto help)
if /i "%~1"=="--help" (goto help)

::Check what type of messagebox and then add the values to VBScript to the variable %MsgType%
if /i "%~1"=="info" (set msgtype=64)
if /i "%~1"=="error" (set msgtype=16)
if /i "%~1"=="question" (set msgtype=32)
if /i "%~1"=="alert" (set msgtype=48)
if /i "%~1"=="nothing" (set msgtype=0)


::Check if command syntax is correct (All the 5 first parameters must be entered)
if "%~2"=="" goto error
if "%~3"=="" goto error
if "%~4"=="" goto error
if "%~5"=="" goto error

::Check if buttons have an action
if "%~7" neq "" (
	if "%~8"=="" goto error
)


::Check messagebox if it will be on top or not and then add the values to VBScript to the variable %MsgType%
if "%~2"=="ontop" (set /a msgtype=%msgtype%+4096)
if "%~2"=="normal" (set /a msgtype=%msgtype%+0)



::Check the buttons that have been choosed and then add the values to VBScript to the variable %MsgType%
if "%~6"=="" set /a msgtype=%msgtype%+0
if /i "%~6"=="OkCancel" (set /a msgtype=%msgtype%+1)
if /i "%~6"=="YesNo" (set /a msgtype=%msgtype%+4)
if /i "%~6"=="Ok" (set /a msgtype=%msgtype%+0)
if /i "%~6"=="YesNoCancel" (set /a msgtype=%msgtype%+3)
if /i "%~6"=="RetryCancel" (set /a msgtype=%msgtype%+5)
if /i "%~6"=="AbortIgnoreRetry" (set /a msgtype=%msgtype%+2)


::Action to perform when a specific button is clicked
set "action=%~8"

::If the action is {RunMsgBox} run message box again
if "%action%"=="{RunMsgBox}" (set action=WScript.exe %TMP%\msgbox.vbs)



::Check the button that has been choosed for the action and set 'clickbutton' variable to the seventh argument (%7)
if /i "%~7"=="" set clickbutton=Ok
if /i "%~7"=="Ok" set clickbutton=Ok
if /i "%~7"=="Yes" set clickbutton=Yes
if /i "%~7"=="No" set clickbutton=No
if /i "%~7"=="Retry" set clickbutton=Retry
if /i "%~7"=="Ignore" set clickbutton=Ignore
if /i "%~7"=="Cancel" set clickbutton=Cancel
if /i "%~7"=="Abort" set clickbutton=Abort


::Check if the message box will wait before CMD.exe ends or not. Goto a different label in diffent cases:
:: :wait for wait and :continue for continue
:: 
::Default value is Continue

if "%~3"=="wait" goto wait
if "%~3"=="continue" goto continue
goto continue


:wait
::Create the message box with all the values that you have entered, pausing console (CMD.exe)
echo btn=msgbox("%~4",%msgtype%,"%~5") > "%TMP%\msgbox.vbs"
echo Set objShell = createObject("WScript.Shell") >> "%TMP%\msgbox.vbs"
echo If btn = vb%clickbutton% Then >> "%TMP%\msgbox.vbs"
echo 	objShell.Run "%action%" >> "%TMP%\msgbox.vbs"
echo End If >> "%TMP%\msgbox.vbs"

start /wait WScript.exe "%TMP%\msgbox.vbs"
goto :end



:continue
::Create the message box with all the values that you have entered, without pausing console (CMD.exe)


echo btn=msgbox("%~4",%msgtype%,"%~5") > "%TMP%\msgbox.vbs"

::Action
echo Set objShell = createObject("WScript.Shell") >> "%TMP%\msgbox.vbs"
echo If btn = vb%clickbutton% Then >> "%TMP%\msgbox.vbs"
echo 	objShell.Run "%action%" >> "%TMP%\msgbox.vbs"
echo End If >> "%TMP%\msgbox.vbs"

start WScript.exe "%TMP%\msgbox.vbs"
goto end


:error
::If an error is found, set errorlevel to 1



if exist "%TMP%\msgbox.vbs" del "%TMP%\msgbox.vbs" /Q>nul
if exist "%TMP%\null.vbs" del "%TMP%\null.vbs" /Q>nul
set errorlevel=1
goto :EOF


:help
::Display help

echo.
echo Usage:
echo.
echo msgbox [error/question/alert/info/nothing] [ontop/normal] [wait/continue] "Message text" "Title text" 
echo [Ok/OkCancel/YesNo/YesNoCancel/RetryCancel/AbortIgnoreRetry] [Ok/Yes/No/Retry/Ignore/Cancel/Abort]
echo "[command]"
echo.
echo Arguments:
echo The first argument will determine the icon of the message box. The second argument will determine if the 
echo message box will be on top or not. The third argument will determine if CMD.exe will wait before having a response
echo of the user. The fourth argument is the message box text, and the fifth the message box title. The sixth argument
echo is the buttons that will be displayed on message box. The seventh argument is the button that will be clicked to
echo perform an action, that is the eighth argument.
echo.
echo Litterally will be:
echo msgbox [icon] [ontop or not] [pause cmd] "[Text]" "[Title]" [Buttons] [Action when a button is clicked] "[Command when
echo the button in seventh argument is clicked]"
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


:end
set errorlevel=0
goto :EOF


