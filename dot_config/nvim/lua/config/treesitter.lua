-- =============================================================================
-- treesitter.lua — nvim-treesitter main branch + native v0.12 treesitter
-- =============================================================================
-- nvim-treesitter main is a full rewrite for 0.12 compatibility.
-- No modules system, no ensure_installed in setup().
-- Plugin manages parser installation + provides queries.
-- We handle vim.treesitter.start() + auto-install ourselves.
-- install() returns an async Task — :await() lets us start highlighting on the
-- triggering buffer as soon as a freshly-installed parser is ready.
-- =============================================================================

local ts = require("nvim-treesitter")

-- nvim-treesitter setup (optional — defaults work without it)
ts.setup()

-- Curated parser list — install at startup (async, no-op if already installed)
ts.install({
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

-- Start treesitter highlighting + set window-local fold options for a buffer
local function ts_start(buf, lang)
	if not vim.api.nvim_buf_is_valid(buf) then
		return false
	end
	local ok = pcall(vim.treesitter.start, buf, lang)
	if ok then
		-- Set fold options for windows showing this buffer (global defaults in
		-- options.lua already cover the common case; this pins new windows too)
		vim.api.nvim_buf_call(buf, function()
			vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.wo[0][0].foldmethod = "expr"
		end)
	end
	return ok
end

-- FileType autocmd: start treesitter, auto-installing the parser if missing
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
	callback = function(ev)
		local lang = vim.treesitter.language.get_lang(ev.match) or ev.match

		-- Parser already installed → start immediately
		if ts_start(ev.buf, lang) then
			return
		end

		-- Not installed: auto-install if the registry knows this language,
		-- then start highlighting on this same buffer once ready.
		if not vim.tbl_contains(ts.get_available(), lang) then
			return
		end
		ts.install({ lang }):await(function(err)
			if not err then
				vim.schedule(function()
					ts_start(ev.buf, lang)
				end)
			end
		end)
	end,
	desc = "Treesitter highlighting + folds, auto-installing missing parsers",
})
