--[[ 
=====================================================================
                 Neovim Configuration - UI Utilities
=====================================================================
This module provides UI-related utility functions.
]]

local M = {}

-- Define highlight groups
function M.set_highlight(group, options)
  vim.api.nvim_set_hl(0, group, options)
end

-- Create a notification with default styling
function M.notify(msg, level, opts)
  opts = opts or {}
  level = level or vim.log.levels.INFO
  vim.notify(msg, level, opts)
end

-- Format an item as a string with proper escaping
function M.format_item(item)
  if type(item) == "string" then
    return item
  elseif type(item) == "table" then
    return vim.inspect(item)
  else
    return tostring(item)
  end
end

return M