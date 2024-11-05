#!/bin/bash

set -x

chezmoi apply

set -e

rustup toolchain install stable-msvc
rustup default stable-msvc

cargo install --locked cargo-binstall
cargo binstall -y tree-sitter-cli
go install github.com/jesseduffield/lazygit@latest
go install github.com/dundee/gdu/v5/cmd/gdu@latest

