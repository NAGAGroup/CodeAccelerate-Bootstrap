@echo off

:: Install pixi if not present
where pixi >nul 2>&1 || (
    powershell -c "iwr -useb https://pixi.sh/install.ps1 | iex"
    set "PATH=%USERPROFILE%\.pixi\bin;%PATH%"
)

:: Install scoop if not present
where scoop >nul 2>&1 || (
    powershell -c "irm get.scoop.sh | iex"
)

:: Install nushell globally via pixi
%USERPROFILE%\.pixi\bin\pixi global install nushell

:: Hand off to nushell install script
%USERPROFILE%\.pixi\bin\nu "%~dp0scripts\install.nu"
