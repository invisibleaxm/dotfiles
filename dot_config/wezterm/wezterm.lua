-- Pull in the wezterm API
local wezterm = require("wezterm")
local keybindings = require("key-bindings")
local act = wezterm.action

-- This table will hold the configuration.
local config = {}
-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.term = "wezterm" -- not sure if I need this
-- This is where you actually apply your config choices
-- For example, changing the color scheme:
-- config.color_scheme = "AdventureTime"
-- config.color_scheme = "Batman"
config.disable_default_key_bindings = true
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 5000 }
config.keys = keybindings
config.color_scheme = "Catppuccin Mocha"
-- config.color_scheme = "Batman"
-- config.color_scheme = "Tango Dark"
--config.font = wezterm.font("FiraCode Nerd Font")
config.font = wezterm.font_with_fallback({
	"FiraCode",
	{ family = "Symbols Nerd Font Mono", scale = 0.70 },
})
config.font_size = 14
-- config.cell_width = 0.95
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe", "-nologo" }
end
config.window_background_opacity = 0.95
config.initial_cols = 120
config.initial_rows = 30
config.enable_scroll_bar = true
config.scrollback_lines = 5000
config.hyperlink_rules = {
	-- Linkify things that look like URLs and the host has a TLD name.
	-- Compiled-in default. Used if you don't specify any hyperlink_rules.
	{
		regex = "\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
		format = "$0",
	},
	-- linkify email addresses
	-- Compiled-in default. Used if you don't specify any hyperlink_rules.
	{
		regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
		format = "mailto:$0",
	},
	-- file:// URI
	-- Compiled-in default. Used if you don't specify any hyperlink_rules.
	{
		regex = [[\bfile://\S*\b]],
		format = "$0",
	},
	-- Linkify things that look like URLs with numeric addresses as hosts.
	-- E.g. http://127.0.0.1:8000 for a local development server,
	-- or http://192.168.1.1 for the web interface of many routers.
	{
		regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
		format = "$0",
	},

	-- Make username/project paths clickable. This implies paths like the following are for GitHub.
	-- As long as a full URL hyperlink regex exists above this it should not match a full URL to
	-- GitHub or GitLab / BitBucket (i.e. https://gitlab.com/user/project.git is still a whole clickable URL)
	{
		regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
		format = "https://www.github.com/$1/$3",
	},
}

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_max_width = 35
config.show_tab_index_in_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true
config.window_close_confirmation = "NeverPrompt"
-- config.window_frame = {
-- 	active_titlebar_bg = "#090909",
-- 	font_size = 9,
-- }
-- config.inactive_pane_hsb = { saturation = 1.0, brightness = 1.0 }
config.window_padding = {
	left = 5,
	right = 10,
	top = 12,
	bottom = 7,
}

config.mouse_bindings = {
	-- Right click sends "woot" to the terminal
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = act.PasteFrom("PrimarySelection"),
	},
	-- Change the default click behavior so that it only selects
	-- text and doesn't open hyperlinks
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},
	-- and make CTRL-Click open hyperlinks
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
	-- NOTE that binding only the 'Up' event can give unexpected behaviors.
	-- Read more below on the gotcha of binding an 'Up' event only.
}
-- and finally, return the configuration to wezterm
return config
