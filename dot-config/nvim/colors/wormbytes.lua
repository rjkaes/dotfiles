-- Adaptive Theme for Neovim

local M = {}

-- Clear existing highlights
vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') then
  vim.cmd('syntax reset')
end

-- Set theme name
vim.g.colors_name = 'wormbytes'

-- Define palettes
local palettes = {
  dark = {
    -- Base colors
    bg = '#000000',      -- black
    fg = '#E8E8E8',      -- white

    -- Grays (Dark to Light)
    gray1 = '#1C1C1C',
    gray2 = '#262626',
    gray3 = '#3A3A3A',
    gray4 = '#4E4E4E',
    gray5 = '#626262',
    gray6 = '#767676',
    gray7 = '#8A8A8A',
    gray8 = '#9E9E9E',
    gray9 = '#B2B2B2',
    gray10 = '#C6C6C6',
    gray11 = '#DADADA',

    -- Meaningful accent colors
    red = '#E06C75',        -- Soft red for errors/deletion
    green = '#98C379',      -- Natural green for strings/addition
    yellow = '#E5C07B',     -- Warm yellow for warnings/numbers
    blue = '#61AFEF',       -- Cool blue for keywords/types
    magenta = '#C678DD',    -- Purple for functions/special
    cyan = '#56B6C2',       -- Teal for constants/preprocessor
    orange = '#D19A66',     -- Orange for operators/special chars

    -- Brighter variants for emphasis
    bright_red = '#FF6B6B',
    bright_green = '#A8E6A1',
    bright_yellow = '#FFD93D',
    bright_blue = '#74C0FC',
    bright_magenta = '#DA70D6',
    bright_cyan = '#66D9EF',

    -- Special colors
    error = '#E06C75',
    warning = '#E5C07B',
    info = '#61AFEF',
    hint = '#8A8A8A',

    -- UI Specifics
    line_nr = '#767676',      -- gray6
    pmenu_sel_bg = '#E5C07B', -- yellow
    search_fg = '#000000',    -- black (bg)

    -- CodeCompanion
    chat_header = '#E8E8E8',  -- white (fg)
  },
  light = {
    -- Base colors
    bg = '#FFFFFF',      -- white
    fg = '#1C1C1C',      -- black

    -- Grays (Light to Dark)
    gray1 = '#F5F5F5',
    gray2 = '#E8E8E8',
    gray3 = '#D4D4D4',
    gray4 = '#B8B8B8',
    gray5 = '#9E9E9E',
    gray6 = '#858585',
    gray7 = '#6B6B6B',
    gray8 = '#525252',
    gray9 = '#3A3A3A',
    gray10 = '#2A2A2A',
    gray11 = '#1C1C1C',

    -- Meaningful accent colors (adjusted for light background)
    red = '#C7254E',        -- Deep red for errors/deletion
    green = '#27761B',      -- Rich green for strings/addition
    yellow = '#A56C00',     -- Deep yellow for warnings/numbers
    blue = '#0366D6',       -- Strong blue for keywords/types
    magenta = '#8250DF',    -- Purple for functions/special
    cyan = '#0884A8',       -- Teal for constants/preprocessor
    orange = '#C25D00',     -- Orange for operators/special chars

    -- Brighter variants for emphasis
    bright_red = '#D73A49',
    bright_green = '#22863A',
    bright_yellow = '#B58900',
    bright_blue = '#005CC5',
    bright_magenta = '#6F42C1',
    bright_cyan = '#0598BC',

    -- Special colors
    error = '#C7254E',
    warning = '#A56C00',
    info = '#0366D6',
    hint = '#6B6B6B',

    -- UI Specifics
    line_nr = '#9E9E9E',      -- gray5
    pmenu_sel_bg = '#0366D6', -- blue
    search_fg = '#FFFFFF',    -- white (bg)

    -- CodeCompanion
    chat_header = '#1C1C1C',  -- black (fg)
  }
}

-- Select palette based on background
local colors = palettes[vim.o.background] or palettes.dark

