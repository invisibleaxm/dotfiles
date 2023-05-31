local wezterm = require("wezterm")

local module = {}
local colors = {}

-- local selected_scheme =
-- theme names :
--"Batman"
--"Tango Dark"
-- "tokyonight_night";
-- local selected_scheme = "Catppuccin Mocha"
local selected_scheme = "Tango (terminal.sexy)"
local scheme = wezterm.get_builtin_color_schemes()[selected_scheme]

colors.active_bg = scheme.selection_bg
colors.active_fg = scheme.ansi[6]
colors.bg = scheme.background
colors.hl_1 = scheme.ansi[5]
colors.hl_2 = scheme.ansi[4]
local bg = wezterm.color.parse(scheme.background)
local _, _, l, _ = bg:hsla()
if l > 0.5 then
	colors.inactive_fg = bg:complement_ryb():darken(0.3)
	colors.panel_bg = bg:darken(0.069)
else
	colors.inactive_fg = bg:complement_ryb():lighten(0.3)
	colors.panel_bg = bg:lighten(0.069)
end

scheme.tab_bar = {
	-- background = colors.bg,
	background = "none",
	new_tab = {
		-- bg_color = colors.bg,
		bg_color = "none",
		fg_color = colors.hl_2,
	},
	active_tab = {
		bg_color = colors.active_bg,
		fg_color = colors.active_fg,
	},
	inactive_tab = {
		bg_color = colors.bg,
		fg_color = colors.inactive_fg,
	},
	inactive_tab_hover = {
		bg_color = colors.bg,
		fg_color = colors.inactive_fg,
	},
}

module.colors = colors

function module.apply_to_config(config)
	config.color_scheme = selected_scheme
	config.color_schemes = {
		[selected_scheme] = scheme,
	}
	config.command_palette_bg_color = colors.panel_bg
	config.command_palette_fg_color = colors.hl_1
	config.command_palette_font_size = 16
	config.inactive_pane_hsb = {
		saturation = 0.66,
		brightness = 0.54,
	}
	config.font = wezterm.font_with_fallback({
		"JetBrains Mono",
		{ family = "Symbols Nerd Font Mono", scale = 0.80 },
	})
	config.font_size = 11
	config.tab_bar_at_bottom = true
	config.tab_max_width = 50
	config.use_fancy_tab_bar = false
	config.window_background_opacity = 0.93
	-- config.window_decorations = "RESIZE"
	config.initial_cols = 120
	config.initial_rows = 30
	config.enable_scroll_bar = true

	-- config.enable_tab_bar = true
	-- config.hide_tab_bar_if_only_one_tab = true
	-- config.use_fancy_tab_bar = false
	-- config.tab_max_width = 35
	config.show_tab_index_in_tab_bar = true
	config.switch_to_last_active_tab_when_closing_tab = true
	config.window_close_confirmation = "NeverPrompt"
	config.window_padding = {
		left = 5,
		right = 10,
		top = 12,
		bottom = 7,
	}
end

return module
