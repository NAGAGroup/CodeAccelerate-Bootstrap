#!/bin/bash

set -x

chezmoi apply

set -e

pixi global sync

~/.pixi/bin/nu.bat -c 'bash -c "npm install --global tabby-agent"'
