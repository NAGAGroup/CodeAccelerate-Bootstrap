# Install dotfiles and set up the development environment.
# Called by bootstrap.sh / bootstrap.bat after nushell is globally installed.

const script_path = path self
def main [] {
    let scripts_dir = ($script_path | path dirname)

    # 1. Sync dotfiles
    try {
        let dots_script = ($scripts_dir | path join "dots.nu")
        nu --no-config-file -c $'use ($dots_script); sync'
    } catch { |err|
        print $"Error: Failed to sync dotfiles: ($err.msg)"
        exit 1
    }

    # 2. Sync pixi global tools (safe here - NOT inside a pixi task)
    try {
        pixi global sync
    } catch { |err|
        print $"Error: Failed to sync pixi global tools: ($err.msg)"
        exit 1
    }

    # 3. Install Posix-compliant cross-platform shell
    try {
        cargo install --git https://github.com/prefix-dev/shell.git --locked shell
    } catch { |err|
        print $"Error: Failed to install shell: ($err.msg)"
        exit 1
    }

    # 4. Install Windows-specific packages via scoop (packages not available in pixi win-64)
    if $nu.os-info.name == "windows" {
        print "Installing Windows-specific packages via scoop..."
        
        # Install neovim (conda-forge nvim is Python library, not the editor)
        try {
            scoop install neovim
        } catch { |err|
            print $"Warning: Failed to install neovim via scoop: ($err.msg)"
        }

        # Install jq (not available on win-64)
        try {
            scoop install jq
        } catch { |err|
            print $"Warning: Failed to install jq via scoop: ($err.msg)"
        }

        # Install zellij via cargo binstall (not available on win-64)
        try {
            cargo binstall -y zellij
        } catch { |err|
            print $"Warning: Failed to install zellij via cargo binstall: ($err.msg)"
        }
    }
}
