-- =============================================================================
-- auto-setup.lua — Automatic tool installation + setup on filetype open
-- =============================================================================
-- LSP: installs for ANY filetype via mason-lspconfig's 282+ filetype mappings.
--   automatic_enable handles enabling + config auto-setup.
-- Formatters: installs from comprehensive curated formatters_by_ft table.
-- Linters: installs from comprehensive curated linters_by_ft table.
-- DAP: installs from comprehensive curated dap_adapters_by_ft table.
--   mason-nvim-dap default_setup handles adapter config registration.
-- Treesitter: handled by treesitter.lua's own FileType autocmd.
-- =============================================================================

local M = {}

-- =============================================================================
-- LSP server preferences per filetype.
-- For filetypes NOT in this table, the FIRST server in the mason-lspconfig
-- mapping is installed. This avoids multiple LSPs fighting for one filetype.
-- =============================================================================
M.lsp_preferences = {
	python = "basedpyright",
	cpp = "clangd",
	c = "clangd",
	typescript = "vtsls",
	javascript = "vtsls",
	lua = "lua_ls",
	bash = "bashls",
	sh = "bashls",
	json = "jsonls",
	yaml = "yamlls",
	toml = "taplo",
	markdown = "marksman",
	cmake = "neocmake",
	nushell = "nushell",
}

-- =============================================================================
-- Comprehensive filetype → formatter table (conform.nvim)
-- Covers every language conform.nvim supports with opinionated choices.
-- =============================================================================
M.formatters_by_ft = {
	-- A
	arduino = { "clang-format" },
	asm = { "asmfmt" },
	awk = { "awk" },
	-- B
	bash = { "shfmt" },
	beancount = { "bean-format" },
	bicep = { "bicep" },
	blade = { "blade-formatter" },
	bp = { "bpfmt" },
	brighterscript = { "bsfmt" },
	-- C
	c = { "clang-format" },
	cabal = { "cabal_fmt" },
	cedar = { "cedar" },
	clojure = { "cljfmt" },
	cmake = { "gersemi" },
	conf = { "dprint" },
	cpp = { "clang-format" },
	crystal = { "crystal" },
	cs = { "csharpier" },
	css = { "biome" },
	cue = { "cue_fmt" },
	-- D
	d = { "dfmt" },
	d2 = { "d2" },
	dart = { "dart_format" },
	dockerfile = { "dockerfmt" },
	-- E
	edn = { "zprint" },
	elixir = { "mix" },
	elm = { "elm_format" },
	erlang = { "erlfmt" },
	-- F
	fennel = { "fnlfmt" },
	fish = { "fish_indent" },
	fortran = { "fprettify" },
	-- G
	gdscript = { "gdformat" },
	gleam = { "gleam" },
	glsl = { "clang-format" },
	gn = { "gn" },
	go = { "goimports", "gofumpt" },
	graphql = { "prettier" },
	groovy = { "npm-groovy-lint" },
	-- H
	haskell = { "fourmolu" },
	hcl = { "hcl" },
	heex = { "mix" },
	html = { "prettier" },
	hurl = { "hurlfmt" },
	-- I
	imba = { "imba_fmt" },
	inko = { "inko" },
	-- J
	java = { "google-java-format" },
	javascript = { "biome" },
	jinja = { "djlint" },
	jq = { "jq" },
	json = { "biome" },
	jsonc = { "biome" },
	jsonnet = { "jsonnetfmt" },
	julia = { "runic" },
	just = { "just" },
	-- K
	kcl = { "kcl" },
	kdl = { "kdlfmt" },
	kotlin = { "ktlint" },
	-- L
	latex = { "latexindent" },
	liquidsoap = { "liquidsoap-prettier" },
	lua = { "stylua" },
	-- M
	make = { "bake" },
	markdown = { "prettier", "injected" },
	matlab = { "mh_style" },
	meson = { "meson" },
	mojo = { "mojo_format" },
	-- N
	nginx = { "nginxfmt" },
	nickel = { "nickel" },
	nim = { "nph" },
	nix = { "alejandra" },
	nushell = { "nufmt" },
	-- O
	ocaml = { "ocamlformat" },
	odin = { "odinfmt" },
	-- P
	pascal = { "pasfmt" },
	perl = { "perltidy" },
	php = { "pint" },
	pkl = { "pkl" },
	puppet = { "puppet-lint" },
	purescript = { "purs-tidy" },
	python = { "ruff_format" },
	-- Q
	qml = { "qmlformat" },
	-- R
	r = { "air" },
	racket = { "racketfmt" },
	rego = { "opa_fmt" },
	rescript = { "rescript-format" },
	roc = { "roc" },
	rst = { "rstfmt" },
	ruby = { "rubocop" },
	rust = { "rustfmt" },
	-- S
	sass = { "biome" },
	scala = { "scalafmt" },
	scss = { "biome" },
	sh = { "shfmt" },
	sml = { "smlfmt" },
	snakefile = { "snakefmt" },
	solidity = { "forge_fmt" },
	sql = { "sqlfluff" },
	svelte = { "prettier" },
	swift = { "swiftformat" },
	-- T
	tcl = { "tclfmt" },
	templ = { "templ" },
	terraform = { "terraform_fmt" },
	tex = { "latexindent" },
	toml = { "taplo" },
	twig = { "twig-cs-fixer" },
	typescript = { "biome" },
	typescriptreact = { "biome" },
	typst = { "typstyle" },
	-- V
	v = { "v" },
	verilog = { "verible" },
	vhdl = { "vsg" },
	vim = { "stylua" },
	vue = { "prettier" },
	-- X
	xml = { "xmllint" },
	-- Y
	yaml = { "yamlfmt" },
	-- Z
	zig = { "zigfmt" },
	ziggy = { "ziggy" },
	ziggy_schema = { "ziggy_schema" },
	-- Special / build-system files
	bzl = { "buildifier" },
	dune = { "format-dune-file" },
	proto = { "buf" },
	http = { "kulala-fmt" },
	gherkin = { "ghokin" },
	openapi = { "openapi_format" },
	typespec = { "typespec" },
}

