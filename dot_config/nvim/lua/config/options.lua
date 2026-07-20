-- =============================================================================
-- options.lua — vim.opt / vim.g settings + ayu colorscheme config
-- =============================================================================
-- Base: LazyVim v16 defaults, modified by selection decisions.
-- ayu.setup() here (config only); colorscheme applied at end of init.lua.
-- =============================================================================

-- Leader keys set in init.lua before vim.pack.add()

-- Editor options (LazyVim defaults)
vim.opt.autowrite = true
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.conceallevel = 2
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.formatoptions = "jcroqlnt"
vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "nosplit"
vim.opt.laststatus = 3
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.pumblend = 10
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8
vim.opt.shiftround = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.smartindent = true
vim.opt.smoothscroll = true
vim.opt.spelllang = { "en" }
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "screen"
vim.opt.termguicolors = true
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.updatetime = 200
vim.opt.virtualedit = "block"
vim.opt.wildmode = "longest:full,full"
vim.opt.wrap = false

-- Fillchars (LazyVim: hide ~ at end of buffer)
vim.opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
}

-- Folding (treesitter)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "1"

-- Native 0.12 features
vim.o.winborder = "rounded"
vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,globals"

-- Shell detection
local bash = vim.fn.exepath("bash")
if bash ~= "" then
	vim.opt.shell = bash
end

-- OSC52 clipboard — ONLY over SSH (LazyVim pattern).
-- Locally, the native provider (wl-copy/xsel) handles both copy AND paste;
-- OSC52 paste is unsupported by most terminals, so forcing it unconditionally
-- would break "+p everywhere.
if vim.env.SSH_TTY then
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		paste = {
			["+"] = require("vim.ui.clipboard.osc52").paste("+"),
			["*"] = require("vim.ui.clipboard.osc52").paste("*"),
		},
	}
end

-- Format on save global (LazyVim convention: autoformat = true means enabled)
vim.g.autoformat = true

-- Root detection spec (LazyVim pattern)
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- Colorscheme configuration (NOT applied here — applied at end of init.lua)
require("ayu").setup({
	mirage = false,
	terminal = true,
	overrides = {},
})
