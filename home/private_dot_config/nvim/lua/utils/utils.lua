--[[ 
=====================================================================
                   Neovim Configuration - Core Utilities
=====================================================================
This module provides common utility functions used across the Neovim
configuration. It includes helpers for plugin management, file operations,
UI enhancements, and system interactions.

Usage:
  local utils = require('plugins.core.utils')
  -- or use the global instance
  NvimLuaUtils.merge_defaults(defaults, config)
]]

local M = {}

-- ============================================================================
-- CONFIGURATION AND SETUP UTILITIES
-- ============================================================================

-- Merges default options with user config while preserving nested tables
function M.merge_defaults(defaults, user_config)
  return vim.tbl_deep_extend('force', defaults, user_config or {})
end

-- Safely require a module with error handling
function M.safe_require(module_name)
  local ok, module = pcall(require, module_name)
  if not ok then
    vim.notify('Could not load module: ' .. module_name, vim.log.levels.WARN)
    return nil
  end
  return module
end

-- Check if a plugin is installed and loaded
function M.is_plugin_available(plugin_name)
  local ok, config = pcall(require, 'lazy.core.config')
  if not ok then
    return false
  end
  return config.plugins[plugin_name] ~= nil
end

-- ============================================================================
-- FILE AND PATH UTILITIES
-- ============================================================================

-- Find a file in parent directories (useful for project detection)
function M.find_file_in_parent(filename, start_dir)
  start_dir = start_dir or vim.fn.expand '%:p:h'
  local root_dir = vim.fn.finddir(filename, start_dir .. ';')
  return root_dir ~= '' and root_dir or nil
end

-- Get the root directory for operations (respects vim.g.root_spec)
function M.get_root()
  -- Define default patterns if not specified in vim.g.root_spec
  -- Use combination of common project markers and the old get_project_root patterns
  local default_patterns = {
    'lsp',
    { '.git', 'package.json', 'Cargo.toml', 'pyproject.toml', 'Makefile', 'CMakeLists.txt', 'lua' },
    'cwd',
  }
  local root_patterns = vim.g.root_spec or default_patterns

  -- Helper to find root by lsp
  local function get_lsp_root()
    local buf = vim.api.nvim_get_current_buf()
    local ignore = vim.g.root_lsp_ignore or {}

    -- Check active clients
    for _, client in pairs(vim.lsp.get_clients { bufnr = buf }) do
      if client.config.root_dir and not vim.tbl_contains(ignore, client.name) then
        return client.config.root_dir
      end
    end
    return nil
  end

  -- Helper to find root by patterns
  local function get_pattern_root(patterns)
    if type(patterns) == 'string' then
      return M.find_file_in_parent(patterns)
    end

    local util = M.safe_require 'lspconfig.util'
    if not util then
      return nil
    end

    local path = vim.api.nvim_buf_get_name(0)
    if path == '' then
      path = vim.fn.getcwd()
    end

    return util.root_pattern(unpack(patterns))(path)
  end

  -- Try to find root in various ways based on spec
  if type(root_patterns) == 'table' then
    for _, spec in ipairs(root_patterns) do
      if spec == 'lsp' then
        local root = get_lsp_root()
        if root then
          return root
        end
      elseif spec == 'cwd' then
        return vim.fn.getcwd()
      elseif type(spec) == 'table' then
        local root = get_pattern_root(spec)
        if root then
          return root
        end
      end
    end
  end

  return vim.fn.getcwd()
end

-- Backward compatibility alias for get_project_root
M.get_project_root = M.get_root

-- ============================================================================
-- UI HELPERS
-- ============================================================================

-- Create consistent bordered window options
function M.bordered_window_opts(title)
  return {
    border = 'rounded',
    title = title and ' ' .. title .. ' ' or nil,
    title_pos = 'center',
    style = 'minimal',
  }
end

-- Format LSP diagnostic virtual text
function M.format_diagnostic(diagnostic)
  local icon = '●'
  local severity_map = {
    [1] = 'Error',
    [2] = 'Warn',
    [3] = 'Info',
    [4] = 'Hint',
  }

  local severity = severity_map[diagnostic.severity] or 'Unknown'
  return string.format('%s %s: %s', icon, severity, diagnostic.message)
end

-- ============================================================================
-- KEYMAPPING UTILITIES
-- ============================================================================

-- Register multiple keymaps with the same options
function M.map_group(mode, maps, options)
  options = options or { silent = true }
  for _, map in ipairs(maps) do
    local lhs, rhs, desc = unpack(map)
    local opts = vim.tbl_extend('force', options, { desc = desc })
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- Conditionally create keymaps based on condition
function M.conditional_map(condition, mode, lhs, rhs, opts)
  if type(condition) == 'function' and not condition() then
    return
  elseif not condition then
    return
  end

  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ============================================================================
