--[[
=====================================================================
                    Neovim Configuration - Key Mappings
=====================================================================

This file defines all global key mappings for the Neovim configuration.
Mappings are organized by category for easy reference and maintenance.

CONVENTIONS:
  - <leader> is set to Space (defined in config/options.lua)
  - <localleader> is set to \ (backslash)
  - Most mappings use 'silent = true' to avoid command line noise
  - Descriptions are provided for which-key integration

MAPPING CATEGORIES:
  - Navigation     : Window, buffer, and cursor movement
  - Editing        : Text manipulation, indentation, commenting
  - Search         : Search result navigation, clearing highlights
  - LSP/Diagnostic : Code diagnostics, formatting
  - UI Toggles     : Toggle various UI features (via Snacks.toggle)
  - Git            : Lazygit integration, git browse
  - Terminal       : Terminal toggle and navigation
  - Tabs/Windows   : Tab and window management

LEADER KEY GROUPS (for which-key):
  <leader>b  - Buffer operations
  <leader>c  - Code/LSP operations
  <leader>d  - Debug operations
  <leader>f  - File/Find operations
  <leader>g  - Git operations
  <leader>q  - Quit/Session operations
  <leader>s  - Search operations (handled in navigation.lua)
  <leader>u  - UI toggle operations
  <leader>w  - Window operations
  <leader>x  - Diagnostics/Quickfix operations
  <leader><tab> - Tab operations

NOTE: LSP-specific keymaps are defined in config/lsp_keymaps.lua
NOTE: Plugin-specific keymaps are defined in their respective plugin files

@see config.lsp_keymaps for LSP keybindings
@see plugins.core.navigation for search keymaps
]]

local map = vim.keymap.set

-- =============================================================================
-- NAVIGATION - Cursor and Line Movement
-- =============================================================================

-- Better up/down movement that respects wrapped lines
-- When no count is given (v:count == 0), use gj/gk to move by display lines
-- This makes navigation more intuitive when lines are wrapped
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
map({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
map({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })

-- =============================================================================
-- NAVIGATION - Window Movement
-- =============================================================================

-- Move between windows using Ctrl + hjkl (like vim navigation)
-- remap = true allows these to work with other plugins that remap <C-w>
map('n', '<C-h>', '<C-w>h', { desc = 'Go to Left Window', remap = true })
map('n', '<C-j>', '<C-w>j', { desc = 'Go to Lower Window', remap = true })
map('n', '<C-k>', '<C-w>k', { desc = 'Go to Upper Window', remap = true })
map('n', '<C-l>', '<C-w>l', { desc = 'Go to Right Window', remap = true })

-- Resize windows using Ctrl + Arrow keys
-- Useful for quickly adjusting split sizes
map('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
map('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

-- =============================================================================
-- EDITING - Line Movement
-- =============================================================================

-- Move lines up/down with Alt+j/k
-- Works in normal, insert, and visual modes
-- Supports count prefix (e.g., 3<A-j> moves line 3 lines down)
map('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Down' })
map('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Up' })
map('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Down' })
map('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Up' })
map('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move Down' })
map('v', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = 'Move Up' })

-- =============================================================================
-- NAVIGATION - Buffer Management
-- =============================================================================

