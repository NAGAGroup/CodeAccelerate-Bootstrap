-- Treesitter configuration (new nvim-treesitter API)
--
-- Troubleshooting:
--   :checkhealth nvim-treesitter  - Verify parser installation status
--   :TSInstall <lang>             - Manually install a parser
--   :TSUpdate                     - Update all installed parsers
--   :Inspect                      - Show highlight groups under cursor

local add = MiniDeps.add

add({
  source = 'nvim-treesitter/nvim-treesitter',
  hooks = {
    post_checkout = function()
      vim.cmd('TSUpdate')
    end,
  },
})

add('nvim-treesitter/nvim-treesitter-textobjects')

-- Ensure these parsers are installed
local ensure_installed = {
  'c', 'cpp', 'cmake', 'python', 'javascript', 'typescript', 'tsx',
  'bash', 'nu', 'json', 'yaml', 'toml',
  'markdown', 'markdown_inline',
  'lua', 'vim', 'vimdoc', 'query',
}

-- Install any missing parsers
local installed = require('nvim-treesitter.config').get_installed()
local installed_set = {}
for _, lang in ipairs(installed) do
  installed_set[lang] = true
end

local to_install = {}
for _, lang in ipairs(ensure_installed) do
  if not installed_set[lang] then
    table.insert(to_install, lang)
  end
end

if #to_install > 0 then
  require('nvim-treesitter.install').install(to_install)
end

-- Enable treesitter highlighting for all buffers with a parser
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter_highlight', { clear = true }),
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    if not ft or ft == '' then return end
    local lang = vim.treesitter.language.get_lang(ft) or ft
    if pcall(vim.treesitter.language.add, lang) then
      pcall(vim.treesitter.start, ev.buf, lang)
    end
  end,
})

-- Enable treesitter-based indentation
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter_indent', { clear = true }),
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    if not ft or ft == '' then return end
    local lang = vim.treesitter.language.get_lang(ft) or ft
    if pcall(vim.treesitter.language.add, lang) then
      pcall(function()
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end)
    end
  end,
})

-- Textobjects (requires nvim-treesitter-textobjects)
local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')

vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_previous)

-- Incremental selection
vim.keymap.set('n', '<C-space>', function()
  vim.treesitter.incremental_selection.init_selection()
end, { desc = 'Init treesitter selection' })