-- Terminal colors
vim.g.terminal_color_0 = colors.bg
vim.g.terminal_color_1 = colors.red
vim.g.terminal_color_2 = colors.green
vim.g.terminal_color_3 = colors.yellow
vim.g.terminal_color_4 = colors.blue
vim.g.terminal_color_5 = colors.magenta
vim.g.terminal_color_6 = colors.cyan
vim.g.terminal_color_7 = colors.fg
vim.g.terminal_color_8 = colors.gray4
vim.g.terminal_color_9 = colors.bright_red
vim.g.terminal_color_10 = colors.bright_green
vim.g.terminal_color_11 = colors.bright_yellow
vim.g.terminal_color_12 = colors.bright_blue
vim.g.terminal_color_13 = colors.bright_magenta
vim.g.terminal_color_14 = colors.bright_cyan
vim.g.terminal_color_15 = colors.fg

-- Helper function to set highlights
local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- =========================================
-- Semantic Abstractions (Base Groups)
-- =========================================

-- Severity & Status
hi('BaseError',   { fg = colors.error })
hi('BaseWarn',    { fg = colors.warning })
hi('BaseInfo',    { fg = colors.info })
hi('BaseHint',    { fg = colors.hint })
hi('BaseSuccess', { fg = colors.green })
hi('BaseErrorBold', { fg = colors.error, bold = true })
hi('BaseWarnBold',  { fg = colors.warning, bold = true })

-- Syntax Basics
hi('BaseComment',   { fg = colors.gray7, italic = true })
hi('BaseString',    { fg = colors.green })
hi('BaseCharacter', { fg = colors.green })
hi('BaseNumber',    { fg = colors.orange })
hi('BaseBoolean',   { fg = colors.red })
hi('BaseFloat',     { fg = colors.orange })
hi('BaseConstant',  { fg = colors.cyan })

hi('BaseFunction',  { fg = colors.magenta })
hi('BaseMethod',    { fg = colors.magenta })
hi('BaseKeyword',   { fg = colors.blue })
hi('BaseType',      { fg = colors.yellow })
hi('BaseProperty',  { fg = colors.fg })
hi('BaseIdentifier',{ fg = colors.fg })
hi('BaseOperator',  { fg = colors.orange })
hi('BaseSpecial',   { fg = colors.orange })
hi('BaseDelimiter', { fg = colors.gray9 })

hi('BasePreProc',   { fg = colors.cyan })
hi('BaseUrl',       { fg = colors.cyan, underline = true })

-- UI Basics
hi('BaseBg',        { bg = colors.bg })
hi('BaseFg',        { fg = colors.fg })
hi('BaseSubtext',   { fg = colors.gray7 })
hi('BaseDim',       { fg = colors.gray6 })
hi('BaseBorder',    { fg = colors.gray4 })
hi('BasePanel',     { bg = colors.gray1 })
hi('BaseSelection', { bg = colors.gray3 })

-- =========================================
-- Editor Highlights
-- =========================================
hi('Normal',       { fg = colors.fg, bg = colors.bg })
hi('NormalNC',     { fg = (vim.o.background == 'light') and colors.gray9 or colors.gray10, bg = colors.bg })

hi('NormalFloat',  { fg = colors.fg, bg = colors.gray1 })
hi('FloatBorder',  { fg = colors.gray4, bg = colors.gray1 })
hi('FloatTitle',   { fg = colors.blue, bg = colors.gray1, bold = true })

hi('ColorColumn',  { bg = colors.gray1 })
hi('Cursor',       { fg = colors.bg, bg = colors.fg })
hi('CursorLine',   { bg = colors.gray1 })
hi('CursorColumn', { bg = colors.gray1 })
hi('CursorLineNr', { fg = colors.orange, bg = colors.gray1, bold = true })

hi('LineNr',       { fg = colors.line_nr })
hi('SignColumn',   { fg = colors.line_nr, bg = colors.bg })

hi('Visual',       { link = 'BaseSelection' })
hi('VisualNOS',    { link = 'BaseSelection' })

hi('Search',       { fg = colors.search_fg, bg = colors.yellow })
hi('IncSearch',    { fg = colors.search_fg, bg = colors.orange })
hi('CurSearch',    { fg = colors.search_fg, bg = colors.bright_yellow })

hi('MatchParen',   { fg = colors.cyan, bg = colors.gray2, bold = true })

hi('VertSplit',    { fg = colors.gray4, bg = colors.bg })
hi('WinSeparator', { fg = colors.gray4, bg = colors.bg })

hi('StatusLine',   { fg = colors.fg, bg = colors.gray2 })
hi('StatusLineNC', { fg = colors.gray7, bg = colors.gray1 })
hi('WinBar',       { fg = colors.fg, bg = colors.bg })
hi('WinBarNC',     { fg = colors.gray7, bg = colors.bg })

hi('TabLine',      { fg = colors.gray8, bg = colors.gray1 })
hi('TabLineFill',  { fg = colors.gray6, bg = colors.gray1 })
hi('TabLineSel',   { fg = colors.fg, bg = colors.gray3, bold = true })

hi('Pmenu',        { fg = colors.fg, bg = colors.gray2 })
hi('PmenuSel',     { fg = colors.bg, bg = colors.pmenu_sel_bg })
hi('PmenuSbar',    { bg = colors.gray3 })
hi('PmenuThumb',   { bg = colors.gray5 })

hi('Folded',       { fg = colors.gray7, bg = colors.gray1 })
hi('FoldColumn',   { fg = colors.gray6, bg = colors.bg })

hi('DiffAdd',      { fg = colors.green, bg = colors.bg })
hi('DiffChange',   { fg = colors.yellow, bg = colors.bg })
hi('DiffDelete',   { fg = colors.red, bg = colors.bg })
hi('DiffText',     { fg = colors.blue, bg = colors.bg, bold = true })

hi('SpellBad',     { fg = colors.red, undercurl = true })
hi('SpellCap',     { fg = colors.yellow, undercurl = true })
hi('SpellLocal',   { fg = colors.cyan, undercurl = true })
hi('SpellRare',    { fg = colors.magenta, undercurl = true })

hi('ErrorMsg',     { link = 'BaseErrorBold' })
hi('WarningMsg',   { link = 'BaseWarnBold' })
hi('ModeMsg',      { fg = colors.fg, bold = true })
hi('MoreMsg',      { fg = colors.green, bold = true })
hi('Question',     { fg = colors.cyan, bold = true })

hi('Conceal',      { link = 'BaseDim' })
hi('Directory',    { link = 'BaseKeyword' })
hi('NonText',      { link = 'BaseBorder' })
hi('SpecialKey',   { link = 'BaseBorder' })
hi('Title',        { fg = colors.blue, bold = true })
hi('QuickFixLine', { bg = colors.gray2 })

-- =========================================
-- Syntax Highlighting
-- =========================================
hi('Comment',      { link = 'BaseComment' })
hi('Constant',     { link = 'BaseConstant' })
hi('String',       { link = 'BaseString' })
hi('Character',    { link = 'BaseCharacter' })
hi('Number',       { link = 'BaseNumber' })
hi('Boolean',      { link = 'BaseBoolean' })
hi('Float',        { link = 'BaseFloat' })

hi('Identifier',   { link = 'BaseIdentifier' })
hi('Function',     { link = 'BaseFunction' })

hi('Statement',    { link = 'BaseKeyword' })
hi('Conditional',  { link = 'BaseKeyword' })
hi('Repeat',       { link = 'BaseKeyword' })
hi('Label',        { link = 'BaseKeyword' })
hi('Operator',     { link = 'BaseOperator' })
hi('Keyword',      { link = 'BaseKeyword' })
hi('Exception',    { link = 'BaseError' })

hi('PreProc',      { link = 'BasePreProc' })
hi('Include',      { link = 'BasePreProc' })
hi('Define',       { link = 'BasePreProc' })
hi('Macro',        { link = 'BasePreProc' })
hi('PreCondit',    { link = 'BasePreProc' })

hi('Type',         { link = 'BaseType' })
hi('StorageClass', { link = 'BaseType' })
hi('Structure',    { link = 'BaseType' })
hi('Typedef',      { link = 'BaseType' })

hi('Special',      { link = 'BaseSpecial' })
hi('SpecialChar',  { link = 'BaseSpecial' })
hi('Tag',          { fg = colors.magenta })
hi('Delimiter',    { link = 'BaseDelimiter' })
hi('SpecialComment', { fg = colors.cyan, italic = true })
hi('Debug',        { fg = colors.red })

