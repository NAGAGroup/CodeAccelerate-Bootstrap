-- Create global instance for easy access
_G.NvimLuaUtils = require 'utils.utils'

-- Load core Neovim configurations
require 'config.options' -- Options and settings
require 'config.autocmds' -- Auto commands

-- Bootstrap lazy.nvim and load plugins
require 'config.lazy'

-- Load keymaps after plugins to ensure all plugin-specific mappings work
require 'config.keymaps' -- Key mappings

-- Load cached theme data
for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
  dofile(vim.g.base46_cache .. v)
end
