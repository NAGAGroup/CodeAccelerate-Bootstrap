--[[
=====================================================================
                    Neovim Configuration - Plugin Manager
=====================================================================

This file bootstraps and configures lazy.nvim, the plugin manager for
this Neovim configuration.

LAZY.NVIM FEATURES:
  - Automatic installation if not present
  - Lazy loading of plugins for fast startup
  - Lockfile support (lazy-lock.json) for reproducible installs
  - Built-in profiler for debugging slow plugins
  - Parallel plugin installation

PLUGIN ORGANIZATION:
  Plugins are organized into three categories in lua/plugins/:
  
  1. core/   - Essential plugins always loaded
     - coding.lua       : LSP, completion, formatting, linting, DAP
     - editor.lua       : Treesitter, text objects, navigation
     - navigation.lua   : FzfLua, Trouble, search/replace
     - git.lua          : Gitsigns, Diffview
     - ui.lua           : Themes, statusline, bufferline, Snacks
     - file-session-mgmt.lua : Mini.files, persistence
     - snippets.lua     : LuaSnip configuration
  
  2. ext/    - Optional/extension plugins
     - copilot.lua      : GitHub Copilot integration
  
  3. lang/   - Language-specific plugins
     - base.lua         : Markdown (markview)
     - c_lang.lua       : C/C++ (clangd_extensions, cmake-tools)

BOOTSTRAP PROCESS:
  1. Check if lazy.nvim exists in data directory
  2. If not, clone from GitHub (stable branch)
  3. Add to runtime path
  4. Load lazy.nvim with configuration

COMMANDS:
  :Lazy         - Open lazy.nvim UI
  :Lazy sync    - Update all plugins
  :Lazy clean   - Remove unused plugins
  :Lazy profile - Show startup profiling

@see https://github.com/folke/lazy.nvim for lazy.nvim documentation
]]

-- =============================================================================
-- LAZY.NVIM BOOTSTRAP
-- =============================================================================

-- Define the path where lazy.nvim will be installed
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

-- Check if lazy.nvim is already installed
-- vim.uv is preferred (Neovim 0.10+), vim.loop is fallback for older versions
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- Clone lazy.nvim from GitHub if not installed
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none', -- Shallow clone for faster download
    '--branch=stable',     -- Use stable branch for reliability
    lazyrepo,
    lazypath,
  }

  -- Handle clone failure
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

-- Prepend lazy.nvim to runtime path so it can be required
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- LAZY.NVIM CONFIGURATION
-- =============================================================================

local lazy_config = {
  -- Plugin specifications - imports plugin files from these directories
  spec = {
    { import = 'plugins.core' }, -- Essential plugins (LSP, completion, editor, etc.)
    { import = 'plugins.lang' }, -- Language-specific plugins (C/C++, markdown, etc.)
    { import = 'plugins.ext' },  -- Extension plugins (Copilot, etc.)
  },

  -- Default options for all plugins
  defaults = {
    lazy = false,   -- By default, load plugins at startup (not lazily)
    version = false, -- Use latest git commit instead of stable releases
                     -- This provides faster access to bug fixes
  },

  -- Plugin update checker
  checker = {
    enabled = true,  -- Periodically check for plugin updates
    notify = false,  -- Don't show notifications (check :Lazy for updates)
  },

  -- Performance optimizations
  performance = {
    rtp = {
      -- Disable unused built-in plugins for faster startup
      disabled_plugins = {
        'gzip',      -- Editing gzip files (rarely needed)
        'tarPlugin', -- Editing tar files (rarely needed)
        'tohtml',    -- :TOhtml command (rarely needed)
        'tutor',     -- Vim tutor (not needed after learning)
        'zipPlugin', -- Editing zip files (rarely needed)
      },
    },
  },

  -- UI configuration
  ui = {
    border = 'rounded', -- Rounded borders for lazy.nvim UI windows
  },
}

-- =============================================================================
-- INITIALIZATION
-- =============================================================================

-- Initialize lazy.nvim with our configuration
require('lazy').setup(lazy_config)

-- Setup scope.nvim for buffer isolation per tab
-- This keeps buffers organized by tab, reducing buffer clutter
require('scope').setup {}

-- vim: ts=2 sts=2 sw=2 et
