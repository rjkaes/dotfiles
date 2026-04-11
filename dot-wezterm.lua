-- TODO: https://rashil2000.me/blogs/tune-wezterm

local wezterm = require 'wezterm'

-- Wormbytes palette, matching the Neovim colorscheme in
-- dot-config/nvim/colors/wormbytes.lua
local wormbytes = {
  dark = {
    foreground = '#E8E8E8',
    background = '#1a1b26',
    cursor_bg = '#52ad70',
    cursor_fg = '#1a1b26',
    cursor_border = '#52ad70',
    selection_bg = '#2A2D3D',
    selection_fg = '#E8E8E8',
    ansi = {
      '#1a1b26',  -- black  (bg)
      '#E06C75',  -- red
      '#98C379',  -- green
      '#E5C07B',  -- yellow
      '#61AFEF',  -- blue
      '#C678DD',  -- magenta
      '#56B6C2',  -- cyan
      '#E8E8E8',  -- white  (fg)
    },
    brights = {
      '#4E4E4E',  -- bright black  (gray4)
      '#FF6B6B',  -- bright red
      '#A8E6A1',  -- bright green
      '#FFD93D',  -- bright yellow
      '#74C0FC',  -- bright blue
      '#E8A0E8',  -- bright magenta
      '#66D9EF',  -- bright cyan
      '#FFFFFF',  -- bright white
    },
  },
  light = {
    foreground = '#1C1C1C',
    background = '#FAFAF8',
    cursor_bg = '#52ad70',
    cursor_fg = '#FFFFFF',
    cursor_border = '#52ad70',
    selection_bg = '#C0BDB6',
    selection_fg = '#1C1C1C',
    ansi = {
      '#FAFAF8',  -- black  (bg)
      '#C7254E',  -- red
      '#27761B',  -- green
      '#8F5E00',  -- yellow
      '#0366D6',  -- blue
      '#8250DF',  -- magenta
      '#07738F',  -- cyan
      '#1C1C1C',  -- white  (fg)
    },
    brights = {
      '#9E9E9E',  -- bright black  (gray5)
      '#D73A49',  -- bright red
      '#22863A',  -- bright green
      '#946D00',  -- bright yellow
      '#005CC5',  -- bright blue
      '#6F42C1',  -- bright magenta
      '#047A9A',  -- bright cyan
      '#1C1C1C',  -- bright white  (fg)
    },
  },
}

local function colors_for_appearance(appearance)
  if appearance:find('Dark') then
    return wormbytes.dark
  else
    return wormbytes.light
  end
end

local config = wezterm.config_builder()

-- Set initial colors; also updated dynamically via window-config-reloaded
-- below so that switching macOS appearance takes effect without restart.
local initial_appearance = (wezterm.gui and wezterm.gui.get_appearance()) or 'Light'
local initial_colors = colors_for_appearance(initial_appearance)

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
config.max_fps = 60
config.scrollback_lines = 5000
config.status_update_interval = 1000
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

config.colors = initial_colors

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

-- Dynamically switch colors when macOS appearance changes.
-- The guard against the current background prevents an infinite loop of
-- set_config_overrides -> window-config-reloaded -> set_config_overrides.
wezterm.on('window-config-reloaded', function(window, pane)
    local overrides = window:get_config_overrides() or {}
    local colors = colors_for_appearance(window:get_appearance())

    if not overrides.colors or overrides.colors.background ~= colors.background then
        overrides.color_scheme = nil
        overrides.colors = colors
        window:set_config_overrides(overrides)
        wezterm.background_child_process { '/Users/rjk/bin/setbg' }
    end
end)

-- Collapse a file path's home prefix to "~".
local function collapse_home(path)
    local home = os.getenv('HOME') or ''
    if home ~= '' and path:sub(1, #home) == home then
        return '~' .. path:sub(#home + 1)
    end
    return path
end

-- Shorten a path by keeping the first and last components when it has
-- more than `max_parts` segments: ~/a/b/c/d -> ~/a/…/d
local function shorten_path(path, max_parts)
    -- Separate a leading "~/" prefix so it doesn't count as a segment.
    local prefix, rest = path:match('^(~/)(.+)$')
    if not prefix then
        prefix = ''
        rest = path
    end

    local parts = {}
    for part in rest:gmatch('[^/]+') do
        table.insert(parts, part)
    end

    if #parts <= max_parts then
        return path
    end

    return prefix .. parts[1] .. '/\u{2026}/' .. parts[#parts]
end

local shells = { fish = true, bash = true, zsh = true, sh = true, nu = true }

-- Show "process cwd" in each tab, but hide the process name when it's
-- just the user's shell since that's the idle default state.
wezterm.on('format-tab-title', function(tab)
    local pane = tab.active_pane
    local process = (pane.foreground_process_name or ''):match('[^/]+$') or ''

    local cwd = ''
    if pane.current_working_dir then
        cwd = shorten_path(collapse_home(pane.current_working_dir.file_path or ''), 3)
    end

    -- Only show the process name when a real command is running, not the shell.
    local title
    if shells[process] then
        title = (cwd ~= '') and cwd or process
    else
        title = process
        if cwd ~= '' then
            title = title .. ' ' .. cwd
        end
    end

    return ' ' .. title .. ' '
end)

wezterm.on('update-status', function(window)
    -- Skip when the tab bar is hidden (single tab) since the status
    -- line isn't visible anyway.
    if #window:mux_window():tabs() < 2 then
        return
    end

    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

    local palette = window:effective_config().resolved_palette
    local bg = palette.background
    local fg = palette.foreground

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
