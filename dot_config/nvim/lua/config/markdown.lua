-- markview.nvim
-- Markdown rendering (n/no/c modes, not insert)
-- Tell markview we handle blink integration manually (in completion.lua)
-- This prevents markview from attempting to register itself as a blink source
-- on VimEnter, which errors if blink.cmp isn't fully loaded yet.
vim.g.markview_blink_loaded = true

require('markview').setup({
  preview = {
    modes = { 'n', 'no', 'c' },
    hybrid_modes = {},
  },
})

-- Keymap
vim.keymap.set('n', '<leader>tm', '<CMD>Markview<CR>', { desc = 'Toggle markdown preview' })

-- SchemaStore.nvim: no setup needed here.
-- Already wired in lsp/jsonls.lua and lsp/yamlls.lua.
