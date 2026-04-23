-- =============================================================================
-- LuaSnip — snippet engine (loads eagerly, no InsertEnter needed)
-- =============================================================================
local ls = require('luasnip')

-- Load VSCode-format snippets from friendly-snippets
require('luasnip.loaders.from_vscode').lazy_load()

-- Snippet navigation keymaps (insert + select mode)
vim.keymap.set({ 'i', 's' }, '<C-k>', function()
  if ls.expand_or_jumpable() then ls.expand_or_jump() end
end, { silent = true, desc = 'Snippet: expand or jump forward' })

vim.keymap.set({ 'i', 's' }, '<C-j>', function()
  if ls.jumpable(-1) then ls.jump(-1) end
end, { silent = true, desc = 'Snippet: jump backward' })

vim.keymap.set({ 'i', 's' }, '<C-l>', function()
  if ls.choice_active() then ls.change_choice(1) end
end, { silent = true, desc = 'Snippet: next choice' })

-- =============================================================================
-- blink.cmp — completion engine
-- =============================================================================
require('blink.cmp').setup({

      -- Snippet engine: LuaSnip
      snippets = {
        preset = 'luasnip',
      },

      -- Completion sources
      sources = {
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
        -- markview provides completions in markdown (link/callout syntax)
        per_filetype = {
          markdown = { 'markview', 'lsp', 'path', 'snippets', 'buffer' },
        },
        providers = {
          lazydev = {
            name         = 'LazyDev',
            module       = 'lazydev.integrations.blink',
            score_offset = 100,
          },
          markview = {
            name   = 'markview',
            module = 'blink-markview',
          },
        },
      },

      -- Keymaps
      keymap = {
        preset        = 'none',
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>']     = { 'hide', 'fallback' },
        ['<C-y>']     = { 'select_and_accept' },
        ['<C-p>']     = { 'select_prev', 'fallback' },
        ['<C-n>']     = { 'select_next', 'fallback' },
        ['<C-b>']     = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>']     = { 'scroll_documentation_down', 'fallback' },
        ['<Tab>']     = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>']   = { 'select_prev', 'snippet_backward', 'fallback' },
      },

      -- Fuzzy matching (pure Lua — no Rust binary required)
      fuzzy = {
        implementation = 'lua',
        prebuilt_binaries = {
          download = false,
        },
      },

      -- Completion menu
      completion = {
        menu = {
          border = 'rounded',
        },
        documentation = {
          auto_show          = true,
          auto_show_delay_ms = 200,
          window = {
            border = 'rounded',
          },
        },
      },

      -- Signature help
      signature = {
        enabled = true,
        window = {
          border = 'rounded',
        },
      },

})