-- PLUGIN-SPECIFIC CONFIGURATION HELPERS
-- ============================================================================

-- Detect formatter availability for Conform.nvim
function M.has_formatter(formatter_name)
  local conform = M.safe_require 'conform'
  if not conform then
    return false
  end

  return conform.formatters[formatter_name] ~= nil
end

-- Check if LSP server is available
function M.has_lsp(server_name)
  local lspconfig = M.safe_require 'lspconfig'
  if not lspconfig then
    return false
  end

  return lspconfig[server_name] ~= nil
end

-- ============================================================================
-- SYSTEM INTERACTION
-- ============================================================================

-- Run system command and return output
function M.system(cmd)
  local output = vim.fn.system(cmd)
  return vim.v.shell_error == 0 and output:gsub('%s+$', '') or nil
end

-- Detect if running in SSH session
function M.is_ssh()
  return vim.env.SSH_TTY ~= nil
end

-- Get OS info
function M.get_os()
  if vim.fn.has 'win32' == 1 then
    return 'windows'
  elseif vim.fn.has 'macunix' == 1 then
    return 'mac'
  else
    return 'linux'
  end
end

-- ============================================================================
-- PLUGIN FEATURE DETECTION
-- ============================================================================

-- Check if treesitter parser is installed
function M.has_treesitter_parser(lang)
  local parsers = M.safe_require 'nvim-treesitter.parsers'
  if not parsers then
    return false
  end

  return parsers.has_parser(lang)
end

-- Check if a certain LSP capability is supported
function M.has_lsp_capability(capability, client_id)
  local clients = vim.lsp.get_clients { buffer = 0 }
  if #clients == 0 then
    return false
  end

  local client = client_id and vim.lsp.get_client_by_id(client_id) or clients[1]
  return client and client.supports_method(capability) or false
end

-- ============================================================================
-- BUFFER AND WINDOW MANAGEMENT
-- ============================================================================

-- Save current buffer state (cursor position, folds, etc)
function M.save_buffer_state()
  local cursor = vim.fn.getcurpos()
  local view = vim.fn.winsaveview()
  return { cursor = cursor, view = view }
end

-- Restore buffer state
function M.restore_buffer_state(state)
  if not state then
    return
  end
  vim.fn.setpos('.', state.cursor)
  vim.fn.winrestview(state.view)
end

-- ============================================================================
-- FEATURE DETECTION AND ENVIRONMENT CHECKING
-- ============================================================================

-- Check if neovim supports a feature
function M.has_feature(feature)
  local version_info = vim.version()

  local feature_map = {
    ['smoothscroll'] = { major = 0, minor = 10, patch = 0 },
    ['extsigns'] = { major = 0, minor = 10, patch = 0 },
    ['statuscolumn'] = { major = 0, minor = 9, patch = 0 },
  }

  local req = feature_map[feature]
  if not req then
    return false
  end

  if version_info.major > req.major then
    return true
  elseif version_info.major == req.major and version_info.minor > req.minor then
    return true
  elseif version_info.major == req.major and version_info.minor == req.minor and version_info.patch >= req.patch then
    return true
  end

  return false
end

-- ============================================================================
-- DEBUGGING UTILITIES
-- ============================================================================

-- Pretty print a Lua table with optional name
function M.dump(o, name)
  if name then
    print(name .. ' = ')
  end

  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then
        k = '"' .. k .. '"'
      end
      s = s .. '[' .. k .. '] = ' .. M.dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

-- Log a message with timestamp
function M.log(level, message, title)
  local timestamp = os.date '%H:%M:%S'
  local formatted_message = string.format('[%s] %s', timestamp, message)

  if title then
    formatted_message = title .. ': ' .. formatted_message
  end

  vim.notify(formatted_message, level or vim.log.levels.INFO)
end

-- ============================================================================
-- PERFORMANCE UTILITIES
-- ============================================================================

-- Simple performance timing utility
function M.time_function(func, name)
  name = name or 'Function'
  local start_time = vim.loop.hrtime()

  local result = func()

  local end_time = vim.loop.hrtime()
  local elapsed = (end_time - start_time) / 1000000 -- Convert to milliseconds

  M.log(vim.log.levels.INFO, string.format('%s took %.2f ms', name, elapsed))

  return result
end

-- Debounce function calls
function M.debounce(ms, fn)
  local timer = vim.uv.new_timer()
  return function(...)
    local argv = { ... }
    timer:start(ms, 0, function()
      timer:stop()
      vim.schedule_wrap(fn)(unpack(argv))
    end)
  end
end

return M
