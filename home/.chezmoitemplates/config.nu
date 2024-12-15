# Nushell Environment Config File

# To load from a custom file you can use:
const custom_path = ($nu.default-config-dir | path join 'custom.nu')
source $custom_path

$env.config.shell_integration.osc133 = false

#~/.config/nushell/config.nu
source ~/.cache/carapace/init.nu

use ~/.cache/pixi/completions.nu *
