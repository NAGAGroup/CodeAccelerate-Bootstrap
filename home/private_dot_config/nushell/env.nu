$env.HOME = $nu.home-path
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

mkdir ~/.cache/pixi
pixi completion --shell nushell | save -f ~/.cache/pixi/completions.nu

let theme_dir = ($nu.default-config-dir | path join nu_scripts themes)
if ($theme_dir | path exists) { 
  $env.NU_THEME_DIR = $theme_dir
  $env.NU_LIB_DIRS =  ($env.NU_LIB_DIRS | prepend $theme_dir) 
}
