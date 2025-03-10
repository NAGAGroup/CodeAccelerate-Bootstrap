#!/bin/bash

set -exou -pipefail

pixi run install
pixi global sync

mkdir -p carapace-bin
wget https://github.com/carapace-sh/carapace-bin/releases/download/v1.1.0/carapace-bin_1.1.0_linux_amd64.tar.gz -O carapace-bin.tar.gz
tar -xzvf carapace-bin.tar.gz -C carapace-bin
cp carapace-bin/carapace ~/bin
rm -rf carapace-bin.tar.gz carapace-bin

find ~/bin -type f -exec chmod +x {} \;

nu -c 'cargo install --git https://github.com/prefix-dev/shell.git --tag v0.2.0 --locked shell'
