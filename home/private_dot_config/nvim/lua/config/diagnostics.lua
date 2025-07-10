--[[
=====================================================================
            Neovim Configuration - Diagnostics Configuration
=====================================================================
This module configures diagnostic settings and visual representation.
]]

local M = {}

-- Default diagnostic config
M.config = {
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    source = 'if_many',
    prefix = '●', -- Could be '■', '▎', 'x'
  },
  severity_sort = true,
  signs = true,
  float = {
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
}

-- Diagnostic signs
M.signs = {
  Error = { text = "󰅚", texthl = "DiagnosticSignError" },
  Warn = { text = "", texthl = "DiagnosticSignWarn" },
  Hint = { text = "󰌶", texthl = "DiagnosticSignHint" },
  Info = { text = "", texthl = "DiagnosticSignInfo" },
}

-- Set up diagnostic configuration
function M.setup()
  -- Set diagnostic configuration
  vim.diagnostic.config(M.config)
  
  -- Set diagnostic signs
  for type, icon in pairs(M.signs) do
    local hl = icon.texthl
    vim.fn.sign_define(hl, {
      text = icon.text,
      texthl = hl,
      numhl = hl,
    })
  end
  
  -- LSP handlers
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover,
    { border = 'rounded' }
  )
  
  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    { border = 'rounded' }
  )
end

return M