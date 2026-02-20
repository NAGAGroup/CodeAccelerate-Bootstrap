@echo off

:: Install pixi if not present
where pixi >nul 2>&1 || (
    powershell -c "iwr -useb https://pixi.sh/install.ps1 | iex"
)

:: Install nushell globally
%USERPROFILE%\.pixi\bin\pixi global install nushell

:: Hand off to nushell install script
%USERPROFILE%\.pixi\bin\nu "%~dp0scripts\install.nu"
