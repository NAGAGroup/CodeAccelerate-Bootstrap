-- =============================================================================
-- config/builtins.lua — Built-in plugins via vim.pack (undotree, difftool)
-- =============================================================================
-- These plugins are packaged with Neovim v0.12+ and available in the runtime pack.
-- They are loaded via :packadd and do not require external installation.

-- Section 1: undotree — persistent undo tree visualization
-- Registered command: :Undotree
vim.cmd('packadd nvim.undotree')
vim.keymap.set('n', '<leader>U', '<cmd>Undotree<cr>', { desc = 'Toggle undotree' })

-- Section 2: difftool — built-in diff comparison tool
-- Registered command: :DiffTool <left> <right>
-- Also used by: nvim -d file1 file2
vim.cmd('packadd nvim.difftool')

-- Section 3: UI2 — experimental new UI system (Neovim v0.12 experimental feature)
-- WARNING: Experimental API — may change before Neovim 1.0
-- Suppresses 'Press ENTER to continue' prompts in multi-line output
-- Remove or comment out if instability is observed
pcall(function()
  require('vim._core.ui2').enable({ enable = true })
end)

-- Section 4: which-key group registration for builtins
local ok, wk = pcall(require, 'which-key')
if ok then
  wk.add({ { '<leader>U', desc = 'Toggle undotree' } })
end
