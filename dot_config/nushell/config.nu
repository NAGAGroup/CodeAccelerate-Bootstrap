# $env.config.shell_integration.osc133 = false

# source $"($nu.cache-dir)/carapace.nu"

use ~/.cache/pixi/completions.nu *

$env.SHELL = "nu"

use std/util "path add"

$env.EDITOR = "nvim"

$env.Path = $env.PATH

if "NU_THEME_DIR" in $env {
  # source nu-themes/catppuccin-mocha.nu
}

const config_ext = $"($nu.default-config-dir)/config-ext.nu"
if ($config_ext | path exists) {
    source $config_ext
}

const alias_file = ($nu.default-config-dir | path join "aliases.nu")
source $alias_file

const alias_file = ($nu.default-config-dir | path join "win-aliases.nu")
source $alias_file

path add ~/go/bin
path add ~/bin
path add ~/.cargo/bin/
path add ~/.opencode/bin
path add ~/.local/bin/
path add ~/.pixi/envs/nodejs
path add ~/.pixi/envs/nodejs/bin
path add ~/.pixi/bin
