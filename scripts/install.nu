# Install dotfiles and set up the development environment.
# Called by bootstrap.sh / bootstrap.bat after nushell is globally installed.

const script_path = path self
def main [] {
    let scripts_dir = ($script_path | path dirname)

    use std/util "path add"
    path add ~/scoop/shims

    # 1. Sync dotfiles
    try {
        let dots_script = ($scripts_dir | path join "dots.nu")
        nu --no-config-file -c $'use ($dots_script); dots sync'
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

    # 3a. Install Linux-specific packages via scoop (packages not available in pixi linux-64)
    if $nu.os-info.name == "linux" {
      try {
        nu-dev -c $"OPENSSL_DIR='($nu.home-dir | path join .pixi/envs/compilers)' cargo install ck-search"
      } catch { |err|
        print $"Warning: Failed to install ck-search: ($err.msg)"
      }
    }

    # 3b. Install Windows-specific packages via scoop (packages not available in pixi win-64)
    if $nu.os-info.name == "windows" {
        print "Installing Windows-specific packages via scoop..."

        # Install jq (not available on win-64)
        try {
            scoop install jq
        } catch { |err|
            print $"Warning: Failed to install jq via scoop: ($err.msg)"
        }

        # Install zellij via cargo binstall (not available on win-64)
        try {
            ~/.pixi/bin/nu-dev -c "cargo install zellij"
        } catch { |err|
            print $"Warning: Failed to install zellij via cargo binstall: ($err.msg)"
        }

        try {
          nu-dev -c $"OPENSSL_DIR='($nu.home-dir | path join .pixi/envs/compilers)' cargo install ck-search"
        } catch { |err|
          print $"Warning: Failed to install ck-search: ($err.msg)"
        }
    }
}
