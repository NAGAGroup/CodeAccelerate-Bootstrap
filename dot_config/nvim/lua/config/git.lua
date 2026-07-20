-- =============================================================================
-- git.lua — gitsigns (LazyVim <leader>gh scheme) + snacks.lazygit
-- =============================================================================

require("gitsigns").setup({
	signs = {
		add = { text = "│" },
		change = { text = "│" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signs_staged = {
		add = { text = "│" },
		change = { text = "│" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signs_staged_enable = true,

	on_attach = function(bufnr)
		local gs = require("gitsigns")
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
		end

		-- Hunk navigation
		map("n", "]h", function()
			gs.nav_hunk("next")
		end, "Git: next hunk")
		map("n", "[h", function()
			gs.nav_hunk("prev")
		end, "Git: prev hunk")

		-- Hunk actions (LazyVim <leader>gh prefix)
		map({ "n", "v" }, "<leader>ghs", function()
			gs.stage_hunk()
		end, "Git: stage hunk")
		map({ "n", "v" }, "<leader>ghr", function()
			gs.reset_hunk()
		end, "Git: reset hunk")
		map("n", "<leader>ghS", function()
			gs.stage_buffer()
		end, "Git: stage buffer")
		map("n", "<leader>ghu", function()
			gs.undo_stage_hunk()
		end, "Git: undo stage")
		map("n", "<leader>ghR", function()
			gs.reset_buffer()
		end, "Git: reset buffer")
		map("n", "<leader>ghp", function()
			gs.preview_hunk()
		end, "Git: preview hunk")
		map("n", "<leader>ghb", function()
			gs.blame_line({ full = true })
		end, "Git: blame line")
		map("n", "<leader>ghd", function()
			gs.diffthis()
		end, "Git: diff this")
		map("n", "<leader>ghD", function()
			gs.diffthis("~")
		end, "Git: diff against ~")

		-- Text object
		map({ "o", "x" }, "ih", function()
			gs.select_hunk()
		end, "Git: select hunk")
	end,
})

-- lazygit (via snacks)
vim.keymap.set("n", "<leader>gg", function()
	Snacks.lazygit.open()
end, { desc = "Lazygit (root)" })
vim.keymap.set("n", "<leader>gG", function()
	Snacks.lazygit.open({ cwd = vim.uv.cwd() })
end, { desc = "Lazygit (cwd)" })
