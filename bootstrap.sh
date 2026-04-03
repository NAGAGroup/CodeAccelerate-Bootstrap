#!/usr/bin/env bash
set -e

# Install pixi if not present
if ! command -v pixi &>/dev/null; then
    curl -fsSL https://pixi.sh/install.sh | bash
    if [ $? -ne 0 ]; then echo "Failed to install pixi"; exit 1; fi
    export PATH="$HOME/.pixi/bin:$PATH"
fi

# Install nushell globally (independent of any pixi project env)
pixi global install nushell

# Hand off to nushell install script
nu "$(dirname "$0")/scripts/install.nu"
