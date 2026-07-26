-- Workaround for SketchyBar's sleep/lock bugs: after the display sleeps or the
-- screen is locked, the bar's windows go stale — items stop updating and the bar
-- can be blank or missing until something forces a redraw. Toggling the bar's
-- `display` property re-creates those windows, which is the upstream-suggested
-- fix (see FelixKratz/SketchyBar issues #430, #497, #675, #783).
--
-- Deliberately not `--reload`: that re-runs the whole config (a real restart,
-- rebuilding all 148 items) instead of just re-creating the windows.
local SB = "/opt/homebrew/bin/sketchybar"

local wake = sbar.add("item", "wake_refresh", {
	drawing = false,
	updates = true,
})

wake:subscribe({ "system_woke", "display_change" }, function()
	sbar.exec(SB .. " --bar display=main", function()
		sbar.exec(SB .. " --bar display=all", function() end)
	end)
end)
