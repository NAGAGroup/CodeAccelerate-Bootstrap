-- LSP configuration using Neovim 0.11+ native vim.lsp.config API

local add = MiniDeps.add

-- nvim-lspconfig is still valuable: it provides server defaults via its `lsp/` directory.
-- The deprecated part is the legacy `require('lspconfig')` framework, which we never use.
add("neovim/nvim-lspconfig")

-- Mason is for installation only.
add("williamboman/mason.nvim")

require("mason").setup({
	ui = {
		border = "rounded",
		icons = {
			package_installed = "I",
			package_pending = ">",
			package_uninstalled = "X",
		},
	},
})

-- Ensure lspconfig server defaults are on runtimepath (mini.deps installs into opt/).
pcall(vim.cmd, "packadd nvim-lspconfig")

-- Capabilities for blink.cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

-- Keymaps via LspAttach
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		map("gd", vim.lsp.buf.definition, "Go to definition")
		map("gD", vim.lsp.buf.declaration, "Go to declaration")
		map("gi", vim.lsp.buf.implementation, "Go to implementation")
		map("gr", vim.lsp.buf.references, "Go to references")
		map("K", vim.lsp.buf.hover, "Hover documentation")
		map("<leader>rn", vim.lsp.buf.rename, "Rename")
		map("<leader>ca", vim.lsp.buf.code_action, "Code action")
		map("<C-k>", vim.lsp.buf.signature_help, "Signature help")

		-- Enable clangd semantic tokens by default; user can disable via toggle command.
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client.name == "clangd" and client.server_capabilities.semanticTokensProvider then
			if vim.g.clangd_semantic_tokens == false then
				pcall(function()
					vim.lsp.semantic_tokens.stop(event.buf, client.id)
				end)
				client.server_capabilities.semanticTokensProvider = nil
			end
		end
	end,
})

vim.api.nvim_create_user_command("ClangdSemanticTokensToggle", function()
	local cur = vim.g.clangd_semantic_tokens
	if cur == nil then
		cur = true
	end
	vim.g.clangd_semantic_tokens = not cur
	vim.notify(
		"clangd semantic tokens: " .. tostring(vim.g.clangd_semantic_tokens) .. " (restart clangd to apply)",
		vim.log.levels.INFO
	)
end, { desc = "Toggle clangd semantic tokens (restart clangd)" })

local function root(markers)
	return function(bufnr, on_dir)
		local dir = vim.fs.root(bufnr, markers) or vim.uv.cwd()
		on_dir(dir)
	end
end

-- Override only what we need; everything else comes from nvim-lspconfig defaults.
vim.lsp.config("clangd", {
	capabilities = capabilities,
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--completion-style=detailed",
		"--header-insertion=iwyu",
		"--function-arg-placeholders=true",
		"--limit-results=1000",
	},
	root_dir = root({
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		"configure.ac",
		".git",
	}),
})

-- CMake: server name is `cmake` (package is `cmake-language-server`).
vim.lsp.config("cmake", {
	capabilities = capabilities,
	cmd = { "cmake-language-server" },
	root_dir = root({ "CMakeLists.txt", ".git" }),
})

vim.lsp.config("basedpyright", {
	capabilities = capabilities,
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "standard",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
	root_dir = root({ "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" }),
})

vim.lsp.config("vtsls", {
	capabilities = capabilities,
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	settings = {
		typescript = {
			inlayHints = {
				parameterNames = { enabled = "all" },
				parameterTypes = { enabled = true },
				variableTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
			},
		},
	},
	root_dir = root({ "package.json", "tsconfig.json", "jsconfig.json", ".git" }),
})

vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = { enable = false },
			hint = { enable = true },
		},
	},
	root_dir = root({
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		"selene.toml",
		".git",
	}),
})

-- Nushell LSP (not part of nvim-lspconfig/mason-lspconfig; configure explicitly)
vim.lsp.config("nushell", {
	cmd = { "nu", "--lsp" },
	filetypes = { "nu" },
	capabilities = capabilities,
	root_dir = root({ ".git" }),
})

vim.lsp.config("marksman", {
	capabilities = capabilities,
	filetypes = { "markdown" },
	root_dir = root({ ".git" }),
})

vim.lsp.config("yamlls", {
	capabilities = capabilities,
	filetypes = { "yaml" },
	root_dir = root({ ".git" }),
})

-- Enable servers only when their executables exist (avoids noisy startup errors)
local function enable_if_executable(name, exe)
	if vim.fn.executable(exe) == 1 then
		local ok, err = pcall(vim.lsp.enable, name)
		if not ok then
			vim.notify(('Failed to enable LSP "%s": %s'):format(name, tostring(err)), vim.log.levels.ERROR)
		end
	end
end

enable_if_executable("clangd", "clangd")
enable_if_executable("cmake", "cmake-language-server")
enable_if_executable("basedpyright", "basedpyright-langserver")
enable_if_executable("vtsls", "vtsls")
enable_if_executable("bashls", "bash-language-server")
enable_if_executable("jsonls", "vscode-json-language-server")
enable_if_executable("yamlls", "yaml-language-server")
enable_if_executable("taplo", "taplo")
enable_if_executable("marksman", "marksman")
enable_if_executable("lua_ls", "lua-language-server")
enable_if_executable("nushell", "nu")

-- Border for floating windows
local border = "rounded"
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })
