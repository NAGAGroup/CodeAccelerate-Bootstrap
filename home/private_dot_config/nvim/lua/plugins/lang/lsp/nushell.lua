--[[ 
=====================================================================
          Neovim Configuration - Nushell Language Server
=====================================================================
This module configures the Nushell language server, which is not installed
via Mason but is expected to be available on the system.
]]

return {
  nushell = {
    cmd = { "nu", "--lsp" },
    filetypes = { "nu" },
    root_dir = require("lspconfig.util").find_git_ancestor,
  },
}