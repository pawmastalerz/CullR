@echo off
setlocal

cd /d "%~dp0.."

call flutter pub get
if errorlevel 1 exit /b 1

call dart format .
if errorlevel 1 exit /b 1

call flutter gen-l10n
if errorlevel 1 exit /b 1

call flutter doctor
if errorlevel 1 exit /b 1

call flutter analyze
if errorlevel 1 exit /b 1

call flutter test
if errorlevel 1 exit /b 1

echo Checks completed successfully.
