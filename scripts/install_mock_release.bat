@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0.."

set "MOCK_GALLERY_LIMIT=200"
set "MANIFEST=android\app\src\main\AndroidManifest.xml"
set "MANIFEST_BACKUP=%TEMP%\cullr_manifest_backup.xml"

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
copy "%MANIFEST%" "%MANIFEST_BACKUP%" >nul
if errorlevel 1 (
  echo Failed to back up AndroidManifest.xml.
  exit /b 1
)
echo Added temporary INTERNET permission to %MANIFEST%.
powershell -NoProfile -Command ^
  "$path = '%MANIFEST%';" ^
  "$line = '<uses-permission android:name=\"android.permission.INTERNET\" />';" ^
  "$content = Get-Content -Raw -Path $path;" ^
  "if ($content -notmatch [regex]::Escape($line)) {" ^
  "  $content = $content -replace '(<manifest[^>]*>)', \"`$1`r`n    $line\";" ^
  "  Set-Content -Path $path -Value $content -NoNewline" ^
  "}"
if errorlevel 1 (
  echo Failed to add INTERNET permission.
  goto :cleanup
)

call flutter pub get
if errorlevel 1 goto :cleanup

call flutter build apk --release --dart-define=MOCK_GALLERY=true --dart-define=MOCK_GALLERY_LIMIT=%MOCK_GALLERY_LIMIT%
if errorlevel 1 goto :cleanup

adb -s %DEVICE_ID% install -r build\app\outputs\flutter-apk\app-release.apk
if errorlevel 1 goto :cleanup

echo Release APK (mock gallery) installed on %DEVICE_ID%.
goto :cleanup

:cleanup
if exist "%MANIFEST_BACKUP%" (
  copy "%MANIFEST_BACKUP%" "%MANIFEST%" >nul
  del "%MANIFEST_BACKUP%" >nul
)
echo Restored original AndroidManifest.xml.
