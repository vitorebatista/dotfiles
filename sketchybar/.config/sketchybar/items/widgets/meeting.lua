local colors = require("colors")
local settings = require("settings")

-- Next-meeting item via icalBuddy (Bartender hides MeetingBar's menu-bar item
-- off-screen, so an alias of it captures blank). Only events from the
-- vitor.batista@trustedhealth.com calendar are considered.
-- Shows "HH:MM · Title" before the meeting and "Xmin left · Title" during it.
local ICALBUDDY = "/opt/homebrew/bin/icalBuddy"
local QUERY = ICALBUDDY
	.. " -ic 'vitor.batista@trustedhealth.com'"
	.. " -n -li 1 -b '' -nc -ps '| . |' -iep 'datetime,title' -po 'datetime,title' -tf '%H:%M' -df '' eventsToday"

local meeting = sbar.add("item", "widgets.meeting", {
	position = "right",
	update_freq = 60,
	icon = {
		string = "󰃰",
		color = colors.white,
		padding_left = 8,
	},
	label = {
		color = colors.white,
		padding_left = 4,
		padding_right = 8,
		max_chars = 40,
	},
	padding_left = 1,
	padding_right = 1,
	click_script = "open -a Calendar",
})

sbar.add("bracket", "widgets.meeting.bracket", { meeting.name }, {
	background = { color = colors.bg1 },
})

sbar.add("item", "widgets.meeting.padding", {
	position = "right",
	width = settings.group_paddings,
})

meeting:subscribe({ "forced", "routine", "system_woke" }, function(env)
	sbar.exec(QUERY .. " 2>/dev/null", function(result)
		local line = tostring(result):match("[^\r\n]+")
		line = line and line:gsub("^%s+", ""):gsub("%s+$", "") or ""
		if line == "" or line:find("error:") then
			meeting:set({ drawing = false })
			return
		end

		-- line looks like "10:00 - 10:30 . Standup" (or "23:30 - ... . Test"
		-- when the event ends after midnight)
		local timepart, title = line:match("^(.-) %. (.+)$")
		if not timepart then
			meeting:set({ drawing = true, label = { string = line } })
			return
		end

		local sh, sm, eh, em = timepart:match("(%d+):(%d+)%s*%-%s*(%d+):(%d+)")
		if not sh then
			sh, sm = timepart:match("(%d+):(%d+)")
		end

		local label = timepart .. " · " .. title
		if sh then
			local now = tonumber(os.date("%H")) * 60 + tonumber(os.date("%M"))
			local start_min = tonumber(sh) * 60 + tonumber(sm)
			if now >= start_min then -- event already started
				if eh then
					local end_min = tonumber(eh) * 60 + tonumber(em)
					if end_min <= start_min then -- ends after midnight
						end_min = end_min + 24 * 60
					end
					label = (end_min - now) .. "min left · " .. title
				else -- end time unknown (rendered as "..." by icalBuddy)
					label = "now · " .. title
				end
			else
				label = sh .. ":" .. sm .. " · " .. title
			end
		end

		meeting:set({ drawing = true, label = { string = label } })
	end)
end)
