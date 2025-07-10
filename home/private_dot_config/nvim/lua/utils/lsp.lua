--[[ 
=====================================================================
                Neovim Configuration - LSP Utilities
=====================================================================
This module provides LSP-related utility functions.
]]

local M = {}

-- Get the client by name
function M.get_client_by_name(name)
  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.name == name then
      return client
    end
  end
  return nil
end

-- Check if a server is configured
function M.is_server_configured(server_name)
  for _, server in pairs(require('lspconfig.configs')) do
    if server.name == server_name then
      return true
    end
  end
  return false
end

-- Get LSP capabilities
function M.get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  
  -- Add completion capabilities from blink.cmp if available
  local has_cmp, cmp_nvim_lsp = pcall(require, 'blink.cmp')
  if has_cmp then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end
  
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  
  return capabilities
end

return M