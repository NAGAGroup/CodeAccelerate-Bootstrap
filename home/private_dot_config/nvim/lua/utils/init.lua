--[[ 
=====================================================================
                Neovim Configuration - Utility Loader
=====================================================================
This module loads and exposes all utility functions used across the
Neovim configuration.
]]

local M = {}

-- Load all utility modules
M.fs = require('utils.fs')
M.lsp = require('utils.lsp')
M.ui = require('utils.ui')
M.profiler = require('utils.profiler')
M.keymap_doc = require('utils.keymap_doc')

-- Include all functions from the old utils module for compatibility
for k, v in pairs(require('utils.compat')) do
  M[k] = v
end

return M