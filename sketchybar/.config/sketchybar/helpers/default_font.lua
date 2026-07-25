return {
  -- "SF Pro"/"SF Mono" need `brew install --cask font-sf-pro font-sf-mono` (sudo)
  text = "Hack Nerd Font",
  numbers = "Hack Nerd Font",

  -- Hack only ships Regular/Bold
  style_map = {
    ["Regular"] = "Regular",
    ["Semibold"] = "Bold",
    ["Bold"] = "Bold",
    ["Heavy"] = "Bold",
    ["Black"] = "Bold",
  }
}
