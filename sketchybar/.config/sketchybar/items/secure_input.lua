local settings = require("settings")
local colors = require("colors")

-- Warns when macOS Secure Input is active: it blocks global hotkeys, silently
-- breaking AeroSpace bindings. Shows the offending app + PID.
-- From https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-13980046
local secure_input = sbar.add("item", "secure_input", {
	position = "left",
	drawing = false,
	update_freq = 10,
	icon = {
		string = "󰀦",
		color = colors.red,
		font = settings.label_font,
		padding_left = 8,
	},
	label = {
		color = colors.red,
		font = settings.label_font,
		padding_left = 4,
		padding_right = 8,
	},
	padding_left = 1,
	padding_right = 1,
})

secure_input:subscribe({ "forced", "routine", "system_woke" }, function(env)
	sbar.exec(
		"pid=$(ioreg -l -w 0 | grep SecureInput | sed -n 's/.*PID\"=\\([0-9]\\{1,\\}\\).*/\\1/p' | head -n1); "
			.. "[ -n \"$pid\" ] && echo \"$pid $(ps -p $pid -o comm= | xargs basename 2>/dev/null)\"",
		function(result)
			local pid, app = tostring(result):match("^(%d+)%s*([^\r\n]*)")
			if not pid then
				secure_input:set({ drawing = false })
				return
			end
			app = (app and app ~= "") and app or "?"
			secure_input:set({
				drawing = true,
				label = { string = "Secure Input: " .. app .. " (" .. pid .. ")" },
			})
		end
	)
end)
