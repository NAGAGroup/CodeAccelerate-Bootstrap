powershell -c "
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser;
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
"
~/scoop/shims/scoop install sudo neovim jq unzip which
