--[[ 
=====================================================================
              Neovim Configuration - Filesystem Utilities
=====================================================================
This module provides filesystem-related utility functions.
]]

local M = {}

-- Check if a file exists
function M.file_exists(path)
  local stat = (vim.uv or vim.loop).fs_stat(path)
  return stat and stat.type == "file"
end

-- Check if a directory exists
function M.dir_exists(path)
  local stat = (vim.uv or vim.loop).fs_stat(path)
  return stat and stat.type == "directory"
end

-- Get all files in a directory matching a pattern
function M.get_files(path, pattern)
  local files = {}
  if not M.dir_exists(path) then
    return files
  end

  local handle = vim.loop.fs_scandir(path)
  if not handle then
    return files
  end

  local function scan()
    return vim.loop.fs_scandir_next(handle)
  end

  for name, type in scan do
    if type == "file" and (not pattern or name:match(pattern)) then
      table.insert(files, path .. "/" .. name)
    end
  end

  return files
end

return M