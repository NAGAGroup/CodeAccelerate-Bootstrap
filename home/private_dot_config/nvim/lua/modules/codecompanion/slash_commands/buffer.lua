local codecompanion = require("codecompanion")
local buf_cmd = require("codecompanion.strategies.chat.slash_commands.buffer")
local path = require("plenary.path")

local buf = require("codecompanion.utils.buffers")
local config = require("codecompanion.config")
local log = require("codecompanion.utils.log")
local util = require("codecompanion.utils")

local api = vim.api
local fmt = string.format

local function pick_buffer(SlashCommands)
	vim.notify("Picking buffer")
	local selected = require("fzf-lua").buffers({
		actions = {
			["default"] = function(selected)
				return selected
			end,
		},
	})

	local filename = vim.fn.fnamemodify(selected.path, ":t")

	-- If the buffer is not loaded, then read the file
	local content
	if not api.nvim_buf_is_loaded(selected.bufnr) then
		content = path.new(selected.path):read()
		if content == "" then
			return log:warn("Could not read the file: %s", selected.path)
		end
		content = "```" .. vim.filetype.match({ filename = selected.path }) .. "\n" .. content .. "\n```"
	else
		content = buf.format(selected.bufnr)
	end

	local id = "<buf>" .. SlashCommand.Chat.References:make_id_from_buf(selected.bufnr) .. "</buf>"

	SlashCommand.Chat:add_message({
		role = config.constants.USER_ROLE,
		content = fmt(
			[[Here is the content from `%s` (which has a buffer number of _%d_ and a filepath of `%s`):

%s]],
			filename,
			selected.bufnr,
			selected.path,
			content
		),
	}, { reference = id, visible = false })

	SlashCommand.Chat.References:add({
		source = "slash_command",
		name = "buffer",
		id = id,
	})

	util.notify(fmt("Added buffer `%s` to the chat", filename))
end

function buf_cmd.new(args)
	local self = setmetatable({
		Chat = args.Chat,
		config = args.config,
		context = args.context,
	}, { __index = buf_cmd })

	return self
end

function buf_cmd:execute(SlashCommands)
	if not config.opts.send_code and (self.config.opts and self.config.opts.contains_code) then
		return log:warn("Sending of code has been disabled")
	end
	pick_buffer(SlashCommands)
end

return buf_cmd
