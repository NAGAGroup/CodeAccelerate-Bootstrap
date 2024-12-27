cargo install --locked nu

rm -rf ~/AppData/Local/nvim
ln -sf ~/.config/nvim ~/AppData/Local/nvim

powershell.exe ./scripts/install-fonts.ps1
