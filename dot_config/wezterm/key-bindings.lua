local wezterm = require("wezterm")
local act = wezterm.action
local mod = "LEADER"

return {

	{ mods = mod, key = "k", action = act.ActivatePaneDirection("Up") },
	{ mods = mod, key = "j", action = act.ActivatePaneDirection("Down") },
	{ mods = mod, key = "l", action = act.ActivatePaneDirection("Right") },
	{ mods = mod, key = "h", action = act.ActivatePaneDirection("Left") },
	{ mods = "LEADER|CTRL", key = "t", action = act.SpawnTab("CurrentPaneDomain") },
	{ mods = "SUPER", key = "c", action = act.CopyTo("Clipboard") },
	{ mods = "SUPER", key = "v", action = act.PasteFrom("Clipboard") },
	{ mods = "CTRL|SHIFT", key = "c", action = act.CopyTo("Clipboard") },
	{ mods = "CTRL|SHIFT", key = "v", action = act.PasteFrom("Clipboard") },
	{ mods = "LEADER|SHIFT", key = "|", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ mods = mod, key = "-", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	--	{ mods = mod, key = "M", action = act.TogglePaneZoomState },
	{ mods = mod, key = "p", action = act.PaneSelect({ alphabet = "", mode = "Activate" }) },
	--	{ mods = mod, key = "C", action = act.CopyTo("ClipboardAndPrimarySelection") },
	--	{ mods = mod, key = "l", action = wezterm.action({ ActivateTabRelative = 1 }) },
	--	{ mods = mod, key = "h", action = wezterm.action({ ActivateTabRelative = -1 }) },
	-- CTRL-SHIFT-l activates the debug overlay
	{ key = "L", mods = "LEADER|SHIFT", action = wezterm.action.ShowDebugOverlay },
	{ key = "1", mods = "ALT", action = wezterm.action.ActivateTab(0) },
	{ key = "2", mods = "ALT", action = wezterm.action.ActivateTab(1) },
	{ key = "3", mods = "ALT", action = wezterm.action.ActivateTab(2) },
	{ key = "4", mods = "ALT", action = wezterm.action.ActivateTab(3) },
	{ key = "5", mods = "ALT", action = wezterm.action.ActivateTab(4) },
	{ key = "6", mods = "ALT", action = wezterm.action.ActivateTab(5) },
	{ key = "7", mods = "ALT", action = wezterm.action.ActivateTab(6) },
	{ key = "8", mods = "ALT", action = wezterm.action.ActivateTab(7) },
	{ key = "9", mods = "ALT", action = wezterm.action.ActivateTab(-1) },
	{ key = "f", mods = mod, action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	{ key = "n", mods = "LEADER|CTRL", action = wezterm.action.SpawnWindow },
	{ key = "t", mods = "LEADER|CTRL", action = wezterm.action.SpawnTab },
}
