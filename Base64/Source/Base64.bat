@echo off
setlocal EnableDelayedExpansion
if /i "%~1"=="" goto help
if /i "%~1"=="-h" goto help
if /i "%~1"=="-?" goto help
if /i "%~1"=="/?" goto help
if /i "%~1"=="--help" goto help
if /i "%~1"=="/help" goto help
if /i "%~1"=="-help" goto help
if not exist "%~2" goto nosuch
if /i "%~1"=="-e" goto encode
if /i "%~1"=="-d" goto decode

echo.
echo Invalid switch
endlocal
exit /B 3
:encode
echo Set objStream = CreateObject("ADODB.Stream") >"%TMP%\b64enc.vbs"
echo objStream.Type = 1 >>"%TMP%\b64enc.vbs"
echo objStream.Open() >>"%TMP%\b64enc.vbs"
echo objStream.LoadFromFile("%~2") >>"%TMP%\b64enc.vbs"
echo Set objXML = CreateObject("MSXml2.DOMDocument") >>"%TMP%\b64enc.vbs"
echo Set objDocElem = objXML.createElement("Base64Data") >>"%TMP%\b64enc.vbs"
echo objDocElem.dataType = "bin.base64" >>"%TMP%\b64enc.vbs"
echo objDocElem.nodeTypedValue = objStream.Read() >>"%TMP%\b64enc.vbs"
echo Set objFSO = CreateObject("Scripting.FileSystemObject") >>"%TMP%\b64enc.vbs"
echo Set objFileOut = objFSO.CreateTextFile("%~dpnx2.base64", true, false) >>"%TMP%\b64enc.vbs"
echo objFileOut.Write objDocElem.text >>"%TMP%\b64enc.vbs"
echo objFileOut.Close() >>"%TMP%\b64enc.vbs"
if not exist "%TMP%\b64enc.vbs" goto err
cscript.exe //nologo //b "%TMP%\b64enc.vbs"
goto success

:decode
echo Set FSO = createObject("Scripting.FileSystemObject") >>"%TMP%\b64dec.vbs"
echo Set objFileIn = FSO.GetFile("%~2") >>"%TMP%\b64dec.vbs"
echo Set ostIn = objFileIn.OpenAsTextStream(1, 0) >>"%TMP%\b64dec.vbs"
echo Set objXML = CreateObject("MSXml2.DOMDocument") >>"%TMP%\b64dec.vbs"
echo Set objDocElem = objXML.createElement("Base64Data") >>"%TMP%\b64dec.vbs"
echo objDocElem.DataType = "bin.base64" >>"%TMP%\b64dec.vbs"
echo objDocElem.text = ostIn.ReadAll() >>"%TMP%\b64dec.vbs"
echo Set ost = CreateObject("ADODB.Stream") >>"%TMP%\b64dec.vbs"
echo ost.Type = 1 >>"%TMP%\b64dec.vbs"
echo ost.Open() >>"%TMP%\b64dec.vbs"
echo ost.Write objDocElem.NodeTypedValue >>"%TMP%\b64dec.vbs"
echo ost.SaveToFile "%~dpn2", 2 >>"%TMP%\b64dec.vbs"
if not exist "%TMP%\b64dec.vbs" goto err
cscript.exe //nologo //b "%TMP%\b64dec.vbs"
:nosuch
echo Base64 Error: No such file or directory
exit /B 1

:err
echo Base64 Internal error
endlocal
exit /b 2

:success
for %%a in ("%TMP%\b64enc.vbs" "%TMP%\b64dec.vbs") do (if exist %%a del %%a /q 2>nul 1>nul)
exit /B 0

:help
echo.
echo Syntax:
echo.
echo Base64 [-e ^| -d] [file]
echo.
echo Examples:
echo.
echo Base64 -e file.txt
echo Will encode using base64 the file called 'file.txt'
echo.
echo Base64 -e file2.txt
echo Will decode using base64 the encoded file called 'file2.txt'
echo.
echo.
echo Copyright (c) 2020 anic17 Software
goto success