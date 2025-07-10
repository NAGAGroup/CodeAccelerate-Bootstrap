--[[ 
=====================================================================
              Neovim Configuration - Core Keymaps
=====================================================================
This module defines core Neovim keymaps that aren't related to any 
specific plugin.
]]

local keymap_doc = require('utils').keymap_doc

-- Use the register function for documentation
local map = keymap_doc.register

-- Helper for registering groups of keymaps
local map_group = keymap_doc.register_group

-- Better up/down movement with line wrapping
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true }, "core")
map({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true }, "core")
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true }, "core")
map({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true }, "core")

-- Window navigation with <ctrl> hjkl
map_group('n', {
  { '<C-h>', '<C-w>h', 'Go to Left Window' },
  { '<C-j>', '<C-w>j', 'Go to Lower Window' },
  { '<C-k>', '<C-w>k', 'Go to Upper Window' },
  { '<C-l>', '<C-w>l', 'Go to Right Window' },
}, { remap = true }, "ui")

-- Window resizing with <ctrl> arrow keys
map_group('n', {
  { '<C-Up>', '<cmd>resize +2<cr>', 'Increase Window Height' },
  { '<C-Down>', '<cmd>resize -2<cr>', 'Decrease Window Height' },
  { '<C-Left>', '<cmd>vertical resize -2<cr>', 'Decrease Window Width' },
  { '<C-Right>', '<cmd>vertical resize +2<cr>', 'Increase Window Width' },
}, { silent = true }, "ui")

-- Line movement with Alt+j/k
map('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Line Down' }, "core")
map('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Line Up' }, "core")
map('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Line Down' }, "core")
map('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Line Up' }, "core")
map('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move Selection Down' }, "core")
map('v', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = 'Move Selection Up' }, "core")

map_group('n', {
  { '<S-h>', '<cmd>bprevious<cr>', 'Previous Buffer' },
  { '<S-l>', '<cmd>bnext<cr>', 'Next Buffer' },
  { '[b', '<cmd>bprevious<cr>', 'Previous Buffer' },
  { ']b', '<cmd>bnext<cr>', 'Next Buffer' },
  { '<leader>bb', '<cmd>e #<cr>', 'Switch to Other Buffer' },
  { '<leader>`', '<cmd>e #<cr>', 'Switch to Other Buffer' },
  { '<leader>bd', '<cmd>bdelete<cr>', 'Delete Buffer' },
  { '<leader>bo', function() Snacks.bufdelete.other() end, 'Delete Other Buffers' },
  { '<leader>bD', '<cmd>:bd<cr>', 'Delete Buffer and Window' },
  { '<leader>bn', '<cmd>enew<cr>', 'New Buffer' },
  { '<leader>fn', '<cmd>enew<cr>', 'New File' },
}, { silent = true }, "files")

map({ 'i', 'n' }, '<esc>', '<cmd>noh<cr><esc>', { desc = 'Escape and clear hlsearch' }, "core")

-- Search navigation
map('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next Search Result' }, "core")
map('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' }, "core")
map('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' }, "core")
map('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev Search Result' }, "core")
map('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' }, "core")
map('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' }, "core")

-- Add undo break-points
map('i', ',', ',<c-g>u', { desc = 'Add Undo Break Point' }, "core")
map('i', '.', '.<c-g>u', { desc = 'Add Undo Break Point' }, "core")
map('i', ';', ';<c-g>u', { desc = 'Add Undo Break Point' }, "core")
-- Better indenting
map_group('v', {
  { '<', '<gv', 'Indent Left' },
  { '>', '>gv', 'Indent Right' },
}, { silent = true }, "core")

-- Save file
map({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save File' }, "files")

-- Quick command mode
map('n', ';', ':', { desc = 'Enter Command Mode' }, "core")

-- Terminal mappings
map_group('t', {
  { '<esc><esc>', '<c-\\><c-n>', 'Enter Normal Mode' },
  { '<C-h>', '<cmd>wincmd h<cr>', 'Go to Left Window' },
  { '<C-j>', '<cmd>wincmd j<cr>', 'Go to Lower Window' },
  { '<C-k>', '<cmd>wincmd k<cr>', 'Go to Upper Window' },
  { '<C-l>', '<cmd>wincmd l<cr>', 'Go to Right Window' },
}, { silent = true }, "terminal")

-- Misc utilities
map_group('n', {
  { '<leader>ll', '<cmd>Lazy<cr>', 'Lazy Plugin Manager' },
  { '<leader>h', '<cmd>nohlsearch<CR>', 'Clear Highlights' },
  { '<leader>k', '<cmd>lua require("utils").keymap_doc.show_keymaps()<CR>', 'Show Keymaps' },
}, { silent = true }, "misc")