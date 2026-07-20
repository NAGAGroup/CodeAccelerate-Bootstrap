-- =============================================================================
-- keymaps.lua — Core keymaps (LazyVim vocabulary) + which-key group registration
-- =============================================================================

-- Disable v0.12 built-in <C-s> insert-mode signature help (conflicts with <C-k>)
pcall(vim.keymap.del, "i", "<C-s>")

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Window resize
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Window height +" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Window height -" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Window width -" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Window width +" })

-- Indentation
-- NOTE: mode "x" (visual only), NOT "v" (visual+select) — select mode is used
-- by mini.snippets placeholders, where printable keys must self-insert.
vim.keymap.set("x", "<", "<gv", { desc = "Indent left + reselect" })
vim.keymap.set("x", ">", ">gv", { desc = "Indent right + reselect" })

-- Line movement (normal + visual)
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("x", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("x", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Search (LazyVim style: clear hlsearch, keep Esc semantics)
vim.keymap.set({ "i", "n" }, "<Esc>", "<cmd>noh<cr><esc>", { desc = "Escape + clear hlsearch" })

-- Clipboard
vim.keymap.set("x", "p", '"_dP', { desc = "Paste without replacing register" })

-- Save (all modes — LazyVim convention)
vim.keymap.set({ "i", "x", "n" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })

-- File / quit
vim.keymap.set("n", "<leader>fn", "<cmd>enew<CR>", { desc = "New file" })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit all" })

-- Buffer navigation — <S-h>/<S-l> open snacks.picker buffer list
vim.keymap.set("n", "<S-h>", function()
	Snacks.picker.buffers()
end, { desc = "Buffers (picker)" })
vim.keymap.set("n", "<S-l>", function()
	Snacks.picker.buffers()
end, { desc = "Buffers (picker)" })

-- Buffer operations
vim.keymap.set("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { desc = "Delete other buffers" })
vim.keymap.set("n", "<leader>bD", "<cmd>bd<CR>", { desc = "Delete buffer + window" })

-- Splits (LazyVim: <leader>- below, <leader>| right)
vim.keymap.set("n", "<leader>-", "<cmd>split<CR>", { desc = "Split below" })
vim.keymap.set("n", "<leader>|", "<cmd>vsplit<CR>", { desc = "Split right" })
vim.keymap.set("n", "<leader>wd", "<cmd>close<CR>", { desc = "Close window" })

-- Terminal
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Quickfix navigation
vim.keymap.set("n", "[q", "<cmd>cprev<CR>", { desc = "Prev quickfix" })
vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })

-- which-key group registration (v3 add() API)
local ok, wk = pcall(require, "which-key")
if ok then
	wk.add({
		{ "<leader><tab>", group = "tabs" },
		{ "<leader>b", group = "buffer" },
		{ "<leader>c", group = "code" },
		{ "<leader>cm", group = "cmake" },
		{ "<leader>d", group = "debug" },
		{ "<leader>f", group = "file/find" },
		{ "<leader>g", group = "git" },
		{ "<leader>gh", group = "hunks" },
		{ "<leader>q", group = "quit/session" },
		{ "<leader>r", group = "refactor" },
		{ "<leader>s", group = "search" },
		{ "<leader>t", group = "test" },
		{ "<leader>u", group = "ui" },
		{ "<leader>w", group = "windows" },
		{ "<leader>x", group = "diagnostics/quickfix" },
		{ "<leader>y", group = "yank" },
		{ "g", group = "goto" },
		{ "gs", group = "surround" },
	})
end
