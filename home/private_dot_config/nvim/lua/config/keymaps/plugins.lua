--[[ 
=====================================================================
             Neovim Configuration - Plugin Keymaps
=====================================================================
This module defines keymaps for various plugins. These are general 
plugin keymaps that don't fit in the plugin-specific configuration.
]]

map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find Files' })
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live Grep' })
map('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Buffers' })
map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Help Tags' })
map('n', '<leader>fc', '<cmd>Telescope commands<cr>', { desc = 'Commands' })
map('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', { desc = 'Recent Files' })
map('n', '<leader>fp', '<cmd>Telescope projects<cr>', { desc = 'Projects' })
map('n', '<leader>fs', '<cmd>Telescope lsp_document_symbols<cr>', { desc = 'Document Symbols' })
map('n', '<leader>fS', '<cmd>Telescope lsp_workspace_symbols<cr>', { desc = 'Workspace Symbols' })

-- File Explorer
map('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle Explorer' })

map('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = 'LazyGit' })
map('n', '<leader>gG', function() Snacks.lazygit() end, { desc = 'Lazygit (cwd)' })
map('n', '<leader>gf', function() Snacks.picker.git_log_file() end, { desc = 'Git Current File History' })
map('n', '<leader>gL', function() Snacks.picker.git_log() end, { desc = 'Git Log (cwd)' })
map('n', '<leader>gb', function() Snacks.picker.git_log_line() end, { desc = 'Git Blame Line' })
map({ "n", "x" }, '<leader>gB', function() Snacks.gitbrowse() end, { desc = 'Git Browse (open)' })
map({ "n", "x" }, '<leader>gY', function() 
  Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
end, { desc = 'Git Browse (copy)' })
map('n', '<leader>gb', '<cmd>Telescope git_branches<cr>', { desc = 'Git Branches' })
map('n', '<leader>gs', '<cmd>Telescope git_status<cr>', { desc = 'Git Status' })
map('n', '<leader>gc', '<cmd>Telescope git_commits<cr>', { desc = 'Git Commits' })
map('n', '<leader>gd', '<cmd>DiffviewOpen<cr>', { desc = 'Diff View' })

-- Comment
map('n', '<leader>/', function()
  require('Comment.api').toggle.linewise.current()
end, { desc = 'Toggle Comment' })
map('v', '<leader>/', "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
  { desc = 'Toggle Comment' })

map('n', '<leader>t', '<cmd>ToggleTerm direction=float<cr>', { desc = 'Toggle Terminal' })
map('n', '<leader>fT', function() Snacks.terminal() end, { desc = 'Terminal (cwd)' })
map('t', '<C-/>', '<cmd>close<cr>', { desc = 'Hide Terminal' })
map('t', '<c-_>', '<cmd>close<cr>', { desc = 'which_key_ignore' })

map('n', '<leader>un', '<cmd>set number!<cr>', { desc = 'Toggle Line Numbers' })
map('n', '<leader>ur', '<cmd>set relativenumber!<cr>', { desc = 'Toggle Relative Numbers' })
map('n', '<leader>us', '<cmd>set spell!<cr>', { desc = 'Toggle Spellcheck' })
map('n', '<leader>uw', '<cmd>set wrap!<cr>', { desc = 'Toggle Word Wrap' })
map('n', '<leader>uc', '<cmd>set cursorline!<cr>', { desc = 'Toggle Cursor Line' })
map('n', '<leader>uL', '<cmd>set relativenumber!<cr>', { desc = 'Toggle Relative Number' })
map('n', '<leader>ud', Snacks.toggle.diagnostics(), { desc = 'Toggle Diagnostics' })
map('n', '<leader>ul', Snacks.toggle.line_number(), { desc = 'Toggle Line Number' })
map('n', '<leader>uc', Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }), { desc = 'Toggle Conceal Level' })
map('n', '<leader>uA', Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }), { desc = 'Toggle Tabline' })
map('n', '<leader>uT', Snacks.toggle.treesitter(), { desc = 'Toggle Treesitter' })
map('n', '<leader>ub', Snacks.toggle.option("background", { off = "light", on = "dark" , name = "Dark Background" }), { desc = 'Toggle Dark Background' })
map('n', '<leader>uD', Snacks.toggle.dim(), { desc = 'Toggle Dim' })
map('n', '<leader>ua', Snacks.toggle.animate(), { desc = 'Toggle Animate' })
map('n', '<leader>ug', Snacks.toggle.indent(), { desc = 'Toggle Indent' })
map('n', '<leader>uS', Snacks.toggle.scroll(), { desc = 'Toggle Scroll' })
map('n', '<leader>dpp', Snacks.toggle.profiler(), { desc = 'Toggle Profiler' })
map('n', '<leader>dph', Snacks.toggle.profiler_highlights(), { desc = 'Toggle Profiler Highlights' })

-- Location and quickfix list
map('n', '<leader>xl', function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = 'Location List' })

map('n', '<leader>xq', function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = 'Quickfix List' })

map('n', '[q', vim.cmd.cprev, { desc = 'Previous Quickfix' })
map('n', ']q', vim.cmd.cnext, { desc = 'Next Quickfix' })

-- Miscellaneous
map('n', '<leader>K', '<cmd>norm! K<cr>', { desc = 'Keywordprg' })
map('n', '<leader>ui', vim.show_pos, { desc = 'Inspect Pos' })
map('n', '<leader>uI', function() vim.treesitter.inspect_tree() vim.api.nvim_input("I") end, { desc = 'Inspect Tree' })
map('n', '<leader>snH', '<cmd>lua Snacks.notifier.show_history()<cr>', { desc = 'Snacks Notification History' })
map('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit All' })
map('n', '<leader>ur', '<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>', { desc = 'Redraw / Clear hlsearch / Diff Update' })

-- Comments
map('n', 'gco', 'o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Below' })
map('n', 'gcO', 'O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Above' })
-- Add inlay hints toggle if supported
if vim.lsp.inlay_hint then
  map('n', '<leader>uh', Snacks.toggle.inlay_hints(), { desc = 'Toggle Inlay Hints' })
end

-- Windows
map('n', '<leader>-', '<C-W>s', { desc = 'Split Window Below', remap = true })
map('n', '<leader>|', '<C-W>v', { desc = 'Split Window Right', remap = true })
map('n', '<leader>wd', '<C-W>c', { desc = 'Delete Window', remap = true })
map('n', '<leader>wm', Snacks.toggle.zoom(), { desc = 'Maximize Window' })
map('n', '<leader>uZ', Snacks.toggle.zoom(), { desc = 'Toggle Zoom' })
map('n', '<leader>uz', Snacks.toggle.zen(), { desc = 'Toggle Zen Mode' })

-- Tabs
map('n', '<leader><tab>l', '<cmd>tablast<cr>', { desc = 'Last Tab' })
map('n', '<leader><tab>o', '<cmd>tabonly<cr>', { desc = 'Close Other Tabs' })
map('n', '<leader><tab>f', '<cmd>tabfirst<cr>', { desc = 'First Tab' })
map('n', '<leader><tab><tab>', '<cmd>tabnew<cr>', { desc = 'New Tab' })
map('n', '<leader><tab>]', '<cmd>tabnext<cr>', { desc = 'Next Tab' })
map('n', '<leader><tab>d', '<cmd>tabclose<cr>', { desc = 'Close Tab' })
map('n', '<leader><tab>[', '<cmd>tabprevious<cr>', { desc = 'Previous Tab' })

-- CodeCompanion
map('n', '<leader>cc', '<cmd>CodeCompanionToggle<cr>', { desc = 'Toggle CodeCompanion' })
map('v', '<leader>ce', '<cmd>CodeCompanionExplain<cr>', { desc = 'Explain Code' })
map('n', '<leader>ct', '<cmd>CodeCompanionTest<cr>', { desc = 'Generate Test' })
map('n', '<leader>co', '<cmd>CodeCompanionOptimize<cr>', { desc = 'Optimize Code' })