-- conform formatter name → mason package name (only where they differ)
M.formatter_to_mason = {
	["ruff_format"] = "ruff",
	["ruff_fix"] = "ruff",
	["ruff_organize_imports"] = "ruff",
	["biome-check"] = "biome",
	["biome-organize-imports"] = "biome",
	["cmake_format"] = "cmakelang",
	["dart_format"] = "dart",
	["deno_fmt"] = "deno",
	["gdformat"] = "gdtoolkit",
	["hcl"] = "hclfmt",
	["terraform_fmt"] = "terraform",
	["terragrunt_hclfmt"] = "terragrunt",
	["nomad_fmt"] = "nomad",
	["packer_fmt"] = "packer",
	["tofu_fmt"] = "tofu",
	["erb_format"] = "erb-formatter",
	["css_beautify"] = "js-beautify",
	["html_beautify"] = "js-beautify",
	["js_beautify"] = "js-beautify",
	["json_repair"] = "json-repair",
	["lua-format"] = "luaformatter",
	["mh_style"] = "miss_hit",
	["nginxfmt"] = "nginx-config-formatter",
	["nixpkgs_fmt"] = "nixpkgs-fmt",
	["odinfmt"] = "ols",
	["opa_fmt"] = "opa",
	["php_cs_fixer"] = "php-cs-fixer",
	["mago_format"] = "mago",
	["mago_lint"] = "mago",
	["purs-tidy"] = "purescript-tidy",
	["pg_format"] = "pgformatter",
	["sql_formatter"] = "sql-formatter",
	["syntax_tree"] = "stree",
	["tclfmt"] = "tclint",
	["bake"] = "mbake",
	["bsfmt"] = "brighterscript-formatter",
	["cue_fmt"] = "cue",
	["dcm_fix"] = "dcm",
	["dcm_format"] = "dcm",
	["elm_format"] = "elm-format",
	["cabal_fmt"] = "cabal-fmt",
	["rescript-format"] = "rescript",
}

