-- Plugin management via mini.deps
-- Loads all plugin modules

local add = MiniDeps.add

-- Load plugin modules in order
require 'plugins.ui'
require 'plugins.treesitter'
require 'plugins.editing'
require 'plugins.testing'
require 'plugins.navigation'
require 'plugins.git'
require 'plugins.languages'
require 'plugins.cpp_workflow'
require 'plugins.markdown'
