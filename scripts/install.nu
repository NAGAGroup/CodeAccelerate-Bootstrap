if ($nu.os-info.name == "windows") {
    nu setup-windows.nu
} 

pixi global sync
cargo install --git https://github.com/prefix-dev/shell.git --tag v0.2.0 --locked shell
npm install --global @github/copilot-language-server

chezmoi init
chezmoi apply

if ($nu.os-info.name == "windows") {
    nu finalize-windows.nu
} else {
    nu finalize-linux.nu
}
