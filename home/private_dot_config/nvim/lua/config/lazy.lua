--[[
=====================================================================
               Neovim Configuration - Lazy Plugin Manager
=====================================================================
]]

-- Bootstrap lazy.nvim installation if it doesn't exist
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

 -- Import plugin specification from plugins module
 local spec = { { import = "plugins" } }

-- Add user plugins if they exist
local user_plugins_file = vim.fn.stdpath("config") .. "/lua/user/plugins.lua"
local fs_stat = vim.uv or vim.loop
if fs_stat.fs_stat(user_plugins_file) then
  vim.list_extend(spec, { { import = "user.plugins" } })
end

-- Lazy.nvim options
local lazy_opts = {
  ui = {
    border = "rounded",
    title = "Lazy Plugin Manager",
    title_pos = "center",
  },
  install = {
    colorscheme = { "tokyonight", "catppuccin", "habamax" },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  checker = {
    enabled = true,
    notify = false,
    frequency = 3600 * 24, -- Check once per day
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
}

-- Initialize lazy.nvim
require("lazy").setup(spec, lazy_opts)
-- Define lazy.nvim configuration
local lazy_config = {
  spec = {
    { import = 'plugins.core' }, -- core plugins
    { import = 'plugins.lang' }, -- language-specific plugins
    { import = 'plugins.ext' }, -- extension plugins, not universally useful
  },
  defaults = {
    lazy = false, -- By default, load plugins at startup
    version = false, -- Use latest git commit
  },
  checker = {
    enabled = true, -- Check for plugin updates
    notify = false, -- Don't notify about updates
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
  ui = {
    border = 'rounded', -- Rounded borders for UI elements
  },
}

-- Initialize lazy.nvim with our configuration
require('lazy').setup(lazy_config)

-- Setup scope.nvim (buffer isolation)
require('scope').setup {}

-- vim: ts=2 sts=2 sw=2 et
