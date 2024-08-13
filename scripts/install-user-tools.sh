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
  rust \
  go \
  fish \
  nvim \
  luarocks \
  shellcheck \
  nodejs \
  tmux \
  pylatexenc

cargo install ripgrep
cargo install bottom
cargo install tree-sitter-cli
go install github.com/jesseduffield/lazygit@latest
go install github.com/dundee/gdu/v5/cmd/gdu@latest

luarocks install --server=https://luarocks.org/dev luaformatter

pixi global install fish

cargo install wl-clipboard-rs-tools

if [ ! -d ~/.local/share/omf ]; then
  fish -c "$(curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install)" -- --noninteractive
fi
