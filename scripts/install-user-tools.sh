#!/bin/bash

set -x -e

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/bin
~/bin/chezmoi apply

pixi global sync

~/.pixi/bin/fish -c 'bash -c "

npm install --global tabby-agent

if [ ! -d ~/.local/share/omf ]; then
	fish -c "$(curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install)" -- --noninteractive
fi

system_pkgmanager=""
if command -v apt >/dev/null 2>&1; then
	system_pkgmanager="apt"
else
	command -v dnf >/dev/null 2>&1
	system_pkgmanager="dnf"
fi

if ! command -v kitty >/dev/null 2>&1; then
	sudo $system_pkgmanager install -y kitty
fi

echo "source ~/.config/envvars.sh" | tee -a ~/.bashrc"'
