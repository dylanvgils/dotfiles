local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- font settings
config.font_size = 12
config.line_height = 1

-- Window appearance
config.enable_tab_bar = true
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_background_opacity = 0.82
config.macos_window_background_blur = 20
config.window_padding = {
	left = "6px",
	right = "6px",
	top = "6px",
	bottom = "6px",
}

return config
