local defaults = {
	models = {
		chat = os.getenv("TABBY_CHAT_MODEL"),
	},
	ports = {
		local_api = "8080",
	},
	roles = {
		llm = "CodeCompanion",
		user = "Jack",
	},
}

local function create_url(host, port)
	return string.format("http://%s:%s", host or "localhost", port or defaults.ports.local_api)
end

local function is_url_accessible(url)
	local command = string.format("curl -Is --max-time 5 %s | head -n 1", url)
	local result = vim.fn.system(command)
	return result:match("HTTP/%d%.%d 200")
end

local function get_adapter()
	local api_key = os.getenv("TABBY_API_KEY")
	local api_url = create_url("localhost", defaults.ports.local_api)
	if api_key == "" or not is_url_accessible(api_url) then
		return "copilot"
	end
	return "tabby"
end

local function create_tabby_adapter()
	return require("codecompanion.adapters").extend("openai_compatible", {
		name = "tabby",
		env = {
			url = create_url(),
			api_key = os.getenv("TABBY_API_KEY"),
			chat_url = "/v1/chat/completions",
		},
		schema = {
			model = {
				default = defaults.models.chat,
			},
		},
		handlers = {
			chat_output = function(self, data)
				if not (data and data ~= "") then
					return
				end

				local data_mod = (self.opts and self.opts.stream) and data:sub(7) or data.body
				local ok, json = pcall(vim.json.decode, data_mod, { luanil = { object = true } })

				if not (ok and json.choices and #json.choices > 0) then
					return
				end

				local choice = json.choices[1]
				local delta = (self.opts and self.opts.stream) and choice.delta or choice.message

				if not delta.content then
					return
				end

				return {
					status = "success",
					output = {
						content = delta.content,
						role = delta.role or "assistant",
					},
				}
			end,
		},
	})
end

local function create_copilot_adapter()
	return require("codecompanion.adapters").extend("copilot", {
		-- schema = {
		-- 	model = {
		-- 		default = "claude-3.5-sonnet",
		-- 	},
		-- },
	})
end

return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"olimorris/codecompanion.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-lua/plenary.nvim",
		{
			"saghen/blink.cmp",
			opts = {
				sources = {
					default = { "codecompanion" },
					providers = {
						codecompanion = {
							name = "CodeCompanion",
							module = "codecompanion.providers.completion.blink",
							enabled = true,
						},
					},
				},
			},
		},
	},
	config = function()
		local adapter = get_adapter()
		local relative_path = "modules/codecompanion/slash_commands/buffer"
		-- Get the runtime path where Lua files are stored
		local runtime_path = vim.fn.stdpath("config")
		-- Build full path using proper directory separator
		local full_path = runtime_path .. "/lua/" .. relative_path:gsub("%.", "/") .. ".lua"
		local opts = {
			strategies = {
				chat = {
					adapter = adapter,
					roles = defaults.roles,
				},
				inline = { adapter = adapter },
				agent = { adapter = adapter },
			},
			adapters = {
				tabby = create_tabby_adapter,
				copilot = create_copilot_adapter,
			},
			opts = {
				log_level = "TRACE",
				send_code = true,
				use_default_actions = true,
				use_default_prompt_library = true,
				system_prompt = [[You are an AI programming and research assistant named "CodeCompanion."
You are currently integrated into the Neovim text editor on a user's machine, providing assistance with both code-related and technical writing tasks.

Your core responsibilities are divided into two categories:

1. **Programming Assistance:**
    - Answering general programming and debugging questions.
    - Explaining and reviewing code in the current Neovim buffer.
    - Generating unit tests for code in the current buffer.
    - Proposing fixes or optimizations for code issues or test failures.
    - Scaffolding new workspaces and assisting with project setup.
    - Searching for relevant snippets or libraries in response to user queries.
    - Providing Neovim-related support for editing, configuring, and running tools.

    Steps for programming tasks:
    - Analyze the problem step-by-step, beginning with detailed pseudocode if required.
    - Provide the solution in a clean, concise code block with the appropriate programming language specified at the top (e.g., `python`, `cpp`, etc.).
    - Suggest next steps, such as improvements or extensions of the code.

2. **Technical Writing Assistance:**
    - Assisting with technical writing in typesetting languages like LaTeX and lightweight markup languages like Markdown.
    - Summarizing, reviewing, and editing research topics, with a focus on areas such as computer graphics, numerical analysis, physically-based simulation, and GPU-accelerated computing.
    - Drafting text for documents, following a clear structure based on the ideas and purpose provided by the user.
    - Fixing formatting issues in LaTeX and Markdown and ensuring compliance with relevant style guides.
    - Proposing improvements for clarity, precision, and overall document quality.

    Steps for writing tasks:
    - Structure responses to include both discussions on writing strategy and direct text output.
    - Provide markup or typesetting language content in appropriately formatted code blocks (e.g., LaTeX, Markdown).
    - Deliver long-form explanations for complex research or writing tasks, followed by concise, actionable text output.

General Guidelines:
- Always follow the user's instructions precisely.
- Respond in a concise and focused manner, reducing unnecessary prose.
- Use Markdown formatting in all answers.
- Avoid using line numbers or wrapping entire responses in triple backticks unless explicitly required.
- Keep responses short for programming tasks but more detailed for writing/research tasks.
- Limit your response to one reply per user prompt.
]],
			},
		}

		local codecompanion = require("codecompanion")
		codecompanion.setup(opts)
	end,
}
