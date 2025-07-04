local M = {}

M._keys = nil

function M.get()
  if M._keys then
    return M._keys
  end
    -- stylua: ignore
    M._keys =  {
      { '<leader>cl', '<cmd>LspInfo<CR>', desc = 'Lsp Info' },
      { 'gd', vim.lsp.buf.definition, desc = 'Goto Definition' },
      { 'gr', vim.lsp.buf.references, desc = 'References' },
      { 'gI', vim.lsp.buf.implementation, desc = 'Goto Implementation' },
      { 'gy', vim.lsp.buf.type_definition, desc = 'Goto Type Definition' },
      { 'gD', vim.lsp.buf.declaration, desc = 'Goto Declaration' },
      { 'K', vim.lsp.buf.hover, desc = 'Hover' },
      { 'gK', vim.lsp.buf.signature_help, desc = 'Signature Help' },
      { '<c-k>', vim.lsp.buf.signature_help, mode = 'i', desc = 'Signature Help' },
      { '<leader>ca', vim.lsp.buf.code_action, desc = 'Code Action', mode = { 'n', 'v' } },
      { '<leader>cc', vim.lsp.codelens.run, desc = 'Run Codelens' },
      { '<leader>cC', vim.lsp.codelens.refresh, desc = 'Refresh Codelens' },
      { '<leader>cr', vim.lsp.buf.rename, desc = 'Rename' },
    }

  return M._keys
end

function M.on_attach(_, buffer)
  local keymaps = M.get()

  for _, keymap in ipairs(keymaps) do
    local lhs = keymap[1]
    local rhs = keymap[2]
    local opts = {}
    opts.desc = keymap.desc or ('LSP: ' .. (type(rhs) == 'string' and rhs or lhs))
    opts.silent = opts.silent ~= false
    opts.buffer = buffer
    opts.nowait = opts.nowait ~= false
    vim.keymap.set(keymap.mode or 'n', lhs, rhs, opts)
  end
end

return M
