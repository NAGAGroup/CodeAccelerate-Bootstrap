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

# Setup OpenCode AI assistant and Superpowers skills library
def setup_opencode [] {
    # Install OpenCode via npm
    print "Installing OpenCode..."
    npm install --global opencode-ai

    # Setup Superpowers skills library
    let superpowers_dir = ("~/.config/opencode/superpowers" | path expand)
    print $"Setting up Superpowers at ($superpowers_dir)..."
    
    if ($superpowers_dir | path exists) == false {
        git clone https://github.com/obra/superpowers.git $superpowers_dir
    } else {
        try {
            cd $superpowers_dir
            git fetch --all
            git pull --rebase
        } catch { |err|
            print ("Failed to update superpowers: " + $err.msg)
        }
    }

    # Create plugin symlink for Superpowers
    let plugin_dir = ("~/.config/opencode/plugin" | path expand)
    let plugin_source = ($superpowers_dir | path join ".opencode" "plugin" "superpowers.js")
    let plugin_target = ($plugin_dir | path join "superpowers.js")

    mkdir $plugin_dir
    if ($plugin_target | path exists) {
        rm $plugin_target
    }
    # Create symlink (works on both Linux and Windows with appropriate permissions)
    if ($nu.os-info.name == "windows") {
        # Windows requires special handling for symlinks
        ^cmd /c mklink $plugin_target $plugin_source
    } else {
        ln -sf $plugin_source $plugin_target
    }
    print "Superpowers plugin linked successfully"
}

def main [] {
    if ($nu.os-info.name == "windows") {
        nu setup-windows.nu
    } 

    chezmoi init
    chezmoi apply

    pixi global sync

    setup_nu_scripts
    setup_opencode

    nu -c 'cargo install --git https://github.com/prefix-dev/shell.git --tag v0.2.0 --locked shell'
    nu -c 'npm install --global @github/copilot-language-server'

    if ($nu.os-info.name == "windows") {
        nu finalize-windows.nu
    } else {
        nu finalize-linux.nu
    }
}
