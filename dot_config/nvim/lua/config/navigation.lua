-- =============================================================================
-- navigation.lua — root detection + snacks.picker/explorer + mini.files + persistence + flash
-- =============================================================================

-- Root detection (LazyVim root_spec pattern)
local function get_root()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	for _, client in ipairs(clients) do
		if client.root_dir then
			return client.root_dir
		end
	end
	local root = vim.fs.root(0, { ".git", "lua" })
	if root then
		return root
	end
	return vim.uv.cwd()
end

-- snacks.picker keymaps
vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.files({ cwd = get_root() })
end, { desc = "Find files (root)" })
vim.keymap.set("n", "<leader>fg", function()
	Snacks.picker.grep({ cwd = get_root() })
end, { desc = "Live grep (root)" })
vim.keymap.set("n", "<leader>fG", function()
	Snacks.picker.git_files({ cwd = get_root() })
end, { desc = "Git files" })
vim.keymap.set("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", function()
	Snacks.picker.help()
end, { desc = "Help" })
vim.keymap.set("n", "<leader>fr", function()
	Snacks.picker.recent()
end, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fc", function()
	Snacks.picker.commands()
end, { desc = "Commands" })
vim.keymap.set("n", "<leader>fk", function()
	Snacks.picker.keymaps()
end, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>fd", function()
	Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>sg", function()
	Snacks.picker.grep({ cwd = get_root() })
end, { desc = "Search grep" })
vim.keymap.set("n", "<leader>ss", function()
	Snacks.picker.lsp_symbols()
end, { desc = "Document symbols" })
vim.keymap.set("n", "<leader>sS", function()
	Snacks.picker.lsp_workspace_symbols()
end, { desc = "Workspace symbols" })
vim.keymap.set("n", "<leader>sr", "<cmd>GrugFar<cr>", { desc = "Search & replace" })

-- snacks.explorer
vim.keymap.set("n", "<leader>e", function()
	Snacks.explorer()
end, { desc = "File explorer" })
vim.keymap.set("n", "<leader>ge", function()
	Snacks.explorer.reveal()
end, { desc = "Reveal in explorer" })

-- mini.files
require("mini.files").setup({})
vim.keymap.set("n", "<leader>fm", function()
	if not MiniFiles.close() then
		MiniFiles.open()
	end
end, { desc = "mini.files (toggle)" })
vim.keymap.set("n", "<leader>fo", function()
	MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
end, { desc = "mini.files (current file)" })

-- mini.files yank path keymaps
vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		local buf = args.data.buf_id
		vim.keymap.set("n", "gy", function()
			local entry = MiniFiles.get_fs_entry()
			if entry then
				vim.fn.setreg(vim.v.register, entry.path)
			end
		end, { buffer = buf, desc = "Yank absolute path" })
	end,
})

-- persistence
require("persistence").setup({
	dir = vim.fn.stdpath("state") .. "/sessions/",
	branch = false,
})
-- LazyVim vocabulary: qs=restore, qS=select, ql=last, qd=don't save
vim.keymap.set("n", "<leader>qs", function()
	require("persistence").load()
end, { desc = "Session: restore" })
vim.keymap.set("n", "<leader>qS", function()
	require("persistence").select()
end, { desc = "Session: select" })
vim.keymap.set("n", "<leader>ql", function()
	require("persistence").load({ last = true })
end, { desc = "Session: restore last" })
vim.keymap.set("n", "<leader>qd", function()
	require("persistence").stop()
end, { desc = "Session: don't save" })

-- flash
require("flash").setup({
	modes = { char = { enabled = false } },
})
vim.keymap.set({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash: jump" })
vim.keymap.set({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash: treesitter" })

-- Yank path keymaps
vim.keymap.set("n", "<leader>ya", function()
	vim.fn.setreg("+", vim.api.nvim_buf_get_name(0))
end, { desc = "Yank absolute path" })
vim.keymap.set("n", "<leader>yr", function()
	local abs = vim.api.nvim_buf_get_name(0)
	local root = get_root()
	if root and abs:sub(1, #root) == root then
		vim.fn.setreg("+", abs:sub(#root + 2))
	else
		vim.fn.setreg("+", abs)
	end
end, { desc = "Yank relative path" })
vim.keymap.set("n", "<leader>yn", function()
	vim.fn.setreg("+", vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t"))
end, { desc = "Yank filename" })