hi('Underlined',   { fg = colors.blue, underline = true })
hi('Ignore',       { fg = colors.gray5 })
hi('Error',        { fg = colors.red, bg = colors.bg, bold = true })
hi('Todo',         { fg = colors.bg, bg = colors.yellow, bold = true })

-- =========================================
-- LSP Highlights
-- =========================================
hi('DiagnosticError',       { link = 'BaseError' })
hi('DiagnosticWarn',        { link = 'BaseWarn' })
hi('DiagnosticInfo',        { link = 'BaseInfo' })
hi('DiagnosticHint',        { link = 'BaseHint' })
hi('DiagnosticOk',          { link = 'BaseSuccess' })
hi('DiagnosticUnnecessary', { link = 'BaseComment' })

hi('DiagnosticUnderlineError', { undercurl = true, sp = colors.error })
hi('DiagnosticUnderlineWarn',  { undercurl = true, sp = colors.warning })
hi('DiagnosticUnderlineInfo',  { undercurl = true, sp = colors.info })
hi('DiagnosticUnderlineHint',  { undercurl = true, sp = colors.hint })

-- Legacy LSP Support
hi('LspDiagnosticsError', { link = "DiagnosticError" })
hi('LspDiagnosticsWarning', { link = "DiagnosticWarn" })
hi('LspDiagnosticsInfo', { link = "DiagnosticInfo" })
hi('LspDiagnosticsHint', { link = "DiagnosticHint" })
hi('LspDiagnosticsUnderlineError', { link = "DiagnosticUnderlineError" })
hi('LspDiagnosticsUnderlineWarning', { link = "DiagnosticUnderlineWarn" })
hi('LspDiagnosticsUnderlineInfo', { link = "DiagnosticUnderlineInfo" })
hi('LspDiagnosticsUnderlineHint', { link = "DiagnosticUnderlineHint" })

-- LSP Semantic Tokens
hi('LspReferenceText',  { bg = colors.gray2 })
hi('LspReferenceRead',  { bg = colors.gray2 })
hi('LspReferenceWrite', { bg = colors.gray3 })
hi('LspSignatureActiveParameter', { fg = colors.orange, bold = true })
hi('LspCodeLens',          { link = 'BaseDim' })
hi('LspCodeLensSeparator', { link = 'BaseDim' })

-- =========================================
-- Treesitter Highlights (modern captures, nvim-treesitter ≥ Jan 2024)
-- =========================================
-- Captures that fall back correctly through the hierarchy (e.g.
-- @keyword.conditional → @keyword → Keyword → BaseKeyword) are omitted.
-- Only captures where the fallback gives the wrong color, or where an
-- explicit anchor improves clarity, are defined here.

-- Fallback anchors & misc
hi('@comment',              { link = 'BaseComment' })
hi('@error',                { link = 'Error' })
hi('@none',                 { link = 'BaseFg' })
hi('@operator',             { link = 'BaseOperator' })

-- Punctuation
hi('@punctuation.delimiter', { link = 'BaseDelimiter' })
hi('@punctuation.bracket',   { link = 'BaseDelimiter' })
hi('@punctuation.special',   { link = 'BaseSpecial' })

-- Variables & identifiers
hi('@variable',                  { link = 'BaseIdentifier' })
hi('@variable.builtin',          { fg = colors.red })
hi('@variable.parameter',        { link = 'BaseIdentifier' })
hi('@variable.parameter.builtin', { fg = colors.red })
hi('@variable.member',           { link = 'BaseProperty' })
hi('@property',                  { link = 'BaseProperty' })

-- Constants
hi('@constant',         { link = 'BaseConstant' })
hi('@constant.builtin', { fg = colors.cyan, bold = true })
hi('@constant.macro',   { link = 'BasePreProc' })
hi('@boolean',          { link = 'BaseBoolean' })

-- Functions
hi('@function',              { link = 'BaseFunction' })
hi('@function.builtin',      { fg = colors.magenta, bold = true })
hi('@function.call',         { link = 'BaseFunction' })
hi('@function.macro',        { link = 'BasePreProc' })
hi('@function.method',       { link = 'BaseMethod' })
hi('@function.method.call',  { link = 'BaseMethod' })
hi('@constructor',           { link = 'BaseType' })

-- Keywords — only those that need a different color than @keyword → BaseKeyword
hi('@keyword',                 { link = 'BaseKeyword' })
hi('@keyword.function',        { link = 'BaseKeyword' })
hi('@keyword.operator',        { link = 'BaseKeyword' })
hi('@keyword.return',          { link = 'BaseKeyword' })
hi('@keyword.import',          { link = 'BasePreProc' })
hi('@keyword.exception',       { link = 'BaseError' })
hi('@keyword.directive',       { link = 'BasePreProc' })
hi('@keyword.directive.define', { link = 'BasePreProc' })
hi('@keyword.storage',         { link = 'BaseType' })
hi('@keyword.debug',           { link = 'Debug' })

-- Types & modules
hi('@type',            { link = 'BaseType' })
hi('@type.builtin',    { fg = colors.yellow, bold = true })
hi('@type.definition', { link = 'BaseType' })
hi('@type.qualifier',  { link = 'BaseKeyword' })
hi('@attribute',       { link = 'BaseConstant' })
hi('@module',          { link = 'BaseType' })
hi('@module.builtin',  { link = 'BaseType' })

-- Strings & characters
hi('@string',                { link = 'BaseString' })
hi('@string.escape',         { link = 'BaseSpecial' })
hi('@string.special',        { link = 'BaseSpecial' })
hi('@string.regexp',         { link = 'BaseSpecial' })
hi('@string.special.symbol', { link = 'BaseConstant' })
hi('@string.special.url',    { link = 'BaseUrl' })
hi('@character',             { link = 'BaseCharacter' })
hi('@character.special',     { link = 'BaseSpecial' })

-- Numbers
hi('@number',       { link = 'BaseNumber' })
hi('@number.float', { link = 'BaseFloat' })

-- Comment annotations
hi('@comment.documentation', { link = 'BaseComment' })
hi('@comment.error',         { link = 'DiagnosticError' })
hi('@comment.warning',       { link = 'DiagnosticWarn' })
hi('@comment.todo',          { link = 'Todo' })
hi('@comment.note',          { link = 'DiagnosticInfo' })

-- Markup (Markdown) — no @markup Vim fallback group, so all need explicit defs
hi('@markup.heading',        { link = 'Title' })
hi('@markup.strong',         { bold = true })
hi('@markup.italic',         { italic = true })
hi('@markup.strikethrough',  { strikethrough = true })
hi('@markup.underline',      { underline = true })
hi('@markup.raw',            { link = 'BaseString' })
hi('@markup.raw.block',      { link = 'BaseString' })
hi('@markup.link',           { link = 'BaseConstant' })
hi('@markup.link.label',     { link = 'BaseConstant' })
hi('@markup.link.url',       { link = 'BaseUrl' })
hi('@markup.list',           { link = 'BaseSpecial' })
hi('@markup.list.checked',   { link = 'BaseSuccess' })
hi('@markup.list.unchecked', { link = 'BaseDim' })
hi('@markup.quote',          { fg = colors.gray7, italic = true })
hi('@markup.math',           { link = 'BaseNumber' })

-- Tags (HTML/JSX/TSX)
hi('@tag',           { link = 'Tag' })
hi('@tag.builtin',   { fg = colors.blue, bold = true })
hi('@tag.attribute', { link = 'BaseType' })
hi('@tag.delimiter', { link = 'BaseDelimiter' })

-- Diff
hi('@diff.plus',  { link = 'BaseSuccess' })
hi('@diff.minus', { link = 'BaseError' })
hi('@diff.delta', { link = 'BaseWarn' })

-- Language-specific overrides
hi('@attribute.html',     { link = 'BaseType' })
hi('@tag.html',           { link = 'BaseKeyword' })
hi('@tag.builtin.html',   { fg = colors.blue, bold = true })
hi('@property.css',       { link = 'BaseConstant' })
hi('@property.scss',      { link = 'BaseConstant' })
hi('@tag.css',            { link = 'BaseKeyword' })
hi('@tag.scss',           { link = 'BaseKeyword' })
hi('@attribute.css',      { link = 'BaseType' })
hi('@attribute.scss',     { link = 'BaseType' })
hi('@property.json',      { link = 'BaseConstant' })
hi('@variable.member.json', { link = 'BaseConstant' })

-- =========================================
-- Plugin Highlights
-- =========================================

-- Cmp
hi('CmpItemAbbr',           { link = 'BaseFg' })
hi('CmpItemAbbrDeprecated', { fg = colors.gray6, strikethrough = true })
hi('CmpItemAbbrMatch',      { fg = colors.blue, bold = true })
hi('CmpItemAbbrMatchFuzzy', { fg = colors.blue, bold = true })
hi('CmpItemKind',           { link = 'BaseConstant' })
hi('CmpItemMenu',           { link = 'BaseDim' })

-- Indent Blankline
hi('IblIndent', { fg = colors.gray2 })
hi('IblScope',  { link = 'BaseBorder' })

-- Lazy.nvim
hi('LazyNormal',       { fg = colors.fg, bg = colors.gray1 })
hi('LazyH1',           { fg = colors.blue, bold = true })
hi('LazyButton',       { fg = colors.fg, bg = colors.gray3 })
hi('LazyButtonActive', { fg = colors.bg, bg = colors.blue })

-- Mason.nvim
hi('MasonHeader',              { fg = colors.bg, bg = colors.blue, bold = true })
hi('MasonHighlight',           { link = 'BaseKeyword' })
hi('MasonHighlightBlock',      { fg = colors.bg, bg = colors.blue })
hi('MasonHighlightBlockBold',  { fg = colors.bg, bg = colors.blue, bold = true })

-- Notify
hi('NotifyERRORBorder', { link = 'BaseError' })
hi('NotifyWARNBorder',  { link = 'BaseWarn' })
hi('NotifyINFOBorder',  { link = 'BaseInfo' })
hi('NotifyDEBUGBorder', { link = 'BaseDim' })
hi('NotifyTRACEBorder', { link = 'BaseDim' })
hi('NotifyERRORIcon',   { link = 'BaseError' })
hi('NotifyWARNIcon',    { link = 'BaseWarn' })
hi('NotifyINFOIcon',    { link = 'BaseInfo' })
hi('NotifyDEBUGIcon',   { link = 'BaseDim' })
hi('NotifyTRACEIcon',   { link = 'BaseDim' })
hi('NotifyERRORTitle',  { link = 'BaseError' })
hi('NotifyWARNTitle',   { link = 'BaseWarn' })
hi('NotifyINFOTitle',   { link = 'BaseInfo' })
hi('NotifyDEBUGTitle',  { link = 'BaseDim' })
hi('NotifyTRACETitle',  { link = 'BaseDim' })
hi('NotifyBackground',  { link = 'NormalFloat' })

-- CodeCompanion
hi('CodeCompanionChatInfo',       { link = 'BaseInfo' })
hi('CodeCompanionChatError',      { link = 'BaseError' })
hi('CodeCompanionChatWarn',       { link = 'BaseWarn' })
hi('CodeCompanionChatSubtext',    { link = 'BaseSubtext' })
hi('CodeCompanionChatHeader',     { fg = colors.chat_header, bold = true })
hi('CodeCompanionChatSeparator',  { link = 'BaseBorder' })
hi('CodeCompanionChatTokens',     { fg = colors.cyan, italic = true })
hi('CodeCompanionChatTool',       { link = 'BaseFunction' })
hi('CodeCompanionChatToolGroups', { link = 'BaseType' })
hi('CodeCompanionChatVariable',   { link = 'BaseIdentifier' })
hi('CodeCompanionVirtualText',    { link = 'BaseSubtext' })

-- Markview
hi('MarkviewPalette0', { fg = colors.fg, bg = colors.gray2 })
hi('MarkviewPalette0Fg', { fg = colors.fg })
hi('MarkviewPalette0Bg', { bg = colors.gray2 })
hi('MarkviewPalette0Sign', { fg = colors.fg, bg = colors.gray2 })

hi('MarkviewPalette1', { fg = colors.blue, bg = colors.gray2 })
hi('MarkviewPalette1Fg', { fg = colors.blue })
hi('MarkviewPalette1Bg', { bg = colors.gray2 })
hi('MarkviewPalette1Sign', { fg = colors.blue, bg = colors.gray2 })

