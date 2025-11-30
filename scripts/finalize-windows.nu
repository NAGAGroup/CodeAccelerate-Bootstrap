def make_symlink [source: string, target: string] {  
  let target_bak = ($target + ".bak")
  rm -rf $target_bak
  mv $target $target_bak
  sudo powershell -c $"New-Item -ItemType SymbolicLink -Path ($target) -Target ($source)" 
}

let nvim_target = ($env.UserProfile | path join "AppData/Local/nvim")
let nvim_src = ($env.UserProfile | path join ".config/nvim")
make_symlink $nvim_src $nvim_target

let nu_target = ($env.UserProfile | path join "AppData/Roaming/nushell")
let nu_src = ($env.UserProfile | path join ".config/nushell")
make_symlink $nu_src $nu_target

# powershell install-fonts.ps1
