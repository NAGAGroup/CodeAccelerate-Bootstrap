@echo off

:: Install pixi if not present
where pixi >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Installing pixi...
    powershell -c "iwr -useb https://pixi.sh/install.ps1 | iex"
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to install pixi
        exit /b 1
    )
    :: Refresh PATH to include pixi
    call RefreshEnv.cmd 2>nul || set "PATH=%USERPROFILE%\.pixi\bin;%PATH%"
)

:: Install scoop if not present
where scoop >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Installing scoop...
    powershell -c "irm get.scoop.sh | iex"
)

:: Install nushell globally via pixi
pixi global install nushell

:: Hand off to nushell install script
nu "%~dp0scripts\install.nu"
