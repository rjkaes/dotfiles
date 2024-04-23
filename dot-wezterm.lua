local wezterm = require 'wezterm'

local scheme_for_appearance = function(appearance)
  if appearance:find 'Light' then
    return 'Catppuccin Latte'
  else
    return 'Catppuccin Mocha'
  end
end

local config = {}

config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.font = wezterm.font_with_fallback {
    -- { family = 'Monaspace Xenon Var', weight = "Light" },
    { family = 'Iosevka Nerd Font Mono', weight = 'Regular' },
    -- 'JetBrainsMonoNL NFM',
    'Apple Color Emoji',
}
config.font_size = 18
config.use_cap_height_to_scale_fallback_fonts = true

-- no ligatures!
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.adjust_window_size_when_changing_font_size = false
config.animation_fps = 1
-- config.freetype_load_target = 'Light'
-- config.freetype_load_flags = 'NO_AUTOHINT'
-- config.freetype_render_target = 'Normal'
config.front_end = 'WebGpu'
config.hide_tab_bar_if_only_one_tab = true
config.initial_cols = 142
config.initial_rows = 47
config.scrollback_lines = 5000
config.tab_bar_at_bottom = true
config.term = 'wezterm'
config.use_dead_keys = false
config.window_decorations = 'RESIZE'
config.macos_window_background_blur = 30
config.window_background_opacity = 1.0

config.colors = {
    -- Overrides the cell background color when the current cell is occupied by the
    -- cursor and the cursor style is set to Block
    cursor_bg = '#52ad70',
    -- Overrides the text color when the current cell is occupied by the cursor
    cursor_fg = 'black',
    -- Specifies the border color of the cursor when the cursor style is set to Block,
    -- or the color of the vertical or horizontal bar when the cursor style is set to
    -- Bar or Underline.
    cursor_border = '#52ad70',
}

config.audible_bell = 'Disabled'
config.visual_bell = {
    fade_in_duration_ms = 75,
    fade_out_duration_ms = 75,
    target = 'CursorColor',
}
config.window_padding = {
    left = '10px',
    right = '10px',
    top = '5px',
    bottom = '5px',
}
config.window_frame = {
    font = wezterm.font { family = 'Noto Sans', weight = 'Regular' }
}
config.keys = {
    {
        key = 'Enter',
        mods = 'SUPER',
        action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
        key = 'Enter',
        mods = 'SUPER | SHIFT',
        action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    -- open web links on the sceeen
    {
        key="e",
        mods="CTRL|ALT",  -- CTRL | OPTION
        action=wezterm.action{QuickSelectArgs={
            patterns={
                "https?://(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)[^()]",
                -- "http?://[\\S]+",
                -- "https?://[\\S]+",
            },
            action = wezterm.action_callback(function(window, pane)
                local url = window:get_selection_text_for_pane(pane)
                wezterm.open_with(url)
            end),
        },
        },
    },
    { key = 'D', mods = 'SUPER', action = wezterm.action.ShowDebugOverlay },
}

return config
