#!/bin/bash

set -x -e

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/bin
~/bin/chezmoi apply

pixi global install \
	python \
	git \
	xclip \
	cmake \
	make \
	ninja \
	gxx \
	gcc \
	cargo \
	go \
	fish \
	nvim \
	luarocks \
	shellcheck \
	nodejs

cargo install ripgrep
cargo install bottom
go install github.com/jesseduffield/lazygit@latest
go install github.com/dundee/gdu/v5/cmd/gdu@latest

luarocks install --server=https://luarocks.org/dev luaformatter

pixi global install fish

cargo install wl-clipboard-rs-tools

source ~/.bashrc
