local wezterm = require("wezterm")
local act = wezterm.action
local mod = "LEADER"

return {

	{ mods = mod, key = "k", action = act.ActivatePaneDirection("Up") },
	{ mods = mod, key = "j", action = act.ActivatePaneDirection("Down") },
	{ mods = mod, key = "l", action = act.ActivatePaneDirection("Right") },
	{ mods = mod, key = "h", action = act.ActivatePaneDirection("Left") },
	{ mods = "LEADER|CTRL", key = "t", action = act.SpawnTab("CurrentPaneDomain") },
	{ mods = "LEADER|SHIFT", key = "|", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ mods = mod, key = "-", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	--	{ mods = mod, key = "M", action = act.TogglePaneZoomState },
	{ mods = mod, key = "p", action = act.PaneSelect({ alphabet = "", mode = "Activate" }) },
	--	{ mods = mod, key = "C", action = act.CopyTo("ClipboardAndPrimarySelection") },
	--	{ mods = mod, key = "l", action = wezterm.action({ ActivateTabRelative = 1 }) },
	--	{ mods = mod, key = "h", action = wezterm.action({ ActivateTabRelative = -1 }) },
	-- CTRL-SHIFT-l activates the debug overlay
	{ key = "L", mods = "LEADER|SHIFT", action = wezterm.action.ShowDebugOverlay },
	{ key = "1", mods = mod, action = wezterm.action.ActivateTab(0) },
}
