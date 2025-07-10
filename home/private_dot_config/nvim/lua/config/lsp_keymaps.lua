--[[
  LSP Keymaps Configuration
  
  This module defines standard LSP keybindings that are attached to buffers
  when an LSP client attaches. It provides a consistent interface for all
  language servers.
]]

local M = {}

-- Cache for LSP keymaps
M._keys = nil

-- Define and return all LSP keybindings
function M.get()
  -- Return cached keybindings if already defined
  if M._keys then
    return M._keys
  end
  
  -- Define key mappings organized by category
  -- stylua: ignore start
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
    
    -- Documentation and help
    { 'K', vim.lsp.buf.hover, desc = 'Show Hover Documentation' },
    { 'gK', vim.lsp.buf.signature_help, desc = 'Signature Help' },
    { '<c-k>', vim.lsp.buf.signature_help, mode = 'i', desc = 'Signature Help' },
    
    -- Code actions and lenses
    { '<leader>ca', vim.lsp.buf.code_action, desc = 'Code Action', mode = { 'n', 'v' } },
    { '<leader>cc', vim.lsp.codelens.run, desc = 'Run Codelens' },
    { '<leader>cC', vim.lsp.codelens.refresh, desc = 'Refresh Codelens' },
    
    -- Workspace management
    { '<leader>cwa', vim.lsp.buf.add_workspace_folder, desc = 'Add Workspace Folder' },
    { '<leader>cwr', vim.lsp.buf.remove_workspace_folder, desc = 'Remove Workspace Folder' },
    { '<leader>cwl', function()
      vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, desc = 'List Workspace Folders' },
  }
  -- stylua: ignore end

  return M._keys
end

-- Attach keymaps to a buffer when an LSP client attaches
function M.on_attach(client, buffer)
  -- Skip attaching keymaps for certain servers if needed
  -- Example: if client.name == "tsserver" and some_condition then return end

  local keymaps = M.get()

  for _, keymap in ipairs(keymaps) do
    -- Extract keymap configuration
    local lhs = keymap[1] -- The key sequence
    local rhs = keymap[2] -- The command or function
    local opts = {
      desc = keymap.desc or ('LSP: ' .. (type(rhs) == 'string' and rhs or lhs)),
      buffer = buffer, -- Apply to the current buffer
      silent = true, -- Don't show command in command line
      nowait = true, -- Don't wait for another key after this
      mode = keymap.mode or 'n', -- Default to normal mode
    }

    -- Set the keymap with appropriate mode
    if type(opts.mode) == 'table' then
      -- Handle multiple modes
      for _, mode in ipairs(opts.mode) do
        local mode_opts = vim.deepcopy(opts)
        mode_opts.mode = nil
        vim.keymap.set(mode, lhs, rhs, mode_opts)
      end
    else
      -- Single mode
      local mode = opts.mode
      opts.mode = nil
      vim.keymap.set(mode, lhs, rhs, opts)
    end
  end

  -- Add language-specific keymaps
  if client.name == 'clangd' then
    vim.keymap.set('n', '<leader>ch', '<cmd>ClangdSwitchSourceHeader<cr>', {
      buffer = buffer,
      desc = 'Switch Source/Header (C/C++)',
      silent = true,
      nowait = true,
    })
  end
end

return M
