#!/bin/bash

set -x -e

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/bin
~/bin/chezmoi apply

pixi global sync

~/.pixi/bin/nu -c 'npm install --global tabby-agent'
