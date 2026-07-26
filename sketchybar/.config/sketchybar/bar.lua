local colors = require("colors")

-- Floating bar style (from the previous wady-based config):
-- margins + y_offset + rounded corners + subtle border
sbar.bar({
  height = 32,
  color = colors.bar.bg,
  padding_left = 1,
  padding_right = 0,
  margin = 8,
  y_offset = 6,
  corner_radius = 10,
  border_width = 1,
  border_color = colors.bar.border,
  -- blur_radius costs a lot to recomposite on every display rebuild (lock/wake
  -- churn: SketchyBar #336). Re-enable if the wake stall is gone and you miss it.
  -- blur_radius = 12,
})
