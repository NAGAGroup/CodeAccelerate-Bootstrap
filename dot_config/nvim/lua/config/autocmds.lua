-- =============================================================================
-- autocmds.lua — Autocommand groups (LazyVim set + #28692 + dap-view)
-- =============================================================================

-- highlight_yank
vim.api.nvim_create_augroup("highlight_yank", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	group = "highlight_yank",
	callback = function()
		vim.highlight.on_yank({ timeout = 200 })
	end,
	desc = "Highlight yanked text",
})

-- close_with_q
vim.api.nvim_create_augroup("close_with_q", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "close_with_q",
	pattern = { "help", "man", "qf", "notify", "checkhealth", "dap-view", "dap-view-term", "dap-view-hover", "trouble" },
	callback = function(ev)
		vim.opt_local.buflisted = false
		vim.keymap.set("n", "q", ":close<CR>", { buffer = ev.buf, silent = true, desc = "Close" })
	end,
	desc = "Close utility buffers with q",
})

-- checktime
vim.api.nvim_create_augroup("checktime", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = "checktime",
	command = ":checktime",
	desc = "Auto-reload file on focus regain",
})

-- resize_splits
vim.api.nvim_create_augroup("resize_splits", { clear = true })
vim.api.nvim_create_autocmd("VimResized", {
	group = "resize_splits",
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
	desc = "Auto-resize splits on window resize",
})

-- last_loc — jump to last cursor position
vim.api.nvim_create_augroup("last_loc", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
	group = "last_loc",
	callback = function(ev)
		if vim.b[ev.buf].last_loc_done then
			return
		end
		vim.b[ev.buf].last_loc_done = true
		local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
		if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
			vim.api.nvim_win_set_cursor(0, mark)
		end
	end,
	desc = "Jump to last cursor position",
})

-- wrap_spell
vim.api.nvim_create_augroup("wrap_spell", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "wrap_spell",
	pattern = { "text", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
	desc = "Enable wrap + spell for prose",
})

-- auto_create_dir
vim.api.nvim_create_augroup("auto_create_dir", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = "auto_create_dir",
	callback = function(ev)
		local dir = vim.fs.dirname(ev.file)
		if dir and not vim.fn.isdirectory(dir) then
			vim.fn.mkdir(dir, "p")
		end
	end,
	desc = "Auto-create parent directories on save",
})

-- treesitter_folds — workaround for neovim/neovim#28692 (still open as of 0.12)
-- TODO: remove when #28692 is confirmed fixed
vim.api.nvim_create_augroup("treesitter_folds", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	group = "treesitter_folds",
	callback = function()
		vim.schedule(function()
			vim.cmd("normal! zx")
		end)
	end,
	desc = "Workaround for #28692 — force treesitter fold recomputation",
})

-- dap_view_statusline — hide lualine in dap-view windows
vim.api.nvim_create_augroup("dap_view_statusline", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "dap_view_statusline",
	pattern = { "dap-view", "dap-view-term", "dap-view-hover" },
	callback = function()
		vim.opt_local.laststatus = 0
	end,
	desc = "Hide statusline in dap-view windows",
})
