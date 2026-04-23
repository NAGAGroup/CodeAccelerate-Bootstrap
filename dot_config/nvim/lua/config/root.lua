-- =============================================================================
-- root.lua — Project root detection utility
-- =============================================================================
-- Priority chain: LSP root → Git root → cwd
-- Results are cached per buffer path to avoid repeated filesystem calls
-- =============================================================================

local M = {}

-- Per-buffer root cache
local _cache = {}

-- Detect the project root for the given buffer (defaults to current buffer)
-- Returns: string (absolute path to root directory)
function M.detect(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)

  -- Return cached result if available
  if _cache[path] then
    return _cache[path]
  end

  local root

  -- Priority 1: LSP root (first attached client with a root_dir)
  -- Use vim.lsp.get_clients() — get_active_clients() is deprecated in v0.12
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client.root_dir then
      root = client.root_dir
      break
    end
  end

  -- Priority 2: Git root via native v0.12 vim.fs.root()
  if not root then
    root = vim.fs.root(bufnr, { '.git' })
  end

  -- Priority 3: Current working directory
  if not root then
    root = vim.uv.cwd()
  end

  _cache[path] = root
  return root
end

-- Get the path of the current buffer relative to its project root
-- Returns: string (relative path, or absolute if outside root)
function M.relative_path(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local abs = vim.api.nvim_buf_get_name(bufnr)
  local root = M.detect(bufnr)
  if root and abs:sub(1, #root) == root then
    return abs:sub(#root + 2)  -- strip root/ prefix
  end
  return abs
end

-- Get just the filename of the current buffer (no path)
-- Returns: string (filename only)
function M.filename(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
end

-- Clear the root cache (useful after changing directories)
function M.clear_cache()
  _cache = {}
end

return M
