--[[
=====================================================================
            Neovim Configuration - Project Settings
=====================================================================
This module handles project-specific configuration and settings.
It looks for .nvim.lua files in project directories and loads them.
]]

local M = {}

-- Cache for loaded project configs
M.loaded_projects = {}

-- Get project root directory
function M.get_project_root()
  local util = require('lspconfig.util')
  local path = vim.fn.expand('%:p:h')
  
  -- Common project root markers
  local root_patterns = {
    '.git',
    'package.json',
    'Cargo.toml',
    'pyproject.toml',
    'Makefile',
    'CMakeLists.txt',
  }
  
  return util.find_git_ancestor(path) or
         util.root_pattern(unpack(root_patterns))(path) or
         path
end

-- Load project configuration if it exists
function M.load_project_config()
  -- Get project root
  local project_root = M.get_project_root()
  
  -- Check if already loaded
  if M.loaded_projects[project_root] then
    return
  end
  
  -- Project config file path
  local config_file = project_root .. '/.nvim.lua'
  
  -- Check if file exists
  local f = io.open(config_file, 'r')
  if f then
    f:close()
    
    -- Load project config
    local success, err = pcall(dofile, config_file)
    if success then
      vim.notify("Loaded project configuration from " .. config_file, vim.log.levels.INFO)
      M.loaded_projects[project_root] = true
    else
      vim.notify("Error loading project configuration: " .. err, vim.log.levels.ERROR)
    end
  end
end

-- Initialize project settings and autocommands
function M.setup()
  -- Create autocmd to load project config when entering a buffer
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = "*",
    callback = function()
      M.load_project_config()
    end,
    desc = "Load project-specific settings",
  })
end

return M