@echo off
rem This little thing must be in the same directory as the powershell script
rem It will execute the Powershellscript for you with the pypass security settings

goto normal

rem Unevelevated
if "%1"=="elevated" goto elevated
rem Start elevating as an Administrator
:elevate
powershell.exe -executionpolicy bypass -nologo -noprofile -command "start-process init.cmd -verb runas -argument 'elevated' -WorkingDirectory '%~dp0'"
goto end

rem Elevated
:elevated
cd "%~dp0"
:normal
powershell.exe -executionpolicy bypass -nologo -noprofile -file process.ps1
goto end

:end
