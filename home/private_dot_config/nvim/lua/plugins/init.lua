--[[
=====================================================================
               Neovim Configuration - Plugin Loader
=====================================================================
This module loads all plugin categories and ensures proper ordering.
]]

-- Plugin loading priority (in order):
-- 1. Core plugins (essential functionality)
-- 2. Language plugins (language support, LSP, etc.)
-- 3. UI plugins (visual enhancements)
-- 4. Editor plugins (editing improvements)
-- 5. Tool plugins (development tools)
-- 6. Extension plugins (optional additions)

return {
  -- Core system plugins (highest priority)
  { import = "plugins.core" },
  
  -- Language-specific plugins
  { import = "plugins.lang" },
  
  -- UI enhancement plugins  
  { import = "plugins.ui" },
  
  -- Editor enhancement plugins
  { import = "plugins.editor" },
  
  -- Development tool plugins
  { import = "plugins.tools" },
  
  -- Optional extension plugins
  { import = "plugins.ext" },
}