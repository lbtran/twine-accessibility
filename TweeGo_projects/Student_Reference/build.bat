@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem === Paths ===
set "PROJECT=%~dp0"
set "SRC=%PROJECT%src"
set "DIST=%PROJECT%dist"
set "FORMATS=%PROJECT%storyformats"
set "FORMAT_ID=sugarcube-2-37-3"

rem Try Tweego in C:\Tools\tweego\tweego.exe first; else use PATH
set "TWEEGO=C:\Tools\tweego\tweego.exe"
if not exist "%TWEEGO%" set "TWEEGO=tweego"

if not exist "%DIST%" mkdir "%DIST%"

echo.
echo === Tweego build starting ===
echo Project  : %PROJECT%
echo Tweego   : %TWEEGO%
echo Source   : %SRC%
echo Output   : %DIST%\index.html
echo FormatId : %FORMAT_ID%
echo.

rem --- Attempt 1: per-project formats via --format-path (new Tweego) ---
if exist "%FORMATS%" (
  echo Trying: --format-path "%FORMATS%"
  "%TWEEGO%" -o "%DIST%\index.html" --format-path "%FORMATS%" --format %FORMAT_ID% "%SRC%"
  if %ERRORLEVEL% EQU 0 goto :copy_assets

  rem --- Attempt 2: per-project formats via --format-dir (some 2.x builds) ---
  echo --format-path not supported; trying: --format-dir "%FORMATS%"
  "%TWEEGO%" -o "%DIST%\index.html" --format-dir "%FORMATS%" --format %FORMAT_ID% "%SRC%"
  if %ERRORLEVEL% EQU 0 goto :copy_assets

  echo Per-project format flags not supported by this Tweego. Falling back to global formats...
) else (
  echo No local storyformats folder found at "%FORMATS%".
  echo Falling back to global formats...
)

rem --- Attempt 3: global formats with specific version id ---
echo Trying global formats with --format %FORMAT_ID% ...
"%TWEEGO%" -o "%DIST%\index.html" --format %FORMAT_ID% "%SRC%"
if %ERRORLEVEL% EQU 0 goto :copy_assets

rem --- Attempt 4: global formats with generic "sugarcube-2" id ---
echo "%FORMAT_ID%" not available globally. Trying: --format sugarcube-2 ...
"%TWEEGO%" -o "%DIST%\index.html" --format sugarcube-2 "%SRC%"
if %ERRORLEVEL% NEQ 0 (
  echo.
  echo *** BUILD FAILED ***
  echo Your Tweego does not support per-project format flags and cannot find SugarCube globally.
  echo Fix one of these:
  echo   A) Update Tweego to latest (then --format-path will work), OR
  echo   B) Install the format globally at:
  echo      C:\Tools\tweego\storyformats\sugarcube-2-37-3\
  echo      (so that "%TWEEGO%" --list-formats shows sugarcube-2-37-3)
  echo.
  pause
  exit /b 1
)

:copy_assets
echo.
if exist "%PROJECT%assets" (
  echo Copying assets to dist\assets ...
  if not exist "%DIST%\assets" mkdir "%DIST%\assets"
  xcopy /E /I /Y "%PROJECT%assets\*" "%DIST%\assets\" >nul
) else (
  echo No assets folder found; skipping asset copy.
)

echo.
echo Build complete: %DIST%\index.html
echo Opening in your default browser...
start "" "%DIST%\index.html"
echo.
pause
exit /b 0
