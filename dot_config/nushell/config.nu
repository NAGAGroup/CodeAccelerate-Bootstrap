# $env.config.shell_integration.osc133 = false

# source $"($nu.cache-dir)/carapace.nu"

use ~/.cache/pixi/completions.nu *

$env.SHELL = "nu"

use std/util "path add"

# Add Linux-specific paths (these directories don't exist on Windows by default)
if $nu.os-info.name != "windows" {
    path add ~/bin
    path add ~/.cargo/bin/
    path add ~/.opencode/bin
    path add ~/.local/bin/
}

$env.EDITOR = "nvim"

$env.Path = $env.PATH

if "NU_THEME_DIR" in $env {
  # source nu-themes/catppuccin-mocha.nu
}

const config_ext = $"($nu.default-config-dir)/config-ext.nu"
if ($config_ext | path exists) {
    source $config_ext
}

