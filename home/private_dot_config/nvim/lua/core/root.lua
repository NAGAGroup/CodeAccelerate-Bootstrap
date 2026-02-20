-- Root detection utilities
-- Priority: LSP root -> git root -> cwd

local M = {}

-- Cache for root directories
M.cache = {}

-- Detect root directory for given buffer
function M.detect(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)

  if path == '' then
    return vim.fn.getcwd()
  end

  -- Check cache
  if M.cache[path] then
    return M.cache[path]
  end

  -- Try LSP root
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  for _, client in ipairs(clients) do
    if client.config.root_dir then
      M.cache[path] = client.config.root_dir
      return client.config.root_dir
    end
  end

  -- Try git root
  local dir = vim.fs.dirname(path)
  local git_root = vim.fs.find('.git', {
    path = dir,
    upward = true,
  })[1]

  if git_root then
    local root = vim.fs.dirname(git_root)
    M.cache[path] = root
    return root
  end

  -- Fallback to cwd
  local cwd = vim.fn.getcwd()
  M.cache[path] = cwd
  return cwd
end

-- Get relative path from root
function M.relative_path(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)

  if path == '' then
    return ''
  end

  local root = M.detect(bufnr)
  local relative = path:gsub('^' .. vim.pesc(root) .. '/', '')
  return relative
end

-- Get filename only
function M.filename(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)

  if path == '' then
    return ''
  end

  return vim.fn.fnamemodify(path, ':t')
end

-- Clear cache for buffer
function M.clear_cache(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)
  M.cache[path] = nil
end

return M
