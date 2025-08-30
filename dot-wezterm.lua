local wezterm = require 'wezterm'

local is_dark = function()
    if wezterm.gui then
        return wezterm.gui.get_appearance():find('Dark')
    end
    return true
end

local scheme_for_appearance = function()
    if is_dark() then
        return 'Catppuccin Mocha'
    else
        return 'Catppuccin Latte'
    end
end

local config = {}

config.font = wezterm.font_with_fallback {
    { family = 'CommitMono Nerd Font', weight = "Regular" },
    'Apple Color Emoji',
}
config.font_size = 16.5
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

config.color_scheme = scheme_for_appearance()

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

    -- use the theme to determine the background color
    background = is_dark() and "black" or "white",
}

config.visual_bell = {
    fade_in_duration_ms = 75,
    fade_out_duration_ms = 75,
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
        key = "e",
        mods = "CTRL|ALT", -- CTRL | OPTION
        action = wezterm.action { QuickSelectArgs = {
            patterns = {
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

wezterm.on('update-status', function(window)
    -- Grab the utf8 character for the "powerline" left facing
    -- solid arrow.
    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

    -- Grab the current window's configuration, and from it the
    -- palette (this is the combination of your chosen colour scheme
    -- including any overrides).
    local color_scheme = window:effective_config().resolved_palette
    local bg = color_scheme.background
    local fg = color_scheme.foreground

    local date = wezterm.strftime '%a %b %-d %H:%M '

    window:set_right_status(wezterm.format({
        -- First, we draw the arrow...
        { Background = { Color = 'none' } },
        { Foreground = { Color = bg } },
        { Text = SOLID_LEFT_ARROW },
        -- Then we draw our text
        { Background = { Color = bg } },
        { Foreground = { Color = fg } },
        { Text = ' ' .. date .. ' ' },
    }))
end)

return config
