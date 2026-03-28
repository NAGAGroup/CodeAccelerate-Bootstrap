-- Plugin management via mini.deps
-- Loads all plugin modules

local add = MiniDeps.add

-- Load plugin modules in order
-- navigation (snacks.nvim) must load EARLY so it initializes first
require 'plugins.navigation'
require 'plugins.ui'
require 'plugins.copilot'
require 'plugins.treesitter'
require 'plugins.editing'
require 'plugins.cpp_workflow'
require 'plugins.cmake'
require 'plugins.testing'
require 'plugins.git'
require 'plugins.languages'
require 'plugins.markdown'
