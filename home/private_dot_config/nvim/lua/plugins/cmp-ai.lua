local function can_access_url(url)
	local command = string.format("curl -Is --max-time 5 %s | head -n 1", url)
	local result = vim.fn.system(command)
	return result:match("HTTP/%d%.%d 200")
end
local function is_tabby_available()
	if os.getenv("TABBY_API_KEY") == "" then
		return false
	end

	return can_access_url("http://localhost:8080")
end

if not is_tabby_available() or true then
	vim.notify("Tabby AI not available.")
	return {}
end

return {
	"hrsh7th/nvim-cmp",
	dependencies = { -- this will only be evaluated if nvim-cmp is enabled
		{
			"tzachar/cmp-ai",
			dependencies = "nvim-lua/plenary.nvim",
			opts = {
				max_lines = 1000,
				provider = "Tabby",
				notify = false,
				provider_options = {
					-- user = 'yourusername',
					-- temperature = 0.2,
					-- seed = 'randomstring',
				},
				notify_callback = function(msg)
					vim.notify(msg)
				end,
				run_on_every_keystroke = true,
				ignored_file_types = {
					-- Example: lua = true
				},
			},
		},
	},
	opts = function(_, opts)
		table.insert(opts.sources, 1, {
			name = "cmp_ai",
			group_index = 1,
			priority = 100,
		})
	end,
}
