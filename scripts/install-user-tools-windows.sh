#!/bin/bash

set -exou -pipefail

chezmoi init
chezmoi apply
