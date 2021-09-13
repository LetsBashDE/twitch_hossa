@echo off
rem This little thing must be in the same directory as the powershell script
rem It will execute the Powershellscript for you with the pypass security settings

rem goto execute

if "%1"=="elevated" goto execute
echo Start elevating as an Administrator
powershell.exe -executionpolicy bypass -nologo -noprofile -command "start-process init.cmd -verb runas -argument 'elevated' -WorkingDirectory '%~dp0'"
goto end

:execute
cd "%~dp0"
powershell.exe -executionpolicy bypass -nologo -noprofile -file process.ps1
goto end

:end
