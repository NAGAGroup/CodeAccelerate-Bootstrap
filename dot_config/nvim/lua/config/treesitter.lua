-- =============================================================================
-- treesitter.lua — nvim-treesitter main branch + native v0.12 treesitter
-- =============================================================================
-- nvim-treesitter main is a full rewrite for 0.12 compatibility.
-- No modules system, no ensure_installed in setup().
-- Plugin manages parser installation + provides queries.
-- We handle vim.treesitter.start() + auto-install ourselves.
-- =============================================================================

-- nvim-treesitter setup (optional — defaults work without it)
require("nvim-treesitter").setup()

-- Curated parser list — install at startup (async, no-op if already installed)
require("nvim-treesitter").install({
	"c",
	"cpp",
	"cmake",
	"lua",
	"vim",
	"vimdoc",
	"query",
	"python",
	"javascript",
	"typescript",
	"tsx",
	"bash",
	"nu",
	"json",
	"yaml",
	"toml",
	"markdown",
	"markdown_inline",
})

-- FileType autocmd: start treesitter highlighting + set folds
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
	callback = function(ev)
		local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
		pcall(function()
			vim.treesitter.start(ev.buf, lang)
			vim.wo[ev.buf][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.wo[ev.buf][0].foldmethod = "expr"
		end)
	end,
	desc = "Enable treesitter highlighting + folds when parser available",
})

-- Auto-install missing parsers on new filetype
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("TreesitterAutoInstall", { clear = true }),
	callback = function(ev)
		local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
		local available = require("nvim-treesitter").get_available()
		if not vim.tbl_contains(available, lang) then
			return
		end
		local installed = require("nvim-treesitter").get_installed()
		if not vim.tbl_contains(installed, lang) then
			require("nvim-treesitter").install({ lang })
		end
	end,
	desc = "Auto-install missing treesitter parsers on filetype open",
})