-- Quick buffer navigation with Shift+h/l
-- Also available with [b and ]b for consistency with other bracket mappings
map('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
map('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
map('n', '[b', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
map('n', ']b', '<cmd>bnext<cr>', { desc = 'Next Buffer' })

-- Buffer operations under <leader>b
map('n', '<leader>bb', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })
map('n', '<leader>`', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })

-- Buffer deletion using Snacks.bufdelete for better handling
-- Snacks.bufdelete properly handles window layouts when closing buffers
map('n', '<leader>bd', function()
  Snacks.bufdelete()
end, { desc = 'Delete Buffer' })
map('n', '<leader>bo', function()
  Snacks.bufdelete.other()
end, { desc = 'Delete Other Buffers' })
map('n', '<leader>bD', '<cmd>:bd<cr>', { desc = 'Delete Buffer and Window' })

-- =============================================================================
-- EDITING - Search and Escape
-- =============================================================================

-- Clear search highlighting on Escape
-- Also works in insert and select modes for convenience
map({ 'i', 'n', 's' }, '<esc>', function()
  vim.cmd 'noh'
  return '<esc>'
end, { expr = true, desc = 'Escape and Clear hlsearch' })

-- Full screen redraw with search/diff clearing
-- Taken from Neovim runtime, provides a clean slate
map('n', '<leader>ur', '<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>', { desc = 'Redraw / Clear hlsearch / Diff Update' })

-- Saner n/N behavior from vim-galore
-- n always goes forward, N always goes backward, regardless of / or ? search
-- 'zv' opens folds to show the match
map('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next Search Result' })
map('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
map('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
map('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev Search Result' })
map('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })
map('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })

-- =============================================================================
-- EDITING - Undo Break Points
-- =============================================================================

-- Add undo break-points at punctuation
-- This allows more granular undo in insert mode (undo word by word)
map('i', ',', ',<c-g>u')
map('i', '.', '.<c-g>u')
map('i', ';', ';<c-g>u')

-- =============================================================================
-- FILE OPERATIONS
-- =============================================================================

-- Save file with Ctrl+s (works in all modes)
map({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save File' })

-- Open keywordprg (usually man page or help)
map('n', '<leader>K', '<cmd>norm! K<cr>', { desc = 'Keywordprg' })

-- =============================================================================
-- EDITING - Indentation
-- =============================================================================

-- Better indenting in visual mode
-- Keeps selection after indent/dedent for repeated operations
map('v', '<', '<gv')
map('v', '>', '>gv')

-- =============================================================================
-- EDITING - Commenting
-- =============================================================================

-- Add comment below/above current line
-- Creates a new line, comments it, and positions cursor for typing
map('n', 'gco', 'o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Below' })
map('n', 'gcO', 'O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Above' })

-- =============================================================================
-- PLUGIN MANAGEMENT
-- =============================================================================

-- Open Lazy plugin manager
map('n', '<leader>l', '<cmd>Lazy<cr>', { desc = 'Lazy' })

-- =============================================================================
-- FILE OPERATIONS
-- =============================================================================

-- Create new empty file
map('n', '<leader>fn', '<cmd>enew<cr>', { desc = 'New File' })

-- =============================================================================
-- DIAGNOSTICS - Location and Quickfix Lists
-- =============================================================================

-- Toggle location list (buffer-local diagnostics/search results)
map('n', '<leader>xl', function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = 'Location List' })

-- Toggle quickfix list (project-wide diagnostics/search results)
map('n', '<leader>xq', function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = 'Quickfix List' })

-- Navigate quickfix items with [q and ]q
map('n', '[q', vim.cmd.cprev, { desc = 'Previous Quickfix' })
map('n', ']q', vim.cmd.cnext, { desc = 'Next Quickfix' })

-- =============================================================================
-- CODE OPERATIONS - Formatting
-- =============================================================================

-- Format current buffer or selection using Conform
map({ 'n', 'v' }, '<leader>cf', function()
  require('conform').format { lsp_fallback = true }
end, { desc = 'Format' })

-- =============================================================================
-- DIAGNOSTICS - Navigation
-- =============================================================================

-- Helper function for diagnostic navigation
-- Supports filtering by severity (ERROR, WARN, etc.)
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go { severity = severity }
  end
end

-- Show diagnostic float for current line
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })

-- Navigate all diagnostics
map('n', ']d', diagnostic_goto(true), { desc = 'Next Diagnostic' })
map('n', '[d', diagnostic_goto(false), { desc = 'Prev Diagnostic' })

-- Navigate only errors
map('n', ']e', diagnostic_goto(true, 'ERROR'), { desc = 'Next Error' })
map('n', '[e', diagnostic_goto(false, 'ERROR'), { desc = 'Prev Error' })

-- Navigate only warnings
map('n', ']w', diagnostic_goto(true, 'WARN'), { desc = 'Next Warning' })
map('n', '[w', diagnostic_goto(false, 'WARN'), { desc = 'Prev Warning' })

