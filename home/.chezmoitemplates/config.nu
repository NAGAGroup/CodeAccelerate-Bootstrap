# Nushell Environment Config File

source ~/.config/nushell/default-env.nu
source ~/.config/nushell/default-config.nu

$env.SHELL = "nu"

$env.Path = ($env.Path | prepend $"($env.HOME)/bin")
$env.Path = ($env.Path | prepend $"($env.HOME)/.cargo/bin")

$env.EDITOR = "nvim"

# To load from a custom file you can use:
const custom_path = ($nu.default-config-dir | path join 'custom.nu')
touch $custom_path

mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

mkdir ~/.cache/pixi
pixi completion --shell nushell | save -f ~/.cache/pixi/completions.nu

# To load from a custom file you can use:
const custom_path = ($nu.default-config-dir | path join 'custom.nu')
source $custom_path

$env.config.shell_integration.osc133 = false

#~/.config/nushell/config.nu
source ~/.cache/carapace/init.nu

use ~/.cache/pixi/completions.nu *
