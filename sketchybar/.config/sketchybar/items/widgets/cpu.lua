local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0", function() end)

-- Threshold color shared by cpu and memory (icon color = load level)
local function load_color(load)
  if load > 80 then return colors.red end
  if load > 60 then return colors.orange end
  if load > 30 then return colors.yellow end
  return colors.blue
end

local cpu = sbar.add("item", "widgets.cpu", {
  position = "right",
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = {
    string = icons.cpu,
    color = colors.blue,
    padding_right = settings.paddings + 3,
  },
  label = {
    string = "??%",
    align = "left",
    padding_left = 0,
  },
  padding_right = settings.paddings + 6,
})

cpu:subscribe("cpu_update", function(env)
  -- Also available: env.user_load, env.sys_load
  local load = tonumber(env.total_load)
  cpu:set({
    icon = { color = load_color(load) },
    label = env.total_load .. "%",
  })
end)

cpu:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a Stats", function() end)
end)

-- Memory usage, sharing the CPU island
local memory = sbar.add("item", "widgets.memory", {
  position = "right",
  update_freq = 10,
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = {
    string = "󰍛",
    color = colors.blue,
    padding_right = settings.paddings + 3,
  },
  label = {
    string = "??%",
    align = "left",
    padding_left = 0,
  },
  padding_right = settings.paddings + 6,
})

memory:subscribe({ "routine", "forced", "system_woke" }, function(env)
  sbar.exec("memory_pressure -Q | awk '/percentage/ {print 100-$5}'", function(out)
    local pct = tonumber(tostring(out):match("%d+"))
    if pct then
      memory:set({
        icon = { color = load_color(pct) },
        label = pct .. "%",
      })
    end
  end)
end)

memory:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a Stats", function() end)
end)

-- Disk usage, sharing the CPU island
local disk = sbar.add("item", "widgets.disk", {
  position = "right",
  update_freq = 300,
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = {
    string = "󰋊",
    color = colors.blue,
    padding_right = settings.paddings + 3,
  },
  label = {
    string = "??%",
    align = "left",
    padding_left = 0,
  },
  padding_right = settings.paddings + 6,
})

disk:subscribe({ "routine", "forced", "system_woke" }, function(env)
  sbar.exec("df /System/Volumes/Data | awk 'NR==2 {gsub(\"%\",\"\",$5); print $5}'", function(out)
    local pct = tonumber(tostring(out):match("%d+"))
    if pct then
      disk:set({
        icon = { color = load_color(pct) },
        label = pct .. "%",
      })
    end
  end)
end)

disk:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a Stats", function() end)
end)

-- Background around the cpu island
sbar.add("bracket", "widgets.cpu.bracket", { cpu.name, memory.name, disk.name }, {
  background = { color = colors.bg1 }
})

sbar.add("item", "widgets.cpu.padding", {
  position = "right",
  width = settings.group_paddings
})
