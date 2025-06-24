if ($nu.os-info.name == "windows") {
    nu setup-windows.nu
} 

chezmoi init
chezmoi apply

pixi global sync

nu -c 'cargo install --git https://github.com/prefix-dev/shell.git --tag v0.2.0 --locked shell'
nu -c 'npm install --global @github/copilot-language-server'

if ($nu.os-info.name == "windows") {
    nu finalize-windows.nu
} else {
    nu finalize-linux.nu
}
