#!/bin/bash

set -exou -pipefail

pixi run install
pixi global sync
