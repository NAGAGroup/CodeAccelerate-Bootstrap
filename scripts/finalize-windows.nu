mv ~/AppData/Local/nvim ~/AppData/Local/nvim.bak
sudo powershell -c $"New-Item -ItemType SymbolicLink -Path ($env.HOME)/AppData/Local/nvim -Target ($env.HOME)/.config/nvim"

powershell.exe ./scripts/install-fonts.ps1

cargo install --git https://github.com/prefix-dev/shell.git --tag v0.2.0 --locked shell
