return {
	"codecompanion.nvim",
	dependencies = {
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-lua/plenary.nvim",
		},
		config = true,
	},
	config = function()
		local can_access_url = function(url)
			local command = string.format("curl -Is --max-time 5 %s | head -n 1", url)
			local result = vim.fn.system(command)
			return result:match("HTTP/%d%.%d 200")
		end
		local get_default_adapter = function()
			if os.getenv("TABBY_API_KEY") == "" or not can_access_url("http://localhost:8080") then
				return "copilot"
			end

			return "tabby"
		end
		return require("codecompanion").setup({
			strategies = {
				chat = {
					adapter = get_default_adapter(),
					roles = {
						llm = "CodeCompanion", -- The markdown header content for the LLM's responses
						user = "Jack", -- The markdown header for your questions
					},
				},
				inline = {
					adapter = get_default_adapter(),
				},
				agent = {
					adapter = get_default_adapter(),
				},
			},
			adapters = {
				tabby = function()
					return require("codecompanion.adapters").extend("openai_compatible", {
						name = "tabby",
						env = {
							url = "http://localhost:8080", -- optional: default value is tabby url http://127.0.0.1:11434
							api_key = os.getenv("TABBY_API_KEY"), -- optional: if your endpoint is authenticated
							chat_url = "/v1/chat/completions", -- optional: default value, override if different
						},
						schema = {
							model = {
								default = os.getenv("TABBY_CHAT_MODEL"),
							},
						},
						handlers = {
							---Handles missing roles by assuming "assistant"
							chat_output = function(self, data)
								local output = {}

								if data and data ~= "" then
									local data_mod = (self.opts and self.opts.stream) and data:sub(7) or data.body
									local ok, json = pcall(vim.json.decode, data_mod, { luanil = { object = true } })

									if ok then
										if json.choices and #json.choices > 0 then
											local choice = json.choices[1]
											local delta = (self.opts and self.opts.stream) and choice.delta
												or choice.message

											if delta.content then
												output.content = delta.content
												-- Handle missing roles by assigning "assistant"
												output.role = delta.role or "assistant"

												return {
													status = "success",
													output = output,
												}
											end
										end
									end
								end
							end,
						},
					})
				end,
			},
			opts = {
				log_level = "TRACE", -- TRACE|DEBUG|ERROR|INFO
				send_code = true, -- Allow code to be sent to the LLM (use cautiously)

				use_default_actions = true, -- Show the default actions in the action palette?
				use_default_prompt_library = true, -- Show the default prompt library in the action palette?

				-- This is the default prompt which is sent with every request in the chat
				-- strategy. It is primarily based on the GitHub Copilot Chat's prompt
				-- but with some modifications. You can choose to remove this via
				-- your own config but note that LLM results may not be as good
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
		})
	end,
}
