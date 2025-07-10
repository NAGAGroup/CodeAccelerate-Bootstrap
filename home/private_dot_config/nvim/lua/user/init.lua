--[[ 
=====================================================================
               Neovim Configuration - User Overrides
=====================================================================
This module handles user-specific overrides that won't be tracked by git.
Users can add their custom configuration here without modifying the core files.
]]

local M = {}

-- Load user plugins if they exist
local fs = require('utils.fs')
local user_plugins_file = vim.fn.stdpath('config') .. '/lua/user/plugins.lua'

function M.load()
  -- Load user options if they exist
  local options_file = vim.fn.stdpath('config') .. '/lua/user/options.lua'
  if fs.file_exists(options_file) then
    require('user.options')
  end
  
  -- User plugin overrides are handled in lazy.nvim's setup
  
  -- Load user keymaps if they exist
  local keymaps_file = vim.fn.stdpath('config') .. '/lua/user/keymaps.lua'
  if fs.file_exists(keymaps_file) then
    require('user.keymaps')
  end
  
  -- Load user autocommands if they exist
  local autocmds_file = vim.fn.stdpath('config') .. '/lua/user/autocmds.lua'
  if fs.file_exists(autocmds_file) then
    require('user.autocmds')
  end
end

return M