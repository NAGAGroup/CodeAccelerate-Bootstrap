#!/bin/bash

set -x -e

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/bin
~/bin/chezmoi apply

# Define the directory you want to remove
DIR_TO_REMOVE="$CONDA_PREFIX/bin"

# Remove the directory from PATH
PATH=$(echo ":$PATH:" | sed "s;:$DIR_TO_REMOVE:;:;g" | sed 's/^://;s/:$//')


pixi global sync

~/.pixi/bin/nu -c 'npm install --global tabby-agent'
