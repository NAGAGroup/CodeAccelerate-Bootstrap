-- Treesitter configuration (Neovim 0.12 native treesitter)
-- Highlighting and folding are enabled natively — no plugin required.
--
-- Troubleshooting:
--   :TSInstall <lang>  - Install a parser (via nvim-treesitter-textobjects or tree-sitter CLI)
--   :Inspect           - Show highlight groups under cursor
--   :checkhealth       - Verify treesitter parser status

local add = MiniDeps.add

add({
  source = 'nvim-treesitter/nvim-treesitter-textobjects',
  checkout = 'main',
})

-- Neovim 0.12 bundles these parsers: c, lua, markdown, markdown_inline, vim, vimdoc, query
-- Run :TSInstall for additional parsers needed by this config:
--   cpp, cmake, python, javascript, typescript, tsx, bash, nu, json, yaml, toml

-- Textobjects (requires nvim-treesitter-textobjects)
local ok, err = pcall(function()
  require('nvim-treesitter-textobjects').setup({
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  })
end)
if not ok then
  vim.notify("nvim-treesitter-textobjects setup failed: " .. tostring(err), vim.log.levels.WARN)
end

local ts_repeat_move = require('nvim-treesitter-textobjects.repeatable_move')

vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_previous)

-- Incremental selection
vim.keymap.set('n', '<C-space>', function()
  vim.treesitter.incremental_selection.init_selection()
end, { desc = 'Init treesitter selection' })
