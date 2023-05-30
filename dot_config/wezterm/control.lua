local theme = require("theme")
local util = require("util")
local wezterm = require("wezterm")

local act = wezterm.action
local module = {}

if wezterm.GLOBAL.prev_workspace == nil then
	wezterm.GLOBAL.prev_workspace = "default"
end

wezterm.on("switch-workspace-default", function(window, pane)
	local cur = wezterm.mux.get_active_workspace()
	window:perform_action(act.SwitchToWorkspace({ name = "default" }), pane)
	if cur ~= "default" then
		wezterm.GLOBAL.prev_workspace = cur
	end
	wezterm.log_info("prev_workspace: " .. wezterm.GLOBAL.prev_workspace)
end)

wezterm.on("switch-workspace-prev", function(window, pane)
	local cur = wezterm.mux.get_active_workspace()
	window:perform_action(act.SwitchToWorkspace({ name = wezterm.GLOBAL.prev_workspace }), pane)
	wezterm.GLOBAL.prev_workspace = cur
	wezterm.log_info("prev_workspace: " .. wezterm.GLOBAL.prev_workspace)
end)

local action_project_switcher = wezterm.action_callback(function(window, pane)
	local choices = {}
	local homePath = os.getenv("HOME")
	if homePath == nil then
		homePath = os.getenv("UserProfile")
	end
	for _, v in pairs(util.file_lines(homePath .. "/.projects")) do
		fmt_label = wezterm.format({
			{ Foreground = { Color = theme.colors.hl_1 } },
			{ Text = v },
		})
		table.insert(choices, { id = v, label = fmt_label })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(window, pane, id, label)
				if not id and not label then
					wezterm.log_info("cancelled")
				else
					local cur = wezterm.mux.get_active_workspace()
					window:perform_action(
						act.SwitchToWorkspace({
							name = id,
							spawn = {
								cwd = id,
							},
						}),
						pane
					)
					wezterm.GLOBAL.prev_workspace = cur
					wezterm.log_info("prev_workspace: " .. wezterm.GLOBAL.prev_workspace)
				end
			end),
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end)

local key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "Escape", action = "PopKeyTable" },
	},
}

local keys = {
	{ key = "a", mods = "LEADER|CTRL", action = act.SendString("\x01") },
	{ key = "D", mods = "LEADER", action = wezterm.action.ShowDebugOverlay },

	-- Workpace and Pallette
	{ key = "d", mods = "LEADER|CTRL", action = act.EmitEvent("switch-workspace-default") },
	{ key = "m", mods = "LEADER|CTRL", action = act.ShowLauncher },
	{ key = "f", mods = "LEADER|CTRL", action = action_project_switcher },
	{ key = "F", mods = "LEADER", action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	{ key = "n", mods = "LEADER|CTRL", action = wezterm.action.SpawnWindow },
	{ key = "t", mods = "LEADER|CTRL", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "c", mods = "LEADER|CTRL", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = ")", mods = "LEADER", action = act.SwitchWorkspaceRelative(1) },
	{ key = "(", mods = "LEADER", action = act.SwitchWorkspaceRelative(-1) },
	{ key = "p", mods = "LEADER|CTRL", action = act.ActivateTabRelative(-1) },
	{ key = "n", mods = "LEADER|CTRL", action = act.ActivateTabRelative(1) },
	-- { key = "P",  mods = "LEADER",      action = action_project_switcher, },
	--  { key = "P",  mods = "LEADER|SHIFT", action = act.ActivateCommandPalette },
	{ key = "L", mods = "LEADER", action = act.EmitEvent("switch-workspace-prev") },

	{
		key = "W",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Foreground = { Color = theme.colors.active_fg } },
				{ Text = "New workspace name:" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:perform_action(
						act.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},

	-- Mode
	{ key = "x", mods = "LEADER", action = act.ActivateCopyMode },
	{ key = " ", mods = "LEADER", action = act.QuickSelect },

	{ mods = "SUPER", key = "c", action = act.CopyTo("Clipboard") },
	{ mods = "SUPER", key = "v", action = act.PasteFrom("Clipboard") },
	{ mods = "CTRL|SHIFT", key = "c", action = act.CopyTo("Clipboard") },
	{ mods = "CTRL|SHIFT", key = "v", action = act.PasteFrom("Clipboard") },

	-- Pane Management
	{ key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	{ key = "q", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
	-- { key = "H", mods = "LEADER", action = act.AdjustPaneSize({ "Left", 5 }) },
	-- { key = "J", mods = "LEADER", action = act.AdjustPaneSize({ "Down", 5 }) },
	-- { key = "K", mods = "LEADER", action = act.AdjustPaneSize({ "Up", 5 }) },
	-- { key = "L", mods = "LEADER", action = act.AdjustPaneSize({ "Right", 5 }) },
	{ key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "Z", mods = "LEADER", action = act.TogglePaneZoomState },

	-- Navigation
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{ key = "}", mods = "LEADER", action = act.MoveTabRelative(1) },
	{ key = "{", mods = "LEADER", action = act.MoveTabRelative(-1) },
	{ key = "1", mods = "ALT", action = act.ActivateTab(0) },
	{ key = "2", mods = "ALT", action = act.ActivateTab(1) },
	{ key = "3", mods = "ALT", action = act.ActivateTab(2) },
	{ key = "4", mods = "ALT", action = act.ActivateTab(3) },
	{ key = "5", mods = "ALT", action = act.ActivateTab(4) },
	{ key = "6", mods = "ALT", action = act.ActivateTab(5) },
	{ key = "7", mods = "ALT", action = act.ActivateTab(6) },
	{ key = "8", mods = "ALT", action = act.ActivateTab(7) },
	{ key = "9", mods = "ALT", action = act.ActivateTab(8) },
	-- { key = "0", mods = "LEADER", action = act.ActivateTab(-1) },
	-- { key = "0", mods = "SUPER",  action = act.ActivateTab(-1) },
}

function module.apply_to_config(config)
	config.key_tables = key_tables
	config.keys = keys
	config.leader = { key = "a", mods = "CTRL" }
end

return module
