--- workspace_profiles: profiles are named GROUPS OF WORKSPACES.
--
-- The bar shows only the active profile's workspaces. Focusing a workspace
-- that belongs to another profile switches the active profile (and thus the
-- visible workspace list). A workspace that belongs to no profile is shown
-- under every profile, and is adopted by the active profile the moment it
-- gets its first window.
--
-- (This replaces the previous snapshot-based helpers/layout_persist.lua,
-- which is kept on disk unused for future reference.)
--
-- State: ~/.local/state/aerospace/workspace_profiles.json
--   { "active": "Work", "profiles": { "Work": ["1","2"], "Personal": ["W"] } }

local json = require("dkjson")

local STATE_DIR  = os.getenv("HOME") .. "/.local/state/aerospace"
local STATE_FILE = STATE_DIR .. "/workspace_profiles.json"

local M = {
	active = nil,
	profiles = {}, -- name -> array of workspace names
}

local function readFile(path)
	local f = io.open(path, "r")
	if not f then return nil end
	local c = f:read("*a")
	f:close()
	return c
end

local function persist()
	os.execute("mkdir -p '" .. STATE_DIR .. "'")
	local f = io.open(STATE_FILE, "w")
	if not f then return end
	f:write(json.encode({ active = M.active, profiles = M.profiles }, { indent = true }))
	f:close()
end

function M.init()
	local content = readFile(STATE_FILE)
	if content then
		local ok, doc = pcall(json.decode, content)
		if ok and type(doc) == "table" and type(doc.profiles) == "table" then
			M.profiles = doc.profiles
			M.active = doc.active
			return
		end
	end
	-- First run: seed with the previously created profile names
	M.profiles = {
		Personal = { "W", "9", "8" },
		Work = { "1", "2", "4", "5", "C", "M", "S" },
	}
	M.active = "Work"
	persist()
end

function M.list()
	local names = {}
	for name, _ in pairs(M.profiles) do table.insert(names, name) end
	table.sort(names)
	return names
end

function M.get_active()
	return M.active
end

function M.workspaces_of(name)
	return M.profiles[name] or {}
end

-- profile that owns a workspace, or nil if unassigned
function M.profile_of(ws)
	for name, list in pairs(M.profiles) do
		for _, w in ipairs(list) do
			if w == ws then return name end
		end
	end
	return nil
end

-- Should this workspace show in the bar right now?
-- Unassigned workspaces show under every profile.
function M.is_visible(ws)
	local owner = M.profile_of(ws)
	return owner == nil or owner == M.active
end

-- Focus moved to `ws`. Returns true if the active profile changed.
function M.on_focus(ws)
	if not ws or ws == "" then return false end
	local owner = M.profile_of(ws)
	if owner and owner ~= M.active then
		M.active = owner
		persist()
		return true
	end
	return false
end

-- `ws` just got its first window. Adopt it into the active profile if it is
-- unassigned. Returns true if it was adopted.
function M.on_nonempty(ws)
	if not ws or ws == "" or not M.active then return false end
	if M.profile_of(ws) ~= nil then return false end
	table.insert(M.profiles[M.active], ws)
	persist()
	return true
end

function M.set_active(name)
	if not M.profiles[name] or M.active == name then return false end
	M.active = name
	persist()
	return true
end

function M.create(name)
	if not name or name:match("^%s*$") or M.profiles[name] then return false end
	M.profiles[name] = {}
	M.active = name
	persist()
	return true
end

function M.rename(old, new)
	if not M.profiles[old] or M.profiles[new] or not new or new:match("^%s*$") then return false end
	M.profiles[new] = M.profiles[old]
	M.profiles[old] = nil
	if M.active == old then M.active = new end
	persist()
	return true
end

function M.delete(name)
	if not M.profiles[name] then return false end
	M.profiles[name] = nil
	if M.active == name then
		M.active = M.list()[1] -- fall back to any remaining profile (or nil)
	end
	persist()
	return true
end

-- Remove a workspace from whichever profile owns it (it becomes unassigned).
function M.unassign(ws)
	for name, list in pairs(M.profiles) do
		for i, w in ipairs(list) do
			if w == ws then
				table.remove(list, i)
				persist()
				return true
			end
		end
	end
	return false
end

return M
