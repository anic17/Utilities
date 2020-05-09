@echo off
chcp 65001 > nul
cd /d "%~dp0"
setlocal EnableDelayedExpansion
if not "%~2"=="-nobanner" (
	echo.
	echo Batch File Packer - BFP
	echo.
	echo A little tool to create packed batch files or self extracting files

	echo.
	echo Copyright ^(c^) 2020 anic17 Software
)
if /i "%~1"=="/?" goto help
if /i "%~1"=="/h" goto help
if /i "%~1"=="-h" goto help
if /i "%~1"=="--help" goto help
if /i "%~1"=="/help" goto help
if /i "%~1"=="-?" goto help


if "%~1"=="" endlocal & exit /B
if not exist "%~1" (
	echo.
	echo BFC Error: Cannot find %~1
	exit /B
)

if exist "%~n1.---" (ren %~n1.--- %~n1.%random:~-1%%random:~-1%%random:~-1%)
if exist "%~n1.bfp" ren %~n1.bfp %~n1.---

set fileext_BFP=%~n1
for %%a in (%1) do (set first_size=%%~za)

findstr /vc:"::" "%~1" > "%~n1.tmp"

makecab "%~n1.tmp" "%~dpn1.cab" > nul
echo Const fsDoOverwrite     = true > "%CD%\BFC.vbs"
echo Const fsAsASCII         = false >> "%CD%\BFC.vbs"
echo Const adTypeBinary      = 1 >> "%CD%\BFC.vbs"
echo Set objStream = CreateObject("ADODB.Stream") >> "%CD%\BFC.vbs"
echo objStream.Type = adTypeBinary >> "%CD%\BFC.vbs"
echo objStream.Open() >> "%CD%\BFC.vbs"
echo objStream.LoadFromFile("%~dpn1.cab") >> "%CD%\BFC.vbs"
echo Set objXML = CreateObject("MSXml2.DOMDocument") >> "%CD%\BFC.vbs"
echo Set objDocElem = objXML.createElement("Base64Data") >> "%CD%\BFC.vbs"
echo objDocElem.dataType = "bin.base64" >> "%CD%\BFC.vbs"
echo objDocElem.nodeTypedValue = objStream.Read() >> "%CD%\BFC.vbs"
echo Set objFSO = CreateObject("Scripting.FileSystemObject") >> "%CD%\BFC.vbs"
echo Set objFileOut = objFSO.CreateTextFile("%~dpn1.b64", fsDoOverwrite, fsAsASCII) >> "%CD%\BFC.vbs"
echo objFileOut.Write objDocElem.text >> "%CD%\BFC.vbs"
echo objFileOut.Close() >> "%CD%\BFC.vbs"

start /wait WScript.exe "%CD%\BFC.vbs"

ren "%~n1.b64" "%~n1.bfp"

echo @echo off >>%~n1.bfp.bat
for /f "delims=" %%T in (%~n1.bfp) do (echo echo %%T^>^> x.b64>> %~n1.bfp.bat)

echo echo Const foForReading          = 1 ^> BFC.vbs>> %~n1.bfp.bat
echo echo Const foAsASCII             = 0 ^>^> BFC.vbs>> %~n1.bfp.bat
echo echo Const adSaveCreateOverWrite = 2 ^>^> BFC.vbs>> %~n1.bfp.bat
echo echo Const adTypeBinary          = 1 ^>^> BFC.vbs>> %~n1.bfp.bat
echo echo Set objFSO = createObject("Scripting.FileSystemObject") ^>^> BFC.vbs >> %~n1.bfp.bat
echo echo Set objFileIn   = objFSO.GetFile("%%CD%%\x.b64") ^>^> BFC.vbs >> %~n1.bfp.bat
echo echo Set objStreamIn = objFileIn.OpenAsTextStream(foForReading, foAsASCII)^>^> BFC.vbs>> %~n1.bfp.bat
echo echo Set objXML = CreateObject("MSXml2.DOMDocument") ^>^> BFC.vbs>> %~n1.bfp.bat
echo echo Set objDocElem = objXML.createElement("Base64Data") ^>^> BFC.vbs>> %~n1.bfp.bat
echo echo objDocElem.DataType = "bin.base64" ^>^> BFC.vbs>> %~n1.bfp.bat
echo echo objDocElem.text = objStreamIn.ReadAll() ^>^> BFC.vbs>> %~n1.bfp.bat
echo echo Set objStream = CreateObject("ADODB.Stream") ^>^> BFC.vbs>> %~n1.bfp.bat
echo echo objStream.Type = adTypeBinary ^>^> BFC.vbs>> %~n1.bfp.bat
echo echo objStream.Open() ^>^> BFC.vbs>> %~n1.bfp.bat
echo echo objStream.Write objDocElem.NodeTypedValue ^>^> BFC.vbs>> %~n1.bfp.bat
echo echo objStream.SaveToFile "%%CD%%\x.bfp", adSaveCreateOverWrite ^>^> BFC.vbs>> %~n1.bfp.bat
echo start /wait WScript.exe "%%CD%%\BFC.vbs" >> %~n1.bfp.bat
echo del BFC.vbs /q ^>nul ^& del x.b64 /q ^>nul >> %~n1.bfp.bat
echo expand x.bfp "%TMP%\%~nx1" ^>nul >> %~n1.bfp.bat
echo del x.bfp /q ^>nul ^& set c_=%%~dp0 >> %~n1.bfp.bat
echo cmd /c "%TMP%\%~nx1" %%*>> %~n1.bfp.bat
echo cd /d "%%c_%%" ^& exit /B>> %~n1.bfp.bat



for %%A in (%fileext_BFP%.bfp.bat) do (set final_size=%%~zA)
set /a ratio=(%final_size%*100)/%first_size%
echo File compression: %first_size% bytes ——^> %final_size% bytes [Compression ratio: %ratio%%%]

if exist "%~n1.cab" del "%~n1.cab" /q > nul
if exist "%CD%\BFC.vbs" del "%CD%\BFC.vbs" /q > nul
if exist "%~n1.tmp" del "%~n1.tmp" /q > nul
if exist "%~n1.bfp" del "%~n1.bfp" /q > nul

endlocal
exit /B

:help
echo.
echo Syntax:
echo.
echo BFP /?
echo Shows this message
echo.
echo BFP [file]
echo Creates a self extracting file (No data loss)
echo.
echo BFP [file] -nobanner
echo Creates a self extracting file within the first message
echo.
echo Note: Batch File Packer is only recommended for files between 5 and 600 kB
echo.
echo.
echo Copyright (c) 2020 anic17 Software
endlocal
exit /B
