local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local aerospace_bin = settings.binaries.aerospace
local app_font = "sketchybar-app-font:Regular:" .. settings.font_sizes.app

local function trim(value)
	return value and value:gsub("^%s*(.-)%s*$", "%1") or value
end

local function aerospace_exec(arguments, callback)
	sbar.exec(aerospace_bin .. " " .. arguments, callback)
end

sbar.add("event", "aerospace_refresh")
sbar.add("event", "aerospace_mode_change")

local aerospace_workspace = sbar.add("item", "aerospace.ws", {
	click_script = "/opt/homebrew/bin/aerospace workspace-back-and-forth",
	icon = {
		font = settings.label_font,
		padding_left = 10,
		padding_right = 0,
		color = colors.white,
	},
	label = { drawing = false },
	padding_left = 1,
})

local aerospace_apps = sbar.add("item", "aerospace.apps", {
	click_script = "/opt/homebrew/bin/aerospace workspace next --wrap-around",
	icon = {
		font = app_font,
		color = colors.white,
		padding_right = 2,
		drawing = false,
	},
	label = {
		font = app_font,
		color = colors.grey,
		padding_right = 10,
		y_offset = -1,
	},
	padding_right = 1,
})

sbar.add("bracket", { aerospace_workspace.name, aerospace_apps.name }, {
	background = colors.island,
})

local function render_workspace(workspace_id)
	if not workspace_id or workspace_id == "" then
		return
	end

	aerospace_exec(
		string.format("list-windows --workspace %q --format '%%{app-name}'", workspace_id),
		function(workspace_apps_output)
			aerospace_exec("list-windows --focused --format '%{app-name}|%{workspace}'", function(focused_output)
				local focused_app, focused_workspace = string.match(focused_output, "^([^|]+)|([^|\r\n]+)")
				focused_app = trim(focused_app)
				focused_workspace = trim(focused_workspace)

				local active_icon = ""
				local inactive_icons = ""
				local seen_apps = {}

				for app_name in string.gmatch(workspace_apps_output, "[^\r\n]+") do
					local normalized_app_name = trim(app_name)
					if normalized_app_name ~= "" and not seen_apps[normalized_app_name] then
						seen_apps[normalized_app_name] = true
						local glyph = app_icons[normalized_app_name] or app_icons.Default or "—"
						if normalized_app_name == focused_app and focused_workspace == workspace_id then
							active_icon = glyph
						else
							inactive_icons = inactive_icons .. glyph
						end
					end
				end

				if active_icon == "" and inactive_icons == "" then
					inactive_icons = " —"
				end

				aerospace_exec("list-modes --current", function(mode_output)
					local current_mode = trim(mode_output)
					local workspace_label = workspace_id
					local extra_padding = 0
					if current_mode == "service" then
						workspace_label = workspace_id .. "[S]"
						extra_padding = 4
					end

					aerospace_workspace:set({
						icon = workspace_label,
						padding_right = 1 + extra_padding,
					})

					local icon_padding = (inactive_icons == "") and 10 or 2
					if active_icon ~= "" then
						aerospace_apps:set({
							icon = { string = active_icon, drawing = true, padding_right = icon_padding },
							label = { string = inactive_icons, drawing = inactive_icons ~= "" },
						})
						return
					end

					aerospace_apps:set({
						icon = { drawing = false, padding_right = 2 },
						label = { string = inactive_icons, drawing = true },
					})
				end)
			end)
		end)
end

local function refresh_workspace(env)
	local workspace_id = env.FOCUSED_WORKSPACE
	if workspace_id and workspace_id ~= "" then
		render_workspace(workspace_id)
		return
	end

	aerospace_exec("list-workspaces --focused", function(focused_workspace_output)
		render_workspace(trim(focused_workspace_output))
	end)
end

aerospace_workspace:subscribe({ "aerospace_refresh", "front_app_switched", "aerospace_mode_change" }, refresh_workspace)

aerospace_exec("list-workspaces --focused", function(focused_workspace_output)
	local workspace_id = trim(focused_workspace_output)
	if workspace_id and workspace_id ~= "" then
		sbar.trigger("aerospace_refresh", { FOCUSED_WORKSPACE = workspace_id })
	end
end)
