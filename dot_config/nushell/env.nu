$env.HOME = $nu.home-dir
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

mkdir ~/.cache/pixi
pixi completion --shell nushell | save -f ~/.cache/pixi/completions.nu

let nu_scripts_dir = ($nu.default-config-dir | path join nu_scripts)
if not ($nu_scripts_dir | path exists) {
    git clone https://github.com/nushell/nu_scripts.git $nu_scripts_dir
} else {
    try {
        git -C $nu_scripts_dir fetch --all
        git -C $nu_scripts_dir pull --rebase
    } catch { |err|
        print ("Failed to update nu_scripts: " + $err.msg)
    }
}

# Ensure config-ext.nu exists (sourced by config.nu)
let config_ext = ($nu.default-config-dir | path join "config-ext.nu")
if not ($config_ext | path exists) {
    touch $config_ext
}

let theme_dir = ($nu.default-config-dir | path join nu_scripts themes)
if ($theme_dir | path exists) {
  $env.NU_THEME_DIR = $theme_dir
  $env.NU_LIB_DIRS =  ($env.NU_LIB_DIRS | prepend $theme_dir)
}
