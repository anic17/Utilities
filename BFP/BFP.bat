@echo off
for /f "tokens=2 delims=:" %%A in ('chcp') do (set "codepage=%%A")
chcp 65001 > nul
setlocal EnableDelayedExpansion
cd /d "%~dp0"
set difoutput=0
set seven-zip=0

echo. 1>&2
echo Batch File Packer - BFP 1>&2
echo. 1>&2
echo A tool to pack batch files or create self extracting files 1>&2



if /i "%~1"=="-d" (call :decompress %~2 & endlocal & exit /B 0)

if /i "%~1"=="/?" goto help
if /i "%~1"=="/h" goto help
if /i "%~1"=="-h" goto help
if /i "%~1"=="--help" goto help
if /i "%~1"=="/help" goto help
if /i "%~1"=="-?" goto help
if /i "%~2"=="-o" (
	set difoutput=1
	set output="%~3"
)
set max=0
if /i "%~2"=="-m" (
	set max=1
)
if /i "%~3"=="-m" (
	set max=1
)
if /i "%~4"=="-m" (
	set max=1
)
if /i "%~5"=="-m" (
	set max=1
)
set hash=0

set "argchar=%~2"
set "argchar_2=%argchar:~2%"
set "argchar=%argchar:~0,2%"


if /i "%argchar%"=="-h" (
	set "algorithm_hash=NULL"
	if "%~2"=="" (
		set hash=1
		set algorithm_hash=SHA256
	) else (
		set "algorithm_hash=%argchar_2%"
		if /i "!algorithm_hash!"=="SHA256" set "algorithm_hash=SHA256"
		if /i "!algorithm_hash!"=="SHA384" set "algorithm_hash=SHA384"
		if /i "!algorithm_hash!"=="SHA512" set "algorithm_hash=SHA512"
		if /i "!algorithm_hash!"=="SHA1" set "algorithm_hash=SHA1"
		if /i "!algorithm_hash!"=="MD5" set "algorithm_hash=MD5"
		if /i "!algorithm_hash!"=="MD4" set "algorithm_hash=MD4"
		if /i "!algorithm_hash!"=="MD2" set "algorithm_hash=MD2"
		if "!algorithm_hash!"=="NULL" (echo Invalid hash algorithm & endlocal && exit /B 1)
		set hash=1
		
	)
)




if /i "%~2"=="-7" (
	set seven-zip=1
)
if /i "%~3"=="-7" (
	set seven-zip=1
)
if /i "%~4"=="-7" (
	set seven-zip=1
)
if /i "%~5"=="-7" (
	set seven-zip=1
)
if /i "%~6"=="-7" (
	set seven-zip=1
)
if "%~1"=="" goto help

if not exist "%~1" (
	echo.
	echo BFP Error: Cannot find %~1
	exit /B 1
)
if exist "%~dpn1.bfp.bat" (
	echo BFP Error: "%~n1.bfp.bat" already exists
	exit /B 1
)

set ext_eb64=cab
set "file_create=%~dpnx1"
if exist "%~n1.---" (ren %~n1.--- %~n1.%random:~-1%%random:~-1%%random:~-1%)
if exist "%~n1.bfp.bat" ren %~n1.bfp %~n1.---

set fileext_BFP=%~n1
for %%a in (%1) do (set first_size=%%~za)

set fileext_BFP=%~n1
for %%a in (%1) do (set first_size=%%~za)

if "%max%"=="1" move "%~dpn1.fi2" "%~dpnx1" 2>nul 1>nul
if "%max%"=="1" set "file_create=%~dpnx1"

if "%seven-zip%"=="1" (
	call :7zip_compress
	7z a "%~dpn1.7z" "%file_create%" -mx9 > nul
) else (
	makecab "%file_create%" "%~dpn1.cab" > nul
)


echo Const fsDoOverwrite     = true > "%TMP%\BFP.vbs"
echo Const fsAsASCII         = false >> "%TMP%\BFP.vbs"
echo Const adTypeBinary      = 1 >> "%TMP%\BFP.vbs"
echo Set objStream = CreateObject("ADODB.Stream") >> "%TMP%\BFP.vbs"
echo objStream.Type = adTypeBinary >> "%TMP%\BFP.vbs"
echo objStream.Open() >> "%TMP%\BFP.vbs"
echo objStream.LoadFromFile("%~dpn1.%ext_eb64%") >> "%TMP%\BFP.vbs"
echo Set objXML = CreateObject("MSXml2.DOMDocument") >> "%TMP%\BFP.vbs"
echo Set objDocElem = objXML.createElement("Base64Data") >> "%TMP%\BFP.vbs"
echo objDocElem.dataType = "bin.base64" >> "%TMP%\BFP.vbs"
echo objDocElem.nodeTypedValue = objStream.Read() >> "%TMP%\BFP.vbs"
echo Set objFSO = CreateObject("Scripting.FileSystemObject") >> "%TMP%\BFP.vbs"

