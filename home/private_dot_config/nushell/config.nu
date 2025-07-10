$env.config.shell_integration.osc133 = false

#~/.config/nushell/config.nu
source ~/.cache/carapace/init.nu

use ~/.cache/pixi/completions.nu *

$env.SHELL = "nu"

use std/util "path add"
$env.PATH = ($env.PATH | prepend $"($env.HOME)/bin")
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.cargo/bin")

$env.EDITOR = "nvim"

$env.Path = $env.PATH

if "NU_THEME_DIR" in $env {
  source nu-themes/horizon-terminal-dark.nu 
}
