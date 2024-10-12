local wezterm = require("wezterm")

local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

return {
	-- Set WSL as the default program
	default_prog = { "wsl.exe" },

	-- Start WezTerm maximized (fullscreen without hiding decorations)
	-- initial_rows = 24,
	-- initial_cols = 80,

	-- Set the font
	font = wezterm.font("JetBrainsMono Nerd Font"),
	font_size = 14.0,

	-- Use the Catppuccin color scheme
	color_scheme = "Tokyo Night",

	-- Customize additional settings as needed
	window_background_opacity = 0.99, -- Slight transparency
	hide_tab_bar_if_only_one_tab = true,

	-- Cursor style and blinking
	--- default_cursor_style = 'BlinkingBlock',

	-- Padding around the terminal window
	window_padding = {
		left = 5,
		right = 5,
		top = 5,
		bottom = 0,
	},
}
