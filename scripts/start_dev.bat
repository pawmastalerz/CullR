@echo off
setlocal enabledelayedexpansion

adb start-server >nul 2>&1

for /f "skip=1 tokens=1,2" %%A in ('adb devices') do (
  if "%%B"=="device" (
    set "DEVICE_ID=%%A"
    goto :found
  )
)

echo No connected adb devices found.
exit /b 1

:found
adb -s %DEVICE_ID% shell pm clear com.example.cullr >nul 2>&1
flutter run -d %DEVICE_ID%
