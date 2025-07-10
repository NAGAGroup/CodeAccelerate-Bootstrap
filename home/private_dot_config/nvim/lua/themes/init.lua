--[[ 
=====================================================================
               Neovim Configuration - Theme Management
=====================================================================
This module handles theme loading and provides theme switching functionality.
]]

local M = {}

-- Load theme customization module
local theme_customizer = require('themes.customization')

-- Current theme state
M.current_theme = nil
M.theme_mode = 'dark' -- 'dark' or 'light'

-- List of available themes
M.themes = {
  -- Dark themes
  dark = {
    'catppuccin',
    'tokyonight',
    'nightfox',
    'kanagawa',
    'onedark',
    'gruvbox',
  },
  
  -- Light themes
  light = {
    'catppuccin-latte',
    'tokyonight-day',
    'dayfox',
    'gruvbox-light',
  }
}

-- Set the current theme
function M.set_theme(theme)
  if not theme then
    return
  end
  
  -- Store current theme
  M.current_theme = theme
  
  -- Apply theme customization
  theme_customizer.apply_customization(theme)
  
  -- Apply the theme
  vim.cmd.colorscheme(theme)
  
  -- Determine if it's a light or dark theme
  if theme:match('latte') or theme:match('light') or theme:match('day') then
    M.theme_mode = 'light'
    vim.opt.background = 'light'
  else
    M.theme_mode = 'dark'
    vim.opt.background = 'dark'
  end
  
  -- Save the theme to a cache file
  local cache_file = vim.fn.stdpath('data') .. '/theme_cache.lua'
  local file = io.open(cache_file, 'w')
  if file then
    file:write(string.format('return { theme = "%s", mode = "%s" }', theme, M.theme_mode))
    file:close()
  end
  
  -- Notify about the change
  vim.notify('Theme changed to ' .. theme)
end

-- Toggle between light and dark themes
function M.toggle_theme_mode()
  local themes = M.theme_mode == 'dark' and M.themes.light or M.themes.dark
  local theme = themes[1] -- Default to first theme in list
  
  M.set_theme(theme)
end

-- Initialize theme system
function M.setup()
  -- Try to load theme from cache
  local cache_file = vim.fn.stdpath('data') .. '/theme_cache.lua'
  local success, cache = pcall(dofile, cache_file)
  
  if success and cache and cache.theme then
    M.set_theme(cache.theme)
  else
    -- Default theme
    M.set_theme('tokyonight')
  end
  
  -- Load cached theme data
  for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache or '')) do
    if vim.g.base46_cache then
      dofile(vim.g.base46_cache .. v)
    end
  end
end

return M