-- =============================================================================
-- Comprehensive filetype → linter table (nvim-lint)
-- Covers every language nvim-lint supports with opinionated choices.
-- =============================================================================
M.linters_by_ft = {
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	zsh = { "shellcheck" },
	python = { "ruff" },
	javascript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	css = { "stylelint" },
	scss = { "stylelint" },
	less = { "stylelint" },
	sass = { "stylelint" },
	vue = { "eslint_d" },
	svelte = { "eslint_d" },
	htmldjango = { "curlylint" },
	erb = { "erb_lint" },
	twig = { "twig-cs-fixer" },
	go = { "golangcilint" },
	rust = { "clippy" },
	c = { "clangtidy" },
	cpp = { "clangtidy" },
	objc = { "clangtidy" },
	objcpp = { "clangtidy" },
	java = { "checkstyle" },
	kotlin = { "ktlint" },
	ruby = { "rubocop" },
	eruby = { "erb_lint" },
	php = { "phpstan" },
	lua = { "luacheck" },
	vim = { "vint" },
	markdown = { "markdownlint-cli2" },
	rst = { "rstcheck" },
	yaml = { "yamllint" },
	["yaml.ghaction"] = { "actionlint" },
	["yaml.ansible"] = { "ansible_lint" },
	json = { "jsonlint" },
	jsonc = { "jsonlint" },
	toml = { "tombi" },
	dockerfile = { "hadolint" },
	terraform = { "tflint" },
	tfvars = { "tflint" },
	sql = { "sqlfluff" },
	make = { "checkmake" },
	cmake = { "cmakelint" },
	bzl = { "buildifier" },
	starlark = { "buildifier" },
	proto = { "protolint" },
	solidity = { "solhint" },
	haskell = { "hlint" },
	clojure = { "clj-kondo" },
	swift = { "swiftlint" },
	tcl = { "tclint" },
	nix = { "nix" },
	gdscript = { "gdlint" },
	gitcommit = { "gitlint" },
	tex = { "chktex" },
	latex = { "chktex" },
	plaintex = { "chktex" },
}

-- nvim-lint linter name → mason package name (only where they differ)
M.linter_to_mason = {
	["ansible_lint"] = "ansible-lint",
	["biomejs"] = "biome",
	["buf_lint"] = "buf",
	["cfn_lint"] = "cfn-lint",
	["cmake_lint"] = "cmakelang",
	["dotenv_linter"] = "dotenv-linter",
	["erb_lint"] = "erb-lint",
	["gdlint"] = "gdtoolkit",
	["golangcilint"] = "golangci-lint",
	["mh_lint"] = "miss_hit",
	["opa_check"] = "opa",
	["pflake8"] = "pyproject-flake8",
	["saltlint"] = "salt-lint",
	["snyk_iac"] = "snyk",
	["terraform_validate"] = "terraform",
	["trivy_secret"] = "trivy",
	["write_good"] = "write-good",
}

-- =============================================================================
-- Comprehensive filetype → DAP adapter table
-- Covers every language with a mason-installable DAP adapter.
-- =============================================================================
M.dap_adapters_by_ft = {
	c = "codelldb",
	cpp = "codelldb",
	rust = "codelldb",
	zig = "codelldb",
	swift = "codelldb",
	python = "python",
	go = "delve",
	javascript = "js",
	typescript = "js",
	javascriptreact = "js",
	typescriptreact = "js",
	sh = "bash",
	php = "php",
	cs = "coreclr",
	fsharp = "coreclr",
	java = "javadbg",
	kotlin = "kotlin",
	dart = "dart",
	elixir = "elixir",
	erlang = "erlang",
	haskell = "haskell",
	ruby = "rdbg",
	lua = "local-lua",
	ocaml = "ocamlearlybird",
	perl = "perl",
	puppet = "puppet",
	robot = "robotcode",
}

-- DAP adapter name → mason package name (only where they differ)
M.dap_to_mason = {
	["python"] = "debugpy",
	["cppdbg"] = "cpptools",
	["js"] = "js-debug-adapter",
	["bash"] = "bash-debug-adapter",
	["coreclr"] = "netcoredbg",
	["javadbg"] = "java-debug-adapter",
	["javatest"] = "java-test",
	["kotlin"] = "kotlin-debug-adapter",
	["dart"] = "dart-debug-adapter",
	["elixir"] = "elixir-ls",
	["erlang"] = "erlang-debugger",
	["haskell"] = "haskell-debug-adapter",
	["local-lua"] = "local-lua-debugger-vscode",
	["ocamlearlybird"] = "ocamlearlybird",
	["perl"] = "perl-debug-adapter",
	["robotcode"] = "robotcode",
	["rdbg"] = "rdbg",
}

-- =============================================================================

function M.setup()
	local registry = require("mason-registry")
	local ok_mappings, mappings = pcall(require, "mason-lspconfig.mappings")

	-- Feed formatter/linter tables to conform/nvim-lint
	local ok_conform, conform = pcall(require, "conform")
	if ok_conform then
		conform.setup({
			formatters_by_ft = M.formatters_by_ft,
			format_on_save = function(bufnr)
				if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
					return nil
				end
				return { timeout_ms = 3000, lsp_format = "fallback" }
			end,
		})
	end

	local ok_lint, lint = pcall(require, "lint")
	if ok_lint then
		lint.linters_by_ft = M.linters_by_ft
	end

	-- FileType autocmd: auto-install tools on first open
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("MasonAutoInstall", { clear = true }),
		callback = function(ev)
			local ft = ev.match

			-- Debounce: skip if already checked this buffer
			if vim.b[ev.buf]._mason_auto_install_checked then
				return
			end
			vim.b[ev.buf]._mason_auto_install_checked = true

			-- 1. LSP servers — install for ANY filetype (mason-lspconfig has 282+ mappings)
			if ok_mappings then
				local ft_map = mappings.get_filetype_map()
				local servers = ft_map[ft]
				if servers then
					local mason_map = mappings.get_mason_map()
					local preferred = M.lsp_preferences[ft]

					local to_install = {}
					if preferred and vim.tbl_contains(servers, preferred) then
						table.insert(to_install, preferred)
					else
						table.insert(to_install, servers[1])
					end

					for _, server_name in ipairs(to_install) do
						local pkg_name = mason_map.lspconfig_to_package[server_name]
						if pkg_name and not registry.is_installed(pkg_name) then
							registry.get_package(pkg_name):install()
						end
					end
				end
			end

			-- 2. Formatters — from curated table
			if ok_conform then
				local ft_formatters = M.formatters_by_ft[ft]
				if ft_formatters then
					for _, name in ipairs(ft_formatters) do
						if type(name) == "string" and name ~= "injected" then
							local mason_name = M.formatter_to_mason[name] or name
							if not registry.is_installed(mason_name) then
								local ok, pkg = pcall(registry.get_package, mason_name)
								if ok then
									pkg:install()
								end
							end
						end
					end
				end
			end

			-- 3. Linters — from curated table
			if ok_lint then
				local linters = M.linters_by_ft[ft]
				if linters then
					for _, name in ipairs(linters) do
						local mason_name = M.linter_to_mason[name] or name
						if not registry.is_installed(mason_name) then
							local ok, pkg = pcall(registry.get_package, mason_name)
							if ok then
								pkg:install()
							end
						end
					end
				end
			end

			-- 4. DAP adapters — from curated table
			local dap_adapter = M.dap_adapters_by_ft[ft]
			if dap_adapter then
				local mason_name = M.dap_to_mason[dap_adapter] or dap_adapter
				if not registry.is_installed(mason_name) then
					local ok, pkg = pcall(registry.get_package, mason_name)
					if ok then
						pkg:install()
					end
				end
			end
		end,
		desc = "Auto-install LSP/formatter/linter/DAP on filetype open",
	})
end

return M
