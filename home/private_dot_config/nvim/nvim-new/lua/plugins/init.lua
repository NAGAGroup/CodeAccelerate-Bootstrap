-- Plugin management via mini.deps
-- Loads all plugin modules

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Load plugin modules in order
now(function()
  require 'plugins.ui'
end)

later(function()
  require 'plugins.treesitter'
end)

later(function()
  require 'plugins.editing'
end)

later(function()
  require 'plugins.navigation'
end)

later(function()
  require 'plugins.git'
end)

later(function()
  require 'plugins.languages'
end)

later(function()
  require 'plugins.cpp_workflow'
end)

later(function()
  require 'plugins.markdown'
end)