hi('MarkviewPalette2', { fg = colors.green, bg = colors.gray2 })
hi('MarkviewPalette2Fg', { fg = colors.green })
hi('MarkviewPalette2Bg', { bg = colors.gray2 })
hi('MarkviewPalette2Sign', { fg = colors.green, bg = colors.gray2 })

hi('MarkviewPalette3', { fg = colors.yellow, bg = colors.gray2 })
hi('MarkviewPalette3Fg', { fg = colors.yellow })
hi('MarkviewPalette3Bg', { bg = colors.gray2 })
hi('MarkviewPalette3Sign', { fg = colors.yellow, bg = colors.gray2 })

hi('MarkviewPalette4', { fg = colors.magenta, bg = colors.gray2 })
hi('MarkviewPalette4Fg', { fg = colors.magenta })
hi('MarkviewPalette4Bg', { bg = colors.gray2 })
hi('MarkviewPalette4Sign', { fg = colors.magenta, bg = colors.gray2 })

hi('MarkviewPalette5', { fg = colors.cyan, bg = colors.gray2 })
hi('MarkviewPalette5Fg', { fg = colors.cyan })
hi('MarkviewPalette5Bg', { bg = colors.gray2 })
hi('MarkviewPalette5Sign', { fg = colors.cyan, bg = colors.gray2 })

hi('MarkviewPalette6', { fg = colors.orange, bg = colors.gray2 })
hi('MarkviewPalette6Fg', { fg = colors.orange })
hi('MarkviewPalette6Bg', { bg = colors.gray2 })
hi('MarkviewPalette6Sign', { fg = colors.orange, bg = colors.gray2 })

hi('MarkviewCode', { fg = colors.fg, bg = colors.bg })
hi('MarkviewCodeInfo', { fg = colors.gray7, bg = colors.bg })
hi('MarkviewCodeFg', { fg = colors.fg })
hi('MarkviewInlineCode', { fg = colors.green, bg = colors.bg })

-- Git Signs
hi('GitSignsAdd',    { link = 'BaseSuccess' })
hi('GitSignsChange', { link = 'BaseWarn' })
hi('GitSignsDelete', { link = 'BaseError' })

-- Telescope
hi('TelescopeNormal',        { link = 'Normal' })
hi('TelescopeBorder',        { link = 'FloatBorder' })
hi('TelescopePromptBorder',  { link = 'FloatBorder' })
hi('TelescopeResultsBorder', { link = 'FloatBorder' })
hi('TelescopePreviewBorder', { link = 'FloatBorder' })
hi('TelescopeSelection',     { link = 'PmenuSel' })
hi('TelescopeSelectionCaret',{ fg = colors.orange, bg = colors.pmenu_sel_bg })
hi('TelescopeMatching',      { fg = colors.orange, bold = true })

-- NvimTree
hi('NvimTreeNormal',          { link = 'Normal' })
hi('NvimTreeFolderName',      { link = 'Directory' })
hi('NvimTreeFolderIcon',      { link = 'Directory' })
hi('NvimTreeOpenedFolderName',{ fg = colors.blue, bold = true })
hi('NvimTreeEmptyFolderName', { link = 'BaseSubtext' })
hi('NvimTreeIndentMarker',    { link = 'BaseBorder' })
hi('NvimTreeSpecialFile',     { link = 'BaseType' })
hi('NvimTreeExecFile',        { link = 'BaseSuccess' })
hi('NvimTreeGitDirty',        { link = 'GitSignsChange' })
hi('NvimTreeGitStaged',       { link = 'GitSignsAdd' })
hi('NvimTreeGitMerge',        { link = 'BaseFunction' })
hi('NvimTreeGitRenamed',      { link = 'BaseFunction' })
hi('NvimTreeGitNew',          { link = 'GitSignsAdd' })
hi('NvimTreeGitDeleted',      { link = 'GitSignsDelete' })

-- WhichKey
hi('WhichKey',          { link = 'BaseConstant' })
hi('WhichKeyGroup',     { link = 'BaseKeyword' })
hi('WhichKeyDesc',      { link = 'BaseFg' })
hi('WhichKeySeperator', { link = 'BaseDim' })
hi('WhichKeyFloat',     { link = 'NormalFloat' })
hi('WhichKeyBorder',    { link = 'FloatBorder' })

return M
