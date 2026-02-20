-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- For example, changing the color scheme:
config.color_scheme = "Horizon Dark (base16)"
-- config.color_scheme = "rose-pine"

config.front_end = "WebGpu"

config.font = wezterm.font({ family = "VictorMono Nerd Font" })
config.font_rules = {
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font({
			family = "VictorMono Nerd Font",
			weight = "Bold",
			style = "Italic",
		}),
	},
	{
		italic = true,
		intensity = "Half",
		font = wezterm.font({
			family = "VictorMono Nerd Font",
			weight = "DemiBold",
			style = "Italic",
		}),
	},
	{
		italic = true,
		intensity = "Normal",
		font = wezterm.font({
			family = "VictorMono Nerd Font",
			style = "Italic",
		}),
	},
}

config.default_prog = { "nu" }

config.ssh_domains = {
	{
		name = "GTA-RIL",
		remote_address = "10.80.55.19",
		username = "gta",
		multiplexing = "None",

		-- When multiplexing == "None", default_prog can be used
		-- to specify the default program to run in new tabs/panes.
		-- Due to the way that ssh works, you cannot specify default_cwd,
		-- but you could instead change your default_prog to put you
		-- in a specific directory.
		default_prog = { "~/.pixi/bin/nu" },

		-- assume that we can use syntax like:
		-- "env -C /some/where $SHELL"
		-- using whatever the default command shell is on this
		-- remote host, so that shell integration will respect
		-- the current directory on the remote host.
		assume_shell = "Posix",
	},
}

config.skip_close_confirmation_for_processes_named = {
	"bash",
	"sh",
	"zsh",
	"fish",
	"tmux",
	"nu",
	"nu.exe",
	"cmd.exe",
	"pwsh.exe",
	"powershell.exe",
}

-- and finally, return the configuration to wezterm
return config
