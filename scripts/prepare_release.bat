@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0.."

set "PUBSPEC=pubspec.yaml"

if not exist "%PUBSPEC%" (
  echo pubspec.yaml not found
  exit /b 1
)

for /f "tokens=2 delims= " %%A in ('findstr /r /c:"^version:" "%PUBSPEC%"') do (
  set "OLD_VERSION=%%A"
)

for /f "tokens=1,2 delims=+" %%A in ("!OLD_VERSION!") do (
  set "SEMVER=%%A"
  set "VERSION_CODE=%%B"
)

for /f "tokens=1,2,3 delims=." %%A in ("!SEMVER!") do (
  set "X=%%A"
  set "Y=%%B"
  set "Z=%%C"
)

echo ----------------------------------------
echo Current version in pubspec.yaml:
echo   !X!.!Y!.!Z!+!VERSION_CODE!
echo ----------------------------------------
echo.
echo Choose version bump:
echo [1] Major (X)
echo [2] Minor (Y)
echo [3] Patch (Z)
echo.

set /p CHOICE=Enter choice (1/2/3): 

if "!CHOICE!"=="1" (
  set /a X+=1
  set "Y=0"
  set "Z=0"
) else if "!CHOICE!"=="2" (
  set /a Y+=1
  set "Z=0"
) else if "!CHOICE!"=="3" (
  set /a Z+=1
) else (
  echo Invalid choice
  exit /b 1
)

set /a VERSION_CODE+=1
set "NEW_VERSION=!X!.!Y!.!Z!+!VERSION_CODE!"

powershell -NoProfile -Command "(Get-Content '%PUBSPEC%' -Raw) -replace '(?m)^version:.*$','version: !NEW_VERSION!' | Set-Content '%PUBSPEC%' -Encoding utf8"

if errorlevel 1 (
  echo Failed to update version
  exit /b 1
)

for /f "tokens=2 delims= " %%A in ('findstr /r /c:"^version:" "%PUBSPEC%"') do (
  set "AFTER_VERSION=%%A"
)

echo.
echo Version updated:
echo   !OLD_VERSION!  -^>  !AFTER_VERSION!
echo.

call flutter clean || exit /b 1
call flutter pub get || exit /b 1
call flutter build appbundle --release || exit /b 1

echo.
echo Release prepared successfully
echo AAB:
echo build\app\outputs\bundle\release\app-release.aab
