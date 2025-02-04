rm -rf ~/AppData/Local/nvim
ln -sf ~/.config/nvim ~/AppData/Local/nvim

powershell.exe ./scripts/install-fonts.ps1

cargo install --git https://github.com/prefix-dev/shell.git --tag v0.2.0 --locked shell
