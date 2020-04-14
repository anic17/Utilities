@echo off
set current_dir_playsound=%cd%
if "%~1"=="" goto help
if /i "%~1"=="/help" goto help
if /i "%~1"=="-?" goto help
if /i "%~1"=="/?" goto help
if /i "%~1"=="-h" goto help
if /i "%~1"=="-help" goto help
if /i "%~1"=="--help" goto help
if /i "%~1"=="/h" goto help
if /i "%~1"=="?" goto help
if /i "%~1"=="help" goto help

cd /d "%tmp%"
if "%~2"=="wait" (set wait_playsound=1)
if "%~2"=="continue" (set wait_playsound=0)

echo Set oPlayer = CreateObject("WMPlayer.OCX") > PLAYSOUND.vbs
echo oPlayer.URL = "%~1" >> PLAYSOUND.vbs
echo oPlayer.controls.play  >> PLAYSOUND.vbs
echo While oPlayer.playState ^<^> 1 >> PLAYSOUND.vbs
echo   WScript.Sleep 100 >> PLAYSOUND.vbs
echo Wend >> PLAYSOUND.vbs
echo oPlayer.Close >> PLAYSOUND.vbs
echo WScript.Quit >> PLAYSOUND.vbs

if "%wait_playsound%"=="1" (start /wait WScript.exe "%CD%\PLAYSOUND.vbs") else (start WScript.exe "%CD%\PLAYSOUND.vbs")
:end
if "%wait_playsound%"=="1" if exist "%TMP%\PLAYSOUND.vbs" del "%TMP%\PLAYSOUND.vbs" /q /f>nul
set wait=
cd /d "%current_dir_playsound%"
set current_dir_playsound=
goto :EOF

:help
echo.
echo Syntax:
echo.
echo PLAYSOUND "[full path of sound]" [wait ^| continue]
echo.
echo.
echo Examples:
echo.
echo PLAYSOUND "C:\Music\My Sound.mp3" wait
echo Will play the sound "C:\Music\My Sound.mp3" and will wait until the sound ends playing
echo.
echo PLAYSOUND "D:\Error.mp3" continue
echo.
echo Will play the sound D:\Error.mp3
echo.
echo.
echo Copyright (c) 2020 anic17 Software
echo.
goto :EOF




