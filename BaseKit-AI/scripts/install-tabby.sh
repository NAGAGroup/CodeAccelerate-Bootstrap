#!/bin/bash

set -e

wget https://github.com/TabbyML/tabby/releases/download/v0.20.0/tabby_x86_64-manylinux2014.zip -O tabby.zip
unzip tabby.zip -d tabby
find tabby/ -type f -exec bash -c "chmod +x {} && cp {} $CONDA_PREFIX/bin" ";"
