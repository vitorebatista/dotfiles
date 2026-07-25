-- aerospace_profiles: leftmost bar item — workspace-group profiles.
-- A profile is a named set of workspaces; the bar shows only the active
-- profile's workspaces. See helpers/workspace_profiles.lua for the model.

local colors   = require("colors")
local settings = require("settings")
local icons    = require("icons")
local profiles = require("helpers.workspace_profiles")
profiles.init()

local ROW_WIDTH = 220

local anchor = sbar.add("item", "aerospace.profiles", {
	position = "left",
	icon = {
		string = icons.yabai.stack,
		color  = colors.white,
	},
	label = {
		string = profiles.get_active() or "",
		color  = colors.grey,
		drawing = profiles.get_active() ~= nil,
	},
	popup = { align = "left" },
})

sbar.add("bracket", "aerospace.profiles.bracket", { anchor.name }, {
	background = { color = colors.bg1 },
})

sbar.add("item", "aerospace.profiles.padding", {
	position = "left",
	width = settings.group_paddings,
})

-- Global so items/aerospace.lua can refresh the label when focus-driven
-- profile switches happen.
function updateProfilesAnchor()
	local active = profiles.get_active()
	anchor:set({ label = { string = active or "", drawing = active ~= nil } })
end

-- ─── osascript dialogs ───────────────────────────────────────────────────────

local function shellQuote(s)
	return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function asQuote(s)
	return '"' .. tostring(s):gsub('"', '\\"') .. '"'
end

local function askName(prompt, cb)
	local script = "display dialog " .. asQuote(prompt) ..
		' default answer "" with title ' .. asQuote("AeroSpace Profiles") ..
		' buttons {"Cancel","OK"} default button "OK"'
	sbar.exec("osascript -e " .. shellQuote(script) .. " 2>/dev/null", function(out)
		local name = out and out:match("text returned:(.*)$")
		if name then name = name:gsub("[\r\n]+$", "") end
		if not name or name:match("^%s*$") then cb(nil) else cb(name) end
	end)
end

local function pickProfile(prompt, cb)
	local names = profiles.list()
	if #names == 0 then cb(nil) return end
	local quoted = {}
	for _, n in ipairs(names) do table.insert(quoted, asQuote(n)) end
	local script = "choose from list {" .. table.concat(quoted, ",") .. "} with prompt " ..
		asQuote(prompt) .. " with title " .. asQuote("AeroSpace Profiles")
	sbar.exec("osascript -e " .. shellQuote(script) .. " 2>/dev/null", function(out)
		local choice = out and out:match("^([^\r\n]+)")
		if not choice or choice == "false" then cb(nil) else cb(choice) end
	end)
end

-- ─── popup content ───────────────────────────────────────────────────────────

local popup_rows = {}
local popup_open = false

local function clearPopupRows()
	for _, name in ipairs(popup_rows) do
		sbar.remove(name)
	end
	popup_rows = {}
end

local function addRow(id_suffix, text, color, onClick)
	local name = anchor.name .. ".row." .. id_suffix
	local item = sbar.add("item", name, {
		position   = "popup." .. anchor.name,
		icon       = { drawing = false },
		label      = {
			string = text,
			color  = color or colors.white,
			width  = ROW_WIDTH,
			align  = "left",
		},
		background = { drawing = false },
	})
	if onClick then
		item:subscribe("mouse.clicked", onClick)
	end
	table.insert(popup_rows, name)
	return item
end

local function addSeparator(id_suffix)
	local name = anchor.name .. ".row.sep" .. id_suffix
	sbar.add("item", name, {
		position   = "popup." .. anchor.name,
		icon       = { drawing = false },
		label      = { drawing = false },
		width      = ROW_WIDTH,
		background = {
			drawing = true,
			color   = colors.bg2,
			height  = 1,
		},
	})
	table.insert(popup_rows, name)
end

local function closePopup()
	popup_open = false
	anchor:set({ popup = { drawing = false } })
end

local function afterModelChange()
	updateProfilesAnchor()
	if refreshAllSpaceVisibility then refreshAllSpaceVisibility() end
	closePopup()
end

-- Activate a profile: switch the bar filter and jump to one of its workspaces
-- (otherwise the focused workspace would flip the active profile right back).
local function activate(name)
	profiles.set_active(name)
	local ws = profiles.workspaces_of(name)[1]
	if ws and sbar.aerospace then
		sbar.aerospace:workspace(ws)
	end
	afterModelChange()
end

local function rebuildPopup(cb)
	clearPopupRows()
	addRow("header", "Profiles", colors.grey)

	local names = profiles.list()
	if #names == 0 then
		addRow("empty", "No profiles yet", colors.grey)
	else
		for i, name in ipairs(names) do
			local active = (name == profiles.get_active())
			local ws_list = table.concat(profiles.workspaces_of(name), " ")
			local prefix = active and "✓ " or "   "
			local text = prefix .. name .. (ws_list ~= "" and ("   [" .. ws_list .. "]") or "   [empty]")
			addRow("p" .. i, text, active and colors.green or colors.white, function()
				activate(name)
			end)
		end
	end

	addSeparator("actions")

	addRow("new", "+  New profile…", colors.white, function()
		askName("New profile name:", function(name)
			if name and profiles.create(name) then afterModelChange() else closePopup() end
		end)
	end)

	addRow("rename", "Rename profile…", colors.white, function()
		pickProfile("Rename which profile?", function(old)
			if not old then closePopup() return end
			askName("New name for " .. old .. ":", function(new)
				if new and profiles.rename(old, new) then afterModelChange() else closePopup() end
			end)
		end)
	end)

	addRow("delete", "Delete profile…", colors.red, function()
		pickProfile("Delete which profile?", function(name)
			if name and profiles.delete(name) then afterModelChange() else closePopup() end
		end)
	end)

	if cb then cb() end
end

anchor:subscribe("mouse.clicked", function()
	if popup_open then
		closePopup()
		return
	end
	rebuildPopup(function()
		popup_open = true
		anchor:set({ popup = { drawing = true } })
	end)
end)
