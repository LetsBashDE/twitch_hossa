@echo off
rem This little thing must be in the same directory as the powershell script
rem It will execute the Powershellscript for you with the pypass security settings

echo Start elevating as an Administrator
echo This is needed because hotkeys can only send global from an administrative application

rem Unevelevated
if "%1"=="psx" goto psx
powershell.exe -executionpolicy bypass -nologo -noprofile -command "start-process init.cmd -verb runas -argument 'psx' -WorkingDirectory '%~dp0'"
goto end

rem Elevated
:psx
cd "%~dp0"
powershell.exe -executionpolicy bypass -nologo -noprofile -file process.ps1
pause

:end
