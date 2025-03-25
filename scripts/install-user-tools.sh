#!/bin/bash

set -x -e

chezmoi init
chezmoi apply
