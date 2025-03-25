#!/bin/bash

set -exou -pipefail

pixi run install
pixi global sync

find ~/bin -type f -exec chmod +x {} \;

nu -c 'cargo install --git https://github.com/prefix-dev/shell.git --tag v0.2.0 --locked shell'