echo Set objFileOut = objFSO.CreateTextFile("%~dpn1.b64", fsDoOverwrite, fsAsASCII) >> "%TMP%\BFP.vbs"
echo objFileOut.Write objDocElem.text >> "%TMP%\BFP.vbs"
echo objFileOut.Close() >> "%TMP%\BFP.vbs"
if "%max%"=="1" for %%A in ("%~dpn1.fi1" "%~dpn1.fi2") do if exist %%A del %%A /q 2>nul 1>nul



CScript.exe //nologo //B "%TMP%\BFP.vbs"

ren "%~dpn1.b64" "%~n1.bfp" 2>nul 1>nul


echo :BFP>>"%~dpn1.bfp.bat"
echo @echo off>>"%~dpn1.bfp.bat"
echo for %%%%B in ^(>>"%~dpn1.bfp.bat"



for /f "usebackq delims=" %%T in ("%~dpn1.bfp") do (echo;%%T>> "%~dpn1.bfp.bat")
echo.)do echo:%%%%B^>^>x>> "%~dpn1.bfp.bat"


echo certutil -f -decode "%%CD%%\x" "%%CD%%\x.bfp"^>nul>> "%~dpn1.bfp.bat"
echo del x /q^>nul>> "%~dpn1.bfp.bat"


if "%seven-zip%"=="1" (
	echo %7z_command% e -o"%%TMP%%" -y "%%CD%%\x.bfp" 2^>nul 1^>nul>> "%~dpn1.bfp.bat"
) else (
	echo expand x.bfp "%%TMP%%\%%~n0%~x1"^>nul>> "%~dpn1.bfp.bat"
)
echo del x.bfp /q^>nul>> "%~dpn1.bfp.bat"
if "%hash%"=="1" goto hash
:next_hash


rem echo cd /d "%%CD%%">> "%~n1.bfp.bat"
echo "%%TMP%%\%%~n0%~x1" %%*>> "%~dpn1.bfp.bat"



for %%A in ("%~dpn1.bfp.bat") do (set final_size=%%~zA)

echo wscript.echo Round(((%final_size%*100)/%first_size%),2) > "%TMP%\bfp_ratio.vbs"


for /f "delims=" %%a in ('cscript.exe //nologo "%TMP%\bfp_ratio.vbs"') do (set ratio=%%a)

echo File compression: %first_size% bytes ——^> %final_size% bytes [Compression ratio: %ratio%%%]
if "%difoutput%"=="1" move "%fileext_BFP%.bfp.bat" "%~3" 2>&1>nul

if exist "%~dpn1.%ext_eb64%" del "%~dpn1.%ext_eb64%" /q 2> nul 1>nul
if exist "%TMP%\BFP.vbs" del "%TMP%\BFP.vbs" /q 2> nul 1>nul
if exist "%~dpn1.tmp" del "%~dpn1.tmp" /q 2> nul 1>nul
if exist "%~dpn1.bfp" del "%~dpn1.bfp" /q 2> nul 1>nul
chcp %codepage% 2>&1>nul
endlocal
exit /B 0

:help
echo.
echo Syntax:
echo.
echo BFP -?
echo Shows this message
echo.
echo BFP [file]
echo Creates a self extracting file (No data loss)
echo.
echo BFP [file] -o [output]
echo Creates a self extracting file with a different output name
echo.
echo BFP -d [file]
echo Decompresses the file, only if packed by BFP
echo.
echo BFP [file] -h[algorithm]
echo Creates a self extracting file with hash verification (Default is SHA256)
echo.
echo BFP [file] -m
echo Creates a self extracting file using max compression possible, modifying the compressed file.
echo This option will cause comments data loss on batch files, achieving a better compression.
echo.
echo BFP [file] -7
echo Creates a self extracting file using 7-Zip. 
echo Requires 7-Zip on the computer that is created and the computer that will be extracted.
echo For more information, visit https://7-zip.org
echo.
echo Examples:
echo.
echo BFP MyFile.bat -o MyFile2.bat
echo Packs MyFile.bat and it saves to MyFile2.bat
echo.
echo BFP -d MyFile2.bat
echo Will decompress MyFile2.bat without data loss
echo.
echo BFP MyFile.bat -m
echo Will create the possible smallest file for the program, but with some comments loss
echo.
echo BFP MyFile.bat -7
echo Will create a 7-Zip self extracting file
echo.
echo Parameters can be combined, so you could also use the different parameters in a single file,
echo except the -d
echo.
echo Note: Batch File Packer is only recommended for files between 3 and 500 kB
echo       Photos, videos and executables may fail. For executables, use UPX!
echo.
echo.
echo Copyright (c) 2020 anic17 Software
endlocal
chcp %codepage% 2>&1>nul
exit /B 0

