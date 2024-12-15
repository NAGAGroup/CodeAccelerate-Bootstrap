# Nushell Environment File

$env.SHELL = "nu"

$env.Path = ($env.Path | prepend ~/bin)
$env.Path = ($env.Path | prepend ~/.cargo/bin)

# To load from a custom file you can use:
const custom_path = ($nu.default-config-dir | path join 'custom.nu')
touch $custom_path

mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

mkdir ~/.cache/pixi
pixi completion --shell nushell | save -f ~/.cache/pixi/completions.nu
