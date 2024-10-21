#!/bin/bash

set -x -e

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/bin
~/bin/chezmoi apply

pixi global install \
  python \
  git \
  cmake \
  make \
  ninja \
  rust \
  go \
  fish \
  nvim \
  shellcheck \
  nodejs \
  fish

cargo install cargo-binstall
cargo binstall -y ripgrep
cargo binstall -y bottom
cargo binstall -y tree-sitter-cli
go install github.com/jesseduffield/lazygit@latest
go install github.com/dundee/gdu/v5/cmd/gdu@latest

if [ ! -d ~/.local/share/omf ]; then
  fish -c "$(curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install)" -- --noninteractive
fi

cargo binstall -y zellij
