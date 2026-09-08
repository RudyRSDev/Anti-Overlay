@echo off
setlocal EnableDelayedExpansion

title Anti Overlay
set "WAIT_SECONDS=20"


echo.
echo  ______  __  __  ______  ______      _____   __  __  ____    ____    __       ______   __    __ 
echo /\  _  \/\ \/\ \/\__  _\/\__  _\    /\  __`\/\ \/\ \/\  _`\ /\  _`\ /\ \     /\  _  \ /\ \  /\ \
echo \ \ \L\ \ \ `\\ \/_/\ \/\/_/\ \/    \ \ \/\ \ \ \ \ \ \ \L\_\ \ \L\ \ \ \    \ \ \L\ \\ `\`\\/'/
echo  \ \  __ \ \ , ` \ \ \ \   \ \ \     \ \ \ \ \ \ \ \ \ \  _\L\ \ ,  /\ \ \  __\ \  __ \`\ `\ /' 
echo   \ \ \/\ \ \ \`\ \ \ \ \   \_\ \__   \ \ \_\ \ \ \_/ \ \ \L\ \ \ \\ \\ \ \L\ \\ \ \/\ \ `\ \ \ 
echo    \ \_\ \_\ \_\ \_\ \ \_\  /\_____\   \ \_____\ `\___/\ \____/\ \_\ \_\ \____/ \ \_\ \_\  \ \_\
echo     \/_/\/_/\/_/\/_/  \/_/  \/_____/    \/_____/`\/__/  \/___/  \/_/\/ /\/___/   \/_/\/_/   \/_/
echo.

:: Locate Steam directory from Windows Registry
set "STEAM_DIR="
for /f "tokens=2* skip=2" %%A in ('reg query "HKCU\Software\Valve\Steam" /v "SteamPath" 2^>nul') do set "STEAM_DIR=%%B"
if not defined STEAM_DIR (
    for /f "tokens=2* skip=2" %%A in ('reg query "HKLM\SOFTWARE\WOW6432Node\Valve\Steam" /v "InstallPath" 2^>nul') do set "STEAM_DIR=%%B"
)
if defined STEAM_DIR (
    set "STEAM_DIR=!STEAM_DIR:/=\!"
) else (
    set "STEAM_DIR=C:\Program Files (x86)\Steam"
)

set "DLL32=!STEAM_DIR!\GameOverlayRenderer.dll"
set "DLL64=!STEAM_DIR!\GameOverlayRenderer64.dll"

:: One-time permission setup for the Users group
icacls "!DLL64!" /deny "Users:(X)" >nul 2>&1
if !errorlevel! neq 0 (
    echo Requesting one-time permission to manage Steam overlay files...
    powershell -NoProfile -Command "Start-Process cmd.exe -ArgumentList '/c icacls `\"!DLL32!`\" /grant Users:F & icacls `\"!DLL64!`\" /grant Users:F' -Verb RunAs -Wait" >nul 2>&1
) else (
    icacls "!DLL64!" /remove:d "Users" >nul 2>&1
)

:: Block overlay DLLs
echo Blocking Steam Overlay...
if exist "!DLL32!" icacls "!DLL32!" /deny "Users:(X)" >nul 2>&1
if exist "!DLL64!" icacls "!DLL64!" /deny "Users:(X)" >nul 2>&1

:: Launch game
echo Launching game: %*
start "" %*

:: Wait for game startup then restore permissions
echo Waiting for game to launch...
timeout /t %WAIT_SECONDS% /nobreak >nul

echo Restoring Steam Overlay permissions...
if exist "!DLL32!" icacls "!DLL32!" /remove:d "Users" >nul 2>&1
if exist "!DLL64!" icacls "!DLL64!" /remove:d "Users" >nul 2>&1
echo Permissions restored successfully.
timeout /t 5 /nobreak >nul

exit /b 0