@echo off
rem This little thing must be in the same directory as the powershell script
rem It will execute the Powershellscript for you with the pypass security settings

powershell.exe -executionpolicy bypass -nologo -noprofile -file process.ps1
timeout /t 5