:decompress
set "filedecompress=%~1"
if not exist "%~1" (
	echo.
	echo BFP Error: Cannot find '%~1'
	exit /B 1
)

if defined __magic_number__ set __magic_number__=
for /f "usebackq delims=" %%A in ("%~1") do (if not defined __magic_number__ set __magic_number__=%%A& goto :magicnum)
:magicnum
if not "%__magic_number__%"==":BFP" (
	echo.
	echo BFP Error: '%~1' not packed by BFP
	endlocal
	exit /B 1
)


set "curdir=%CD%"
cd /d "%~dp1"
for %%a in (%~nx1) do (set size_before=%%~za)
cd /d "%curdir%"

findstr /v /c:"%%*" "%~1" > "%~nx1.unp.bat"
if exist "%~nx1.unp.bat" (
	if exist "%~1" copy "%~1" "%TMP%\%~nx1_original%~x1%" 2> nul 1>nul
) else (
	echo.
	echo BFP Error: Error while unpacking '%~1'
	endlocal
	exit /B 1
)
if not exist "%TMP%\*.bat" goto before_wd

dir /B "%TMP%\*.bat" > "%TMP%\bfp_batch.tmp"
for /f "usebackq delims=" %%a in ("%TMP%\bfp_batch.tmp") do move /y "%TMP%\%%a" "%TMP%\_bfp_files" 2> nul 1>nul

:before_wd
start /min /wait cmd.exe /c "%filedecompress%.unp.bat"
if exist "%~nx1.unp.bat" del "%~nx1.unp.bat" /q > nul
:while_decompress
if exist "%TMP%\*.bat" (goto next_while_d) else (timeout /t 1 > nul)
goto while_decompress

:next_while_d
if not exist "%TMP%\_bfp_files" (md "%TMP%\_bfp_files")


xcopy "%TMP%\*.bat" "%CD%\%~1" /y 2>nul 1>nul

cd /d "%~dp1"
for %%a in (%~nx1) do (set size_after=%%~za)
cd /d "%curdir%"

echo.
echo Decompression: %size_before% ——^> %size_after% bytes
endlocal
exit /B 0

:compress_max_replace

echo strFileName = Wscript.Arguments(0) > "__Replace__.vbs"
echo strOldText = Wscript.Arguments(1) >> "__Replace__.vbs"
echo strNewText = Wscript.Arguments(2) >> "__Replace__.vbs"

echo Set objFSO = CreateObject("Scripting.FileSystemObject") >> "__Replace__.vbs"
echo Set objFile = objFSO.OpenTextFile(strFileName, 1) >> "__Replace__.vbs"
echo strText = objFile.ReadAll >> "__Replace__.vbs"
echo objFile.Close >> "__Replace__.vbs"

echo strNewText = Replace(strText, strOldText, strNewText) >> "__Replace__.vbs"
echo Set objFile = objFSO.OpenTextFile(strFileName, 2) >> "__Replace__.vbs"
echo objFile.Write strNewText >> "__Replace__.vbs"
echo objFile.Close >> "__Replace__.vbs"
goto :EOF

:7zip_compress
if not exist "7z.exe" if not exist "%ProgramFiles%\7-Zip\7z.exe" (
	echo Could not find 7-Zip
	goto exit
)
set ext_eb64=7z
if exist "%ProgramFiles%\7-Zip\7z.exe" set 7z_command="%ProgramFiles%\7-Zip\7z.exe"
if exist "7z.exe" set "7z_command=7z.exe"
exit /B

:exit
endlocal
exit /B %errorlevel%

:hash
for /f "delims=" %%A in ('certutil -hashfile "%~1" !algorithm_hash! ^| findstr /ivc:h') do set "hashfile=%%A"
echo.for /f "delims=" %%%%B in ('certutil -hashfile "%%TMP%%\%%~n0%~x1" !algorithm_hash! ^^^^^| findstr /ivc:h') do if /i "%%%%B" neq "!hashfile!" echo Corrupted file ^& exit /B>> "%~n1.bfp.bat"
goto next_hash