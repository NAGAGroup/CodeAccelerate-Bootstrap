$env.HOME = $nu.home-dir
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
mkdir $"($nu.cache-dir)"
try {
    carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"
} catch { |err|
    print $"Warning: Failed to generate carapace completions: ($err.msg)"
}

mkdir ~/.cache/pixi
try {
    pixi completion --shell nushell | save -f ~/.cache/pixi/completions.nu
} catch { |err|
    print $"Warning: Failed to generate pixi completions: ($err.msg)"
}

let nu_scripts_dir = ($nu.default-config-dir | path join nu_scripts)
if not ($nu_scripts_dir | path exists) {
    try {
        git clone https://github.com/nushell/nu_scripts.git $nu_scripts_dir
    } catch { |err|
        print $"Warning: Failed to clone nu_scripts: ($err.msg)"
    }
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
$env.nu-config-ext = $config_ext
if not ($config_ext | path exists) {
    touch $config_ext
}

let theme_dir = ($nu.default-config-dir | path join nu_scripts themes)
if ($theme_dir | path exists) {
  $env.NU_THEME_DIR = $theme_dir
  $env.NU_LIB_DIRS =  ($env.NU_LIB_DIRS | prepend $theme_dir)
}

$env.TERM = "xterm-256color"
$env.COLORTERM = "truecolor"

const alias_file = ($nu.default-config-dir | path join "aliases.nu")

if ($alias_file | path exists) == false {
  touch $alias_file
}


# pnpm
$env.PNPM_HOME = "/home/jack/.local/share/pnpm"
$env.PATH = ($env.PATH | split row (char esep) | prepend $env.PNPM_HOME )
# pnpm end
