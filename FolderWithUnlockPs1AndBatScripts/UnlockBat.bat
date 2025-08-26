@echo off
REM — Получаем полный путь к папке, где лежит этот батник
set "SCRIPT_DIR=%~dp0"

REM — Имя вашего PS-скрипта (замените на фактическое имя файла)
set "PS_SCRIPT=UnlockADAccount.ps1"

REM — Запуск PowerShell с обходом политики ExecutionPolicy
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%%PS_SCRIPT%"

pause
