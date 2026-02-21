# Install dotfiles and set up the development environment.
# Called by bootstrap.sh / bootstrap.bat after nushell is globally installed.

const script_path = path self
def main [] {
    let scripts_dir = ($script_path | path dirname)

    # 1. Sync dotfiles
    nu ($scripts_dir | path join "dots.nu") sync

    # 2. Sync pixi global tools (safe here - NOT inside a pixi task)
    pixi global sync

    # 3. Install Posix-compliant cross-platform shell
    cargo install --git https://github.com/prefix-dev/shell.git --locked shell
}