-- stylua: ignore start

-- =============================================================================
-- UI TOGGLES - Snacks.toggle Integration
-- =============================================================================
-- These toggles use Snacks.toggle for consistent behavior and notifications
-- Each toggle shows a notification when the state changes

-- Text display toggles
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")

-- Diagnostics and line numbers
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")

-- Conceal level (for markdown, etc.)
Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>uc")

-- UI element toggles
Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>uA")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.option("background", { off = "light", on = "dark" , name = "Dark Background" }):map("<leader>ub")

-- Snacks UI features
Snacks.toggle.dim():map("<leader>uD")
Snacks.toggle.animate():map("<leader>ua")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.scroll():map("<leader>uS")

-- Profiler toggles (for debugging performance)
Snacks.toggle.profiler():map("<leader>dpp")
Snacks.toggle.profiler_highlights():map("<leader>dph")

-- LSP inlay hints toggle (only if supported)
if vim.lsp.inlay_hint then
  Snacks.toggle.inlay_hints():map("<leader>uh")
end

-- =============================================================================
-- GIT OPERATIONS - Lazygit and Git Browse
-- =============================================================================

-- Lazygit integration (only if lazygit is installed)
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
  map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Current File History" })
  map("n", "<leader>gL", function() Snacks.picker.git_log() end, { desc = "Git Log (cwd)" })
end

-- Git blame and browse (works without lazygit)
map("n", "<leader>gb", function() Snacks.picker.git_log_line() end, { desc = "Git Blame Line" })
map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse (open)" })

-- Copy git URL to clipboard instead of opening
map({"n", "x" }, "<leader>gY", function()
  Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
end, { desc = "Git Browse (copy)" })

-- =============================================================================
-- SESSION OPERATIONS
-- =============================================================================

-- Quit all buffers
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- =============================================================================
-- UI INSPECTION
-- =============================================================================

-- Inspect highlight groups under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })

-- Inspect treesitter tree (opens in a new window)
map("n", "<leader>uI", function() vim.treesitter.inspect_tree() vim.api.nvim_input("I") end, { desc = "Inspect Tree" })

-- =============================================================================
-- TERMINAL
-- =============================================================================

-- Open floating terminal
map("n", "<leader>fT", function() Snacks.terminal() end, { desc = "Terminal (cwd)" })

-- Terminal mode mappings
-- <C-/> closes the terminal (same key to toggle on/off)
-- <c-_> is the same as <C-/> on some terminals
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- =============================================================================
-- WINDOW MANAGEMENT
-- =============================================================================

-- Quick split creation
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

-- Window zoom and zen mode toggles
Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
Snacks.toggle.zen():map("<leader>uz")

-- =============================================================================
-- TAB MANAGEMENT
-- =============================================================================

map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- =============================================================================
-- SNIPPETS - Legacy Support (Neovim < 0.11)
-- =============================================================================

-- Native snippet navigation for Neovim versions before 0.11
-- Neovim 0.11+ creates these mappings by default
if vim.fn.has("nvim-0.11") == 0 then
  map("s", "<Tab>", function()
    return vim.snippet.active({ direction = 1 }) and "<cmd>lua vim.snippet.jump(1)<cr>" or "<Tab>"
  end, { expr = true, desc = "Jump Next" })
  map({ "i", "s" }, "<S-Tab>", function()
    return vim.snippet.active({ direction = -1 }) and "<cmd>lua vim.snippet.jump(-1)<cr>" or "<S-Tab>"
  end, { expr = true, desc = "Jump Previous" })
end

-- =============================================================================
-- MISCELLANEOUS
-- =============================================================================

-- Snacks notification history
map('n', '<leader>snH', '<cmd>lua Snacks.notifier.show_history()<cr>', { desc = 'Snacks Notification History' })

-- NVChad theme picker
map('n', '<leader>uC', "<cmd>lua require('nvchad.themes').open()<cr>", { desc = 'NVChad Theme Picker' })

-- Terminal toggle in normal mode (same as <leader>fT but more convenient)
map('n', '<C-/>', function() Snacks.terminal() end, { desc = 'Toggle Terminal' })
