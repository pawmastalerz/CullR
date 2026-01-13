@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0.."

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
call flutter pub get
if errorlevel 1 exit /b 1

call flutter build apk --release
if errorlevel 1 exit /b 1

adb -s %DEVICE_ID% install -r build\app\outputs\flutter-apk\app-release.apk
if errorlevel 1 exit /b 1

echo Release APK installed on %DEVICE_ID%.
