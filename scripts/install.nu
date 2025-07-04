def setup_nu_scripts [] {
    let nu_scripts_dir = ($nu.default-config-dir | path join nu_scripts)
    if ($nu_scripts_dir | path exists) == false {
        git clone https://github.com/nushell/nu_scripts.git $nu_scripts_dir
    } else {
        try {
            cd $nu_scripts_dir
            git fetch --all
            git pull --rebase
        } catch { |err|
            print ("Failed to update nu_scripts: " + $err.msg)
        }
    }
}

def main [] {
    if ($nu.os-info.name == "windows") {
        nu setup-windows.nu
    } 

    chezmoi init
    chezmoi apply

    pixi global sync

    setup_nu_scripts

    nu -c 'cargo install --git https://github.com/prefix-dev/shell.git --tag v0.2.0 --locked shell'
    nu -c 'npm install --global @github/copilot-language-server'

    if ($nu.os-info.name == "windows") {
        nu finalize-windows.nu
    } else {
        nu finalize-linux.nu
    }
}
