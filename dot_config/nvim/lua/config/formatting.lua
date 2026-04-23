-- =============================================================================
-- formatting.lua — Code formatting via conform.nvim
-- =============================================================================

require('conform').setup({
  -- Per-filetype formatter assignments
  formatters_by_ft = {
    python                          = { 'ruff_format' },
    javascript                      = { 'biome' },
    javascriptreact                 = { 'biome' },
    typescript                      = { 'biome' },
    typescriptreact                 = { 'biome' },
    json                            = { 'biome' },
    sh                              = { 'shfmt' },
    bash                            = { 'shfmt' },
    yaml                            = { 'prettier' },
    toml                            = { 'taplo' },
    lua                             = { 'stylua' },
  },

  -- Format on save — gated by toggle system globals
  -- Return nil to disable, table to enable with options
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return  -- disable (return nil)
    end
    return { timeout_ms = 500, lsp_format = 'fallback' }
  end,
})

-- Manual format keymap: <leader>cf
vim.keymap.set({ 'n', 'v' }, '<leader>cf', function()
  require('conform').format({
    async      = true,
    lsp_format = 'fallback',
    timeout_ms = 500,
  })
end, { desc = 'Format: format buffer/selection' })
