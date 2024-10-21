local wezterm = require("wezterm")

local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

return {
	-- Start WezTerm maximized (fullscreen without hiding decorations)
	-- initial_rows = 24,
	-- initial_cols = 80,

	-- Set the font
	font = wezterm.font("JetBrainsMono Nerd Font"),
	font_size = 13.0,

	-- Use the Catppuccin color scheme
	color_scheme = "Tokyo Night",
	--
	-- Sets the window decoration to very minimal
	window_decorations = "NONE",

	-- Customize additional settings as needed
	-- window_background_opacity = 0.98, -- Slight transparency

	-- tab bar
	-- tab_bar_at_bottom = true,
	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	tab_and_split_indices_are_zero_based = true,

	-- Cursor style and blinking
	-- default_cursor_style = "BlinkingBlock",

	-- Padding around the terminal window
	window_padding = {
		left = 10,
		right = 10,
		top = 10,
		bottom = 10,
	},
}
