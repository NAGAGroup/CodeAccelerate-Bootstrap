mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

mkdir ~/.cache/pixi
pixi completion --shell nushell | save -f ~/.cache/pixi/completions.nu
