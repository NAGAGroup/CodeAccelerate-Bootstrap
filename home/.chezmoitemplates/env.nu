# Default Nushell Environment Config File
# These "sensible defaults" are set before the user's `env.nu` is loaded
#
# version = "0.101.0"

if $nu.os-info.name == "windows" {
    if not ("PIXI_DEVENV_ACTIVE" in $env) {
        if (echo ~/.cargo/bin/nu.exe | path exists) {
            echo "nu.exe found in ~/.pixi/bin"
            $env.PIXI_DEVENV_ACTIVE = "1"
            exec $"($env.USERPROFILE)/.cargo/bin/nu.exe"
        }
    }
}

$env.PROMPT_COMMAND = $env.PROMPT_COMMAND? | default {||
    let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)(ansi reset)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

$env.PROMPT_COMMAND_RIGHT = $env.PROMPT_COMMAND_RIGHT? | default {||
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (date now | format date '%x %X') # try to respect user's locale
    ] | str join | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
        str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

if ($nu.os-info.name == "windows") {
    $env.HOME = $env.USERPROFILE
    $env.PATH = $env.Path
}

$env.SHELL = "nu"

$env.PATH = ($env.PATH | prepend ~/bin)
$env.PATH = ($env.PATH | prepend ~/.cargo/bin)

$env.EDITOR = "nvim"

$env.PATH = ($env.PATH | uniq)
$env.Path = $env.PATH

# To load from a custom file you can use:
const custom_path = ($nu.default-config-dir | path join "custom.nu")
touch $custom_path

mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

mkdir ~/.cache/pixi
pixi completion --shell nushell | save -f ~/.cache/pixi/completions.nu
