-- Neovim v0.12 core keymaps configuration

-- Disable conflicting v0.12 built-in LSP defaults
-- Disable v0.12 built-in <C-s> (insert mode signature help)
-- Conflicts with our <C-k> signature help keymap defined in lsp.lua
vim.keymap.del('i', '<C-s>')

-- Window Navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Window Resize
vim.keymap.set('n', '<C-Up>',    ':resize +2<CR>',          { desc = 'Increase window height' })
vim.keymap.set('n', '<C-Down>',  ':resize -2<CR>',          { desc = 'Decrease window height' })
vim.keymap.set('n', '<C-Left>',  ':vertical resize -2<CR>', { desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { desc = 'Increase window width' })

-- Indentation
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and reselect' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and reselect' })

-- Line Movement
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==',        { desc = 'Move line down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==',        { desc = 'Move line up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv",   { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv",   { desc = 'Move selection up' })

-- Search
vim.keymap.set('n', '<Esc>', ':nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Clipboard
vim.keymap.set('v', 'p', '"_dP', { desc = 'Paste without replacing register' })

-- File Operations
vim.keymap.set('n', '<leader>w', ':w<CR>',  { desc = 'Save file' })
vim.keymap.set('n', '<leader>qq', ':qa<CR>', { desc = 'Quit all' })

-- Buffer Navigation
vim.keymap.set('n', '<S-h>',      ':bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<S-l>',      ':bnext<CR>',     { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>',   { desc = 'Delete buffer' })

-- Terminal
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
