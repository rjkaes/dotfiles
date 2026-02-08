-- TODO: https://rashil2000.me/blogs/tune-wezterm

local wezterm = require 'wezterm'

local function colors_for_appearance(appearance)
  if appearance:find('Dark') then
    return 'Catppuccin Mocha', 'black'
  else
    return 'Catppuccin Latte', 'white'
  end
end

local config = wezterm.config_builder()

-- Set initial color scheme; also updated dynamically via window-config-reloaded
-- below so that switching macOS appearance takes effect without restart.
local initial_appearance = (wezterm.gui and wezterm.gui.get_appearance()) or 'Light'
local initial_scheme, initial_bg = colors_for_appearance(initial_appearance)
config.color_scheme = initial_scheme

config.font = wezterm.font_with_fallback {
    { family = 'Maple Mono Normal NL NF', weight = "Regular" },
    -- { family = 'CommitMono Nerd Font', weight = "Regular" },
    'Apple Color Emoji',
}
config.font_size = 17
config.use_cap_height_to_scale_fallback_fonts = true

-- no ligatures!
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.adjust_window_size_when_changing_font_size = false
config.animation_fps = 1
config.front_end = 'WebGpu'
config.hide_tab_bar_if_only_one_tab = true
config.initial_cols = 142
config.initial_rows = 47
config.macos_window_background_blur = 30
config.max_fps = 60
config.scrollback_lines = 5000
config.status_update_interval = 10000
config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.term = 'wezterm'
config.underline_thickness = '1.5pt'
config.use_dead_keys = false
config.webgpu_power_preference = 'LowPower'
config.window_background_opacity = 1.0
config.window_decorations = 'RESIZE'

-- config.freetype_load_target = 'Light'
-- config.freetype_load_flags = 'NO_AUTOHINT'
-- config.freetype_render_target = 'Normal'

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

    -- Use the theme to determine the background color; also updated dynamically
    -- via the window-config-reloaded handler.
    background = initial_bg,
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
    -- Open web links on the screen
    {
        key = "e",
        mods = "CTRL|ALT", -- CTRL | OPTION
        action = wezterm.action { QuickSelectArgs = {
            patterns = {
                -- Match URLs including those with balanced parentheses (e.g. Wikipedia).
                -- The inner group allows paired parens like (bar) while the outer
                -- negative-lookahead trims trailing punctuation that isn't part of the URL.
                "https?://[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b(?:[-a-zA-Z0-9()@:%_\\+.~#?&/=]*\\([-a-zA-Z0-9()@:%_\\+.~#?&/=]*\\))*[-a-zA-Z0-9()@:%_\\+.~#?&/=]*",
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

-- Dynamically switch color scheme and background when macOS appearance changes.
-- The guard against the current scheme prevents an infinite loop of
-- set_config_overrides -> window-config-reloaded -> set_config_overrides.
wezterm.on('window-config-reloaded', function(window, pane)
    local overrides = window:get_config_overrides() or {}
    local scheme, bg = colors_for_appearance(window:get_appearance())

    if overrides.color_scheme ~= scheme then
        overrides.color_scheme = scheme
        overrides.colors = {
            cursor_bg = '#52ad70',
            cursor_fg = 'black',
            cursor_border = '#52ad70',
            background = bg,
        }
        window:set_config_overrides(overrides)
    end
end)

wezterm.on('update-status', function(window)
    -- Skip when the tab bar is hidden (single tab) since the status
    -- line isn't visible anyway.
    if #window:mux_window():tabs() < 2 then
        return
    end

    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

    local color_scheme = window:effective_config().resolved_palette
    local bg = color_scheme.background
    local fg = color_scheme.foreground

    local date = wezterm.strftime '%a %b %-d %H:%M '

    window:set_right_status(wezterm.format({
        { Background = { Color = 'none' } },
        { Foreground = { Color = bg } },
        { Text = SOLID_LEFT_ARROW },
        { Background = { Color = bg } },
        { Foreground = { Color = fg } },
        { Text = ' ' .. date .. ' ' },
    }))
end)

return config
