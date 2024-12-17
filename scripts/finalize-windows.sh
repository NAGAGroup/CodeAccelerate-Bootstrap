#!/bin/bash

set -x

cargo="$HOME/.pixi/bin/cargo.bat"

$cargo install --locked nu
ln -sf ~/.cargo/bin/nu ~/.pixi/bin/nu
