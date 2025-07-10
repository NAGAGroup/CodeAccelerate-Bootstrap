--[[ 
=====================================================================
          Neovim Configuration - LSP Extensions
=====================================================================
This module loads LSP extension plugins.
]]

return {
  -- SchemaStore: JSON schema provider
  {
    'b0o/schemastore.nvim',
    lazy = true,
  },
  
  -- Enhanced C/C++ support
  {
    'p00f/clangd_extensions.nvim',
    lazy = true,
    ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    opts = {
      inlay_hints = {
        inline = false,
      },
    },
  },
  
  -- Semantic token highlighting
  {
    'folke/lsp-colors.nvim',
    event = 'LspAttach',
  },
  
  -- LSP progress UI
  {
    'j-hui/fidget.nvim',
    opts = {
      progress = {
        display = {
          progress_icon = { pattern = "moon", period = 1 },
        },
      },
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
    event = 'LspAttach',
  },
}