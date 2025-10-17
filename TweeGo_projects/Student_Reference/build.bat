@echo off
setlocal ENABLEDELAYEDEXPANSION

:: --------- CONFIG (edit if needed) ----------
set "TWEEGO=C:\Tools\tweego\tweego.exe"
set "FORMAT=sugarcube-2-37-3"
:: --------------------------------------------

:: Resolve paths RELATIVE to this script, not the working dir
set "PROJECT=%~dp0"
set "SRC=%PROJECT%src"
set "DIST=%PROJECT%dist"
set "ASSETS=%PROJECT%assets"

echo === Tweego build starting ===
echo Project  : %PROJECT%
echo Tweego   : %TWEEGO%
echo Source   : %SRC%
echo Output   : %DIST%\index.html
echo FormatId : %FORMAT%
echo.

:: Sanity checks
if not exist "%TWEEGO%" (
  echo ERROR: Tweego not found at "%TWEEGO%".
  echo Edit TWEEGO= in build.bat and try again.
  pause
  exit /b 1
)
if not exist "%SRC%" (
  echo ERROR: src folder not found at "%SRC%".
  pause
  exit /b 1
)

:: Clean dist so there’s never a stale file
echo Cleaning dist...
if exist "%DIST%" rmdir /S /Q "%DIST%"
mkdir "%DIST%" >nul 2>&1

:: Compile
echo Compiling with Tweego...
"%TWEEGO%" -o "%DIST%\index.html" --format "%FORMAT%" --log-files "%SRC%"
if errorlevel 1 (
  echo Build failed. See Tweego errors above.
  pause
  exit /b 1
)

:: Copy assets (optional)
if exist "%ASSETS%" (
  echo Copying assets...
  xcopy /E /I /Y "%ASSETS%" "%DIST%\assets" >nul
)

:: Show what we actually wrote
for %%F in ("%DIST%\index.html") do (
  echo Built: %%~fF
  echo Time : %%~tF
  echo Size : %%~zF bytes
)

:: Open the LOCAL file (not a GitHub URL)
echo Opening local build...
start "" "%DIST%\index.html"

echo Done.
endlocal
