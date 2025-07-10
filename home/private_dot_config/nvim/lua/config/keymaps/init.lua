--[[ 
=====================================================================
              Neovim Configuration - Keymap Loader
=====================================================================
This module loads all keymapping configurations.
]]

-- Load core keymaps
require('config.keymaps.core')

-- Load LSP keymaps (these are attached on LSP attach)
require('config.keymaps.lsp')

-- Load plugin-specific keymaps
require('config.keymaps.plugins')

-- Optional: Load user keymaps if they exist
local fs = require('utils.fs')
if fs.file_exists(vim.fn.stdpath('config') .. '/lua/user/keymaps.lua') then
  require('user.keymaps')
end