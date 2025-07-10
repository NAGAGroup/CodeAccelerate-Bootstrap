--[[
=====================================================================
              Neovim Configuration - LSP Keymaps
=====================================================================
This module defines standard LSP keybindings that are attached to buffers
when an LSP client attaches. It provides a consistent interface for all
language servers.
]]

local M = {}

 -- Helper function for diagnostic navigation
 local diagnostic_goto = function(next, severity)
   local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
   severity = severity and vim.diagnostic.severity[severity] or nil
   return function()
     go { severity = severity }
   end
 end
 
M._keys = nil

-- Define and return all LSP keybindings
function M.get()
  -- Return cached keybindings if already defined
  if M._keys then
    return M._keys
  end
  
  -- Define key mappings organized by category
  M._keys = {
    -- LSP Info and management
    { '<leader>cl', '<cmd>LspInfo<CR>', desc = 'LSP Info' },
    { '<leader>cr', vim.lsp.buf.rename, desc = 'Rename Symbol' },
    
    -- Code navigation
    { 'gd', vim.lsp.buf.definition, desc = 'Goto Definition' },
    { 'gD', vim.lsp.buf.declaration, desc = 'Goto Declaration' },
    { 'gr', vim.lsp.buf.references, desc = 'Find References' },
    { 'gI', vim.lsp.buf.implementation, desc = 'Goto Implementation' },
    { 'gy', vim.lsp.buf.type_definition, desc = 'Goto Type Definition' },
    
    -- Documentation
    { 'K', vim.lsp.buf.hover, desc = 'Hover Documentation' },
    { 'gK', vim.lsp.buf.signature_help, desc = 'Signature Help' },
    { '<c-k>', vim.lsp.buf.signature_help, desc = 'Signature Help', mode = 'i' },
    
    -- Diagnostics
    { '[d', vim.diagnostic.goto_prev, desc = 'Previous Diagnostic' },
    { ']d', vim.diagnostic.goto_next, desc = 'Next Diagnostic' },
    { '[e', diagnostic_goto(false, 'ERROR'), desc = 'Previous Error' },
    { ']e', diagnostic_goto(true, 'ERROR'), desc = 'Next Error' },
    { '[w', diagnostic_goto(false, 'WARN'), desc = 'Previous Warning' },
    { ']w', diagnostic_goto(true, 'WARN'), desc = 'Next Warning' },
    { '<leader>cd', vim.diagnostic.open_float, desc = 'Line Diagnostics' },
    { '<leader>cD', '<cmd>Telescope diagnostics<cr>', desc = 'Workspace Diagnostics' },
    
    -- Code actions
    { '<leader>ca', vim.lsp.buf.code_action, desc = 'Code Action', mode = { 'n', 'v' } },
    { '<leader>cc', vim.lsp.codelens.run, desc = 'Run Codelens' },
    { '<leader>cC', vim.lsp.codelens.refresh, desc = 'Refresh Codelens' },
    
    -- Workspace
    { '<leader>cwa', vim.lsp.buf.add_workspace_folder, desc = 'Add Workspace Folder' },
    { '<leader>cwr', vim.lsp.buf.remove_workspace_folder, desc = 'Remove Workspace Folder' },
    { '<leader>cwl', function()
      vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()), vim.log.levels.INFO)
    end, desc = 'List Workspace Folders' },
    
    -- Formatting
    { '<leader>cf', function()
      vim.lsp.buf.format({ async = true })
    end, desc = 'Format Document', mode = { 'n', 'v' } },
  }
  
  return M._keys
end

-- Set up keymaps when an LSP attaches to a buffer
function M.on_attach(client, buffer)
  local Keys = require("lazy.core.handler.keys")
  local keymaps = M.get()
  
  for _, keys in pairs(keymaps) do
    -- If the keymap has a specific mode, use it; otherwise default to 'n'
    local mode = keys.mode or 'n'
    keys.mode = nil
    
    -- Add buffer to the keymap
    keys.buffer = buffer
    
    -- Set the keymap
    Keys.set(mode, keys)
  end
end

return M