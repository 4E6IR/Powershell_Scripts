@echo off
setlocal
set "source1=C:\Users\%username%\Desktop"
set "source2=C:\Users\%username%\Documents"
set "source3=C:\Users\%username%\Downloads"
set "serverPath=\\test-dc-01\DataForArchivation\%username%"
if not exist "%serverPath%" (
    mkdir "%serverPath%"
)
robocopy "%source1%" "%serverPath%\Desktop" /MIR /Z /J /R:3 /W:3
robocopy "%source2%" "%serverPath%\Documents" /XJ /MIR /Z /J /R:3 /W:3
robocopy "%source3%" "%serverPath%\Downloads" /MIR /Z /J /R:3 /W:3
endlocal

#