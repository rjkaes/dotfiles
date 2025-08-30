-- High Contrast Dark Theme for Neovim

local M = {}

-- Clear existing highlights
vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') then
  vim.cmd('syntax reset')
end

-- Set theme name
vim.g.colors_name = 'high_contrast_dark'

-- Define color palette
local colors = {
  -- Base colors
  black = '#000000',
  white = '#E8E8E8',
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
}

-- Helper function to set highlights
local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Editor highlights
hi('Normal', { fg = colors.white, bg = colors.black })
hi('NormalFloat', { fg = colors.white, bg = colors.gray1 })
hi('NormalNC', { fg = colors.gray10, bg = colors.black })

-- Cursor
hi('Cursor', { fg = colors.black, bg = colors.white })
hi('CursorLine', { bg = colors.gray1 })
hi('CursorColumn', { bg = colors.gray1 })
hi('CursorLineNr', { fg = colors.orange, bg = colors.gray1, bold = true })

-- Line numbers
hi('LineNr', { fg = colors.gray6 })
hi('SignColumn', { fg = colors.gray6, bg = colors.black })

-- Visual selection
hi('Visual', { bg = colors.gray3 })
hi('VisualNOS', { bg = colors.gray3 })

-- Search
hi('Search', { fg = colors.black, bg = colors.yellow })
hi('IncSearch', { fg = colors.black, bg = colors.orange })
hi('CurSearch', { fg = colors.black, bg = colors.bright_yellow })

-- Matching
hi('MatchParen', { fg = colors.cyan, bg = colors.gray2, bold = true })

-- Splits
hi('VertSplit', { fg = colors.gray4, bg = colors.black })
hi('WinSeparator', { fg = colors.gray4, bg = colors.black })

-- Status line
hi('StatusLine', { fg = colors.white, bg = colors.gray2 })
hi('StatusLineNC', { fg = colors.gray7, bg = colors.gray1 })

-- Tab line
hi('TabLine', { fg = colors.gray8, bg = colors.gray1 })
hi('TabLineFill', { fg = colors.gray6, bg = colors.gray1 })
hi('TabLineSel', { fg = colors.white, bg = colors.gray3, bold = true })

-- Popup menu
hi('Pmenu', { fg = colors.white, bg = colors.gray2 })
hi('PmenuSel', { fg = colors.black, bg = colors.yellow })
hi('PmenuSbar', { bg = colors.gray3 })
hi('PmenuThumb', { bg = colors.gray5 })

-- Folding
hi('Folded', { fg = colors.gray7, bg = colors.gray1 })
hi('FoldColumn', { fg = colors.gray6, bg = colors.black })

-- Diff
hi('DiffAdd', { fg = colors.green, bg = colors.black })
hi('DiffChange', { fg = colors.yellow, bg = colors.black })
hi('DiffDelete', { fg = colors.red, bg = colors.black })
hi('DiffText', { fg = colors.blue, bg = colors.black, bold = true })

-- Spelling
hi('SpellBad', { fg = colors.red, undercurl = true })
hi('SpellCap', { fg = colors.yellow, undercurl = true })
hi('SpellLocal', { fg = colors.cyan, undercurl = true })
hi('SpellRare', { fg = colors.magenta, undercurl = true })

-- Messages
hi('ErrorMsg', { fg = colors.red, bold = true })
hi('WarningMsg', { fg = colors.yellow, bold = true })
hi('ModeMsg', { fg = colors.white, bold = true })
hi('MoreMsg', { fg = colors.green, bold = true })
hi('Question', { fg = colors.cyan, bold = true })

-- Syntax highlighting
hi('Comment', { fg = colors.gray7, italic = true })
hi('Constant', { fg = colors.cyan })
hi('String', { fg = colors.green })
hi('Character', { fg = colors.green })
hi('Number', { fg = colors.orange })
hi('Boolean', { fg = colors.red })
hi('Float', { fg = colors.orange })

hi('Identifier', { fg = colors.white })
hi('Function', { fg = colors.magenta })

hi('Statement', { fg = colors.blue })
hi('Conditional', { fg = colors.blue })
hi('Repeat', { fg = colors.blue })
hi('Label', { fg = colors.blue })
hi('Operator', { fg = colors.orange })
hi('Keyword', { fg = colors.blue })
hi('Exception', { fg = colors.red })

hi('PreProc', { fg = colors.cyan })
hi('Include', { fg = colors.cyan })
hi('Define', { fg = colors.cyan })
hi('Macro', { fg = colors.cyan })
hi('PreCondit', { fg = colors.cyan })

hi('Type', { fg = colors.yellow })
hi('StorageClass', { fg = colors.yellow })
hi('Structure', { fg = colors.yellow })
hi('Typedef', { fg = colors.yellow })

hi('Special', { fg = colors.orange })
hi('SpecialChar', { fg = colors.orange })
hi('Tag', { fg = colors.magenta })
hi('Delimiter', { fg = colors.gray9 })
hi('SpecialComment', { fg = colors.cyan, italic = true })
hi('Debug', { fg = colors.red })

hi('Underlined', { fg = colors.blue, underline = true })
hi('Ignore', { fg = colors.gray5 })
hi('Error', { fg = colors.red, bg = colors.black, bold = true })
hi('Todo', { fg = colors.black, bg = colors.yellow, bold = true })

-- LSP highlights
hi('DiagnosticError', { fg = colors.error })
hi('DiagnosticWarn', { fg = colors.warning })
hi('DiagnosticInfo', { fg = colors.info })
hi('DiagnosticHint', { fg = colors.hint })

hi('DiagnosticUnderlineError', { undercurl = true, sp = colors.error })
hi('DiagnosticUnderlineWarn', { undercurl = true, sp = colors.warning })
hi('DiagnosticUnderlineInfo', { undercurl = true, sp = colors.info })
hi('DiagnosticUnderlineHint', { undercurl = true, sp = colors.hint })

hi('LspDiagnosticsError', { link = "DiagnosticError" })
hi('LspDiagnosticsWarning', { link = "DiagnosticWarn" })
hi('LspDiagnosticsInfo', { link = "DiagnosticInfo" })
hi('LspDiagnosticsHint', { link = "DiagnosticHint" })

hi('LspDiagnosticsUnderlineError', { link = "DiagnosticUnderlineError" })
hi('LspDiagnosticsUnderlineWarning', { link = "DiagnosticUnderlineWarn" })
hi('LspDiagnosticsUnderlineInfo', { link = "DiagnosticUnderlineInfo" })
hi('LspDiagnosticsUnderlineHint', { link = "DiagnosticUnderlineHint" })

-- LSP Semantic Token Groups
hi('LspReferenceText', { bg = colors.gray2 })
hi('LspReferenceRead', { bg = colors.gray2 })
hi('LspReferenceWrite', { bg = colors.gray3 })

-- LSP Signature Help
hi('LspSignatureActiveParameter', { fg = colors.orange, bold = true })

-- LSP Code Lens
hi('LspCodeLens', { fg = colors.gray6, italic = true })
hi('LspCodeLensSeparator', { fg = colors.gray5 })

-- LSP Semantic Tokens
hi('@lsp.type.class', { fg = colors.yellow })
hi('@lsp.type.comment', { fg = colors.gray7, italic = true })
hi('@lsp.type.decorator', { fg = colors.cyan })
hi('@lsp.type.enum', { fg = colors.yellow })
hi('@lsp.type.enumMember', { fg = colors.cyan })
hi('@lsp.type.field', { fg = colors.white })
hi('@lsp.type.function', { fg = colors.magenta })
hi('@lsp.type.interface', { fg = colors.yellow })
hi('@lsp.type.keyword', { fg = colors.blue })
hi('@lsp.type.macro', { fg = colors.cyan })
hi('@lsp.type.method', { fg = colors.magenta })
hi('@lsp.type.module', { fg = colors.yellow })
hi('@lsp.type.namespace', { fg = colors.yellow })
hi('@lsp.type.number', { fg = colors.orange })
hi('@lsp.type.operator', { fg = colors.orange })
hi('@lsp.type.parameter', { fg = colors.white })
hi('@lsp.type.property', { fg = colors.white })
hi('@lsp.type.regexp', { fg = colors.orange })
hi('@lsp.type.string', { fg = colors.green })
hi('@lsp.type.struct', { fg = colors.yellow })
hi('@lsp.type.type', { fg = colors.yellow })
hi('@lsp.type.typeParameter', { fg = colors.yellow })
hi('@lsp.type.variable', { fg = colors.white })
hi('@lsp.typemod.parameter.declaration', { fg = colors.white, bold = true })
hi('@lsp.typemod.variable.static', { fg = colors.white, italic = true })

-- LSP Semantic Token Modifiers
hi('@lsp.mod.declaration', { bold = true })
hi('@lsp.mod.definition', { bold = true })
hi('@lsp.mod.readonly', { italic = true })
hi('@lsp.mod.static', { italic = true })
hi('@lsp.mod.deprecated', { fg = colors.gray6, strikethrough = true })
hi('@lsp.mod.abstract', { italic = true })
hi('@lsp.mod.async', { italic = true })
hi('@lsp.mod.modification', { underline = true })
hi('@lsp.mod.documentation', { italic = true })
hi('@lsp.mod.defaultLibrary', { bold = true })

-- C# specific LSP semantic tokens
hi('@lsp.type.annotation.cs', { fg = colors.cyan })
hi('@lsp.type.class.cs', { fg = colors.yellow })
hi('@lsp.type.constant.cs', { fg = colors.cyan })
hi('@lsp.type.controlKeyword.cs', { fg = colors.blue })
hi('@lsp.type.delegate.cs', { fg = colors.yellow })
hi('@lsp.type.enum.cs', { fg = colors.yellow })
hi('@lsp.type.enumMember.cs', { fg = colors.cyan })
hi('@lsp.type.event.cs', { fg = colors.magenta })
hi('@lsp.type.field.cs', { fg = colors.white })
hi('@lsp.type.interface.cs', { fg = colors.yellow, italic = true })
hi('@lsp.type.keyword.cs', { fg = colors.blue })
hi('@lsp.type.label.cs', { fg = colors.blue })
hi('@lsp.type.local.cs', { fg = colors.white })
hi('@lsp.type.method.cs', { fg = colors.magenta })
hi('@lsp.type.namespace.cs', { fg = colors.yellow })
hi('@lsp.type.number.cs', { fg = colors.orange })
hi('@lsp.type.operator.cs', { fg = colors.orange })
hi('@lsp.type.parameter.cs', { fg = colors.white })
hi('@lsp.type.property.cs', { fg = colors.white })
hi('@lsp.type.string.cs', { fg = colors.green })
hi('@lsp.type.struct.cs', { fg = colors.yellow })
hi('@lsp.type.typeAlias.cs', { fg = colors.yellow })
hi('@lsp.type.typeParameter.cs', { fg = colors.yellow })
hi('@lsp.type.variable.cs', { fg = colors.white })

-- C# modifiers
hi('@lsp.mod.static.cs', { italic = true })
hi('@lsp.mod.readonly.cs', { italic = true })
hi('@lsp.mod.sealed.cs', { italic = true })
hi('@lsp.mod.abstract.cs', { italic = true })
hi('@lsp.mod.virtual.cs', { italic = true })
hi('@lsp.mod.override.cs', { italic = true })
hi('@lsp.mod.async.cs', { italic = true })
hi('@lsp.mod.extern.cs', { italic = true })
hi('@lsp.mod.unsafe.cs', { fg = colors.red, italic = true })

-- C# type combinations with modifiers
hi('@lsp.typemod.class.abstract.cs', { fg = colors.yellow, italic = true })
hi('@lsp.typemod.class.sealed.cs', { fg = colors.yellow, italic = true })
hi('@lsp.typemod.class.static.cs', { fg = colors.yellow, italic = true })
hi('@lsp.typemod.field.readonly.cs', { fg = colors.cyan, italic = true })
hi('@lsp.typemod.field.static.cs', { fg = colors.white, italic = true })
hi('@lsp.typemod.method.abstract.cs', { fg = colors.magenta, italic = true })
hi('@lsp.typemod.method.async.cs', { fg = colors.magenta, italic = true })
hi('@lsp.typemod.method.override.cs', { fg = colors.magenta, italic = true })
hi('@lsp.typemod.method.static.cs', { fg = colors.magenta, italic = true })
hi('@lsp.typemod.method.virtual.cs', { fg = colors.magenta, italic = true })
hi('@lsp.typemod.parameter.defaultLibrary.cs', { fg = colors.white, bold = true })
hi('@lsp.typemod.property.readonly.cs', { fg = colors.white, italic = true })
hi('@lsp.typemod.property.static.cs', { fg = colors.white, italic = true })
hi('@lsp.typemod.variable.readonly.cs', { fg = colors.white, italic = true })

-- Ruby LSP Semantic Tokens
hi('@lsp.type.class.ruby', { fg = colors.yellow })
hi('@lsp.type.constant.ruby', { fg = colors.cyan })
hi('@lsp.type.enum.ruby', { fg = colors.yellow })
hi('@lsp.type.enumMember.ruby', { fg = colors.cyan })
hi('@lsp.type.function.ruby', { fg = colors.magenta })
hi('@lsp.type.method.ruby', { fg = colors.magenta })
hi('@lsp.type.module.ruby', { fg = colors.yellow })
hi('@lsp.type.namespace.ruby', { fg = colors.yellow })
hi('@lsp.type.parameter.ruby', { fg = colors.white })
hi('@lsp.type.property.ruby', { fg = colors.white })
hi('@lsp.type.string.ruby', { fg = colors.green })
hi('@lsp.type.variable.ruby', { fg = colors.white })
hi('@lsp.type.number.ruby', { fg = colors.orange })
hi('@lsp.type.keyword.ruby', { fg = colors.blue })
hi('@lsp.type.operator.ruby', { fg = colors.orange })
hi('@lsp.type.boolean.ruby', { fg = colors.red })
hi('@lsp.type.type.ruby', { fg = colors.yellow })
hi('@lsp.mod.deprecated.ruby', { fg = colors.gray6, strikethrough = true })
hi('@lsp.mod.readonly.ruby', { italic = true })
hi('@lsp.mod.static.ruby', { italic = true })

-- Generic LSP semantic tokens (fallback for other languages)
hi('@lsp.type.boolean', { fg = colors.red })
hi('@lsp.type.builtinType', { fg = colors.yellow, bold = true })
hi('@lsp.type.comment', { fg = colors.gray7, italic = true })
hi('@lsp.type.generic', { fg = colors.yellow })
hi('@lsp.type.lifetime', { fg = colors.orange })
hi('@lsp.type.selfKeyword', { fg = colors.red })
hi('@lsp.type.selfTypeKeyword', { fg = colors.red })
hi('@lsp.type.unresolvedReference', { fg = colors.red, undercurl = true })

-- Treesitter highlights
hi('@annotation', { fg = colors.yellow })
hi('@attribute.builtin', { fg = colors.cyan, italic = true })
hi('@attribute', { fg = colors.cyan })
hi('@boolean', { fg = colors.red })
hi('@character.special', { fg = colors.orange })
hi('@character', { fg = colors.green })
hi('@comment.documentation', { fg = colors.gray8, italic = true })
hi('@comment', { fg = colors.gray7, italic = true })
hi('@conditional', { fg = colors.blue })
hi('@constant.builtin', { fg = colors.cyan, bold = true })
hi('@constant.macro', { fg = colors.cyan })
hi('@constant', { fg = colors.cyan })
hi('@constructor.call', { fg = colors.yellow })
hi('@constructor', { fg = colors.yellow })
hi('@debug', { fg = colors.red })
hi('@define', { fg = colors.cyan })
hi('@error', { fg = colors.red })
hi('@exception', { fg = colors.red })
hi('@field', { fg = colors.white })
hi('@float', { fg = colors.orange })
hi('@function.builtin', { fg = colors.magenta, bold = true })
hi('@function.call', { fg = colors.magenta })
hi('@function.macro', { fg = colors.cyan })
hi('@function.method.call', { fg = colors.magenta })
hi('@function', { fg = colors.magenta })
hi('@include', { fg = colors.cyan })
hi('@keyword.function', { fg = colors.blue })
hi('@keyword.operator', { fg = colors.blue })
hi('@keyword.return', { fg = colors.blue })
hi('@keyword', { fg = colors.blue })
hi('@label', { fg = colors.blue })
hi('@markup.italic', { fg = colors.white, italic = true })
hi('@markup.link', { fg = colors.cyan, underline = true })
hi('@markup.strong', { fg = colors.white, bold = true })
hi('@method.call', { fg = colors.magenta })
hi('@method', { fg = colors.magenta })
hi('@module', { fg = colors.yellow })
hi('@namespace', { fg = colors.yellow })
hi('@none', { fg = colors.white })
hi('@number', { fg = colors.orange })
hi('@operator', { fg = colors.orange })
hi('@parameter.reference', { fg = colors.white })
hi('@parameter', { fg = colors.white })
hi('@property', { fg = colors.white })
hi('@punctuation.bracket', { fg = colors.gray9 })
hi('@punctuation.delimiter', { fg = colors.gray9 })
hi('@punctuation.special', { fg = colors.orange })
hi('@repeat', { fg = colors.blue })
hi('@string.documentation', { fg = colors.green, italic = true })
hi('@string.escape', { fg = colors.orange })
hi('@string.special', { fg = colors.orange })
hi('@string', { fg = colors.green })
hi('@symbol', { fg = colors.cyan })
hi('@tag.attribute', { fg = colors.yellow })
hi('@tag.delimiter', { fg = colors.gray9 })
hi('@tag', { fg = colors.magenta })
hi('@text.danger', { fg = colors.black, bg = colors.error, bold = true })
hi('@text.emphasis', { fg = colors.white, italic = true })
hi('@text.environment.name', { fg = colors.yellow })
hi('@text.environment', { fg = colors.cyan })
hi('@text.literal', { fg = colors.green })
hi('@text.math', { fg = colors.orange })
hi('@text.note', { fg = colors.black, bg = colors.info, bold = true })
hi('@text.reference', { fg = colors.cyan })
hi('@text.strike', { fg = colors.white, strikethrough = true })
hi('@text.strong', { fg = colors.white, bold = true })
hi('@text.title', { fg = colors.blue, bold = true })
hi('@text.todo', { fg = colors.black, bg = colors.yellow, bold = true })
hi('@text.underline', { fg = colors.white, underline = true })
hi('@text.uri', { fg = colors.cyan, underline = true })
hi('@text.warning', { fg = colors.black, bg = colors.warning, bold = true })
hi('@text', { fg = colors.white })
hi('@type.builtin', { fg = colors.yellow, bold = true })
hi('@type.definition', { fg = colors.yellow })
hi('@type.qualifier', { fg = colors.blue })
hi('@type', { fg = colors.yellow })
hi('@variable.builtin', { fg = colors.red })
hi('@variable.parameter', { fg = colors.white })
hi('@variable', { fg = colors.white })

-- Language-specific Treesitter highlights
-- HTML
hi('@attribute.html', { fg = colors.yellow })
hi('@comment.html', { fg = colors.gray7, italic = true })
hi('@constant.html', { fg = colors.cyan })
hi('@keyword.html', { fg = colors.blue })
hi('@namespace.html', { fg = colors.yellow })
hi('@punctuation.bracket.html', { fg = colors.gray9 })
hi('@punctuation.delimiter.html', { fg = colors.gray9 })
hi('@string.html', { fg = colors.green })
hi('@tag.attribute.html', { fg = colors.yellow })
hi('@tag.builtin.html', { fg = colors.blue, bold = true })
hi('@tag.delimiter.html', { fg = colors.gray9 })
hi('@tag.html', { fg = colors.blue })
hi('@text.html', { fg = colors.white })

-- HTML entities and special characters
hi('@character.special.html', { fg = colors.orange })
hi('@string.special.html', { fg = colors.orange })

-- HTML doctype
hi('@preproc.html', { fg = colors.cyan })
hi('@keyword.directive.html', { fg = colors.cyan })

-- CSS
hi('@property.css', { fg = colors.cyan })
hi('@string.css', { fg = colors.green })
hi('@number.css', { fg = colors.orange })
hi('@tag.css', { fg = colors.blue })
hi('@type.css', { fg = colors.yellow })
hi('@attribute.css', { fg = colors.yellow })
hi('@function.css', { fg = colors.magenta })
hi('@keyword.css', { fg = colors.blue })
hi('@operator.css', { fg = colors.orange })
hi('@punctuation.bracket.css', { fg = colors.gray9 })
hi('@punctuation.delimiter.css', { fg = colors.gray9 })
hi('@comment.css', { fg = colors.gray7, italic = true })
hi('@constant.css', { fg = colors.cyan })
hi('@variable.css', { fg = colors.white })
hi('@namespace.css', { fg = colors.yellow })
hi('@string.special.css', { fg = colors.orange })
hi('@character.special.css', { fg = colors.orange })

-- SCSS/SASS
hi('@property.scss', { fg = colors.cyan })
hi('@string.scss', { fg = colors.green })
hi('@number.scss', { fg = colors.orange })
hi('@tag.scss', { fg = colors.blue })
hi('@type.scss', { fg = colors.yellow })
hi('@attribute.scss', { fg = colors.yellow })
hi('@function.scss', { fg = colors.magenta })
hi('@keyword.scss', { fg = colors.blue })
hi('@operator.scss', { fg = colors.orange })
hi('@punctuation.bracket.scss', { fg = colors.gray9 })
hi('@punctuation.delimiter.scss', { fg = colors.gray9 })
hi('@comment.scss', { fg = colors.gray7, italic = true })
hi('@constant.scss', { fg = colors.cyan })
hi('@variable.scss', { fg = colors.white })
hi('@namespace.scss', { fg = colors.yellow })
hi('@string.special.scss', { fg = colors.orange })
hi('@character.special.scss', { fg = colors.orange })

-- JavaScript/TypeScript
hi('@variable.javascript', { fg = colors.white })
hi('@variable.typescript', { fg = colors.white })
hi('@property.javascript', { fg = colors.white })
hi('@property.typescript', { fg = colors.white })
hi('@function.javascript', { fg = colors.magenta })
hi('@function.typescript', { fg = colors.magenta })
hi('@function.builtin.javascript', { fg = colors.magenta, bold = true })
hi('@function.builtin.typescript', { fg = colors.magenta, bold = true })
hi('@method.javascript', { fg = colors.magenta })
hi('@method.typescript', { fg = colors.magenta })
hi('@method.call.javascript', { fg = colors.magenta })
hi('@method.call.typescript', { fg = colors.magenta })
hi('@constructor.javascript', { fg = colors.yellow })
hi('@constructor.typescript', { fg = colors.yellow })
hi('@keyword.javascript', { fg = colors.blue })
hi('@keyword.typescript', { fg = colors.blue })
hi('@keyword.function.javascript', { fg = colors.blue })
hi('@keyword.function.typescript', { fg = colors.blue })
hi('@keyword.operator.javascript', { fg = colors.blue })
hi('@keyword.operator.typescript', { fg = colors.blue })
hi('@keyword.return.javascript', { fg = colors.blue })
hi('@keyword.return.typescript', { fg = colors.blue })
hi('@conditional.javascript', { fg = colors.blue })
hi('@conditional.typescript', { fg = colors.blue })
hi('@repeat.javascript', { fg = colors.blue })
hi('@repeat.typescript', { fg = colors.blue })
hi('@exception.javascript', { fg = colors.red })
hi('@exception.typescript', { fg = colors.red })
hi('@operator.javascript', { fg = colors.orange })
hi('@operator.typescript', { fg = colors.orange })
hi('@string.javascript', { fg = colors.green })
hi('@string.typescript', { fg = colors.green })
hi('@string.template.javascript', { fg = colors.green })
hi('@string.template.typescript', { fg = colors.green })
hi('@string.regex.javascript', { fg = colors.orange })
hi('@string.regex.typescript', { fg = colors.orange })
hi('@number.javascript', { fg = colors.orange })
hi('@number.typescript', { fg = colors.orange })
hi('@boolean.javascript', { fg = colors.red })
hi('@boolean.typescript', { fg = colors.red })
hi('@constant.javascript', { fg = colors.cyan })
hi('@constant.typescript', { fg = colors.cyan })
hi('@constant.builtin.javascript', { fg = colors.cyan, bold = true })
hi('@constant.builtin.typescript', { fg = colors.cyan, bold = true })
hi('@type.javascript', { fg = colors.yellow })
hi('@type.typescript', { fg = colors.yellow })
hi('@type.builtin.javascript', { fg = colors.yellow, bold = true })
hi('@type.builtin.typescript', { fg = colors.yellow, bold = true })
hi('@parameter.javascript', { fg = colors.white })
hi('@parameter.typescript', { fg = colors.white })
hi('@field.javascript', { fg = colors.white })
hi('@field.typescript', { fg = colors.white })
hi('@namespace.javascript', { fg = colors.yellow })
hi('@namespace.typescript', { fg = colors.yellow })
hi('@module.javascript', { fg = colors.yellow })
hi('@module.typescript', { fg = colors.yellow })
hi('@label.javascript', { fg = colors.blue })
hi('@label.typescript', { fg = colors.blue })
hi('@punctuation.bracket.javascript', { fg = colors.gray9 })
hi('@punctuation.bracket.typescript', { fg = colors.gray9 })
hi('@punctuation.delimiter.javascript', { fg = colors.gray9 })
hi('@punctuation.delimiter.typescript', { fg = colors.gray9 })
hi('@punctuation.special.javascript', { fg = colors.orange })
hi('@punctuation.special.typescript', { fg = colors.orange })
hi('@comment.javascript', { fg = colors.gray7, italic = true })
hi('@comment.typescript', { fg = colors.gray7, italic = true })
hi('@comment.documentation.javascript', { fg = colors.gray8, italic = true })
hi('@comment.documentation.typescript', { fg = colors.gray8, italic = true })
hi('@tag.javascript', { fg = colors.magenta })
hi('@tag.typescript', { fg = colors.magenta })
hi('@tag.attribute.javascript', { fg = colors.yellow })
hi('@tag.attribute.typescript', { fg = colors.yellow })
hi('@tag.delimiter.javascript', { fg = colors.gray9 })
hi('@tag.delimiter.typescript', { fg = colors.gray9 })
hi('@variable.builtin.javascript', { fg = colors.red })
hi('@variable.builtin.typescript', { fg = colors.red })
hi('@variable.parameter.javascript', { fg = colors.white })
hi('@variable.parameter.typescript', { fg = colors.white })

-- JSX/TSX specific
hi('@tag.jsx', { fg = colors.magenta })
hi('@tag.tsx', { fg = colors.magenta })
hi('@tag.builtin.jsx', { fg = colors.blue, bold = true })
hi('@tag.builtin.tsx', { fg = colors.blue, bold = true })
hi('@tag.attribute.jsx', { fg = colors.yellow })
hi('@tag.attribute.tsx', { fg = colors.yellow })
hi('@tag.delimiter.jsx', { fg = colors.gray9 })
hi('@tag.delimiter.tsx', { fg = colors.gray9 })
hi('@constructor.jsx', { fg = colors.yellow })
hi('@constructor.tsx', { fg = colors.yellow })

-- JSON
hi('@property.json', { fg = colors.cyan })
hi('@string.json', { fg = colors.green })
hi('@number.json', { fg = colors.orange })
hi('@boolean.json', { fg = colors.red })
hi('@constant.json', { fg = colors.cyan })
hi('@punctuation.bracket.json', { fg = colors.gray9 })
hi('@punctuation.delimiter.json', { fg = colors.gray9 })
hi('@comment.json', { fg = colors.gray7, italic = true })

-- Python
hi('@variable.python', { fg = colors.white })
hi('@function.builtin.python', { fg = colors.magenta, bold = true })

-- Ruby Treesitter Highlights
hi('@class.ruby', { fg = colors.yellow })
hi('@constant.ruby', { fg = colors.cyan })
hi('@constructor.ruby', { fg = colors.yellow })
hi('@function.ruby', { fg = colors.magenta })
hi('@function.builtin.ruby', { fg = colors.magenta, bold = true })
hi('@function.call.ruby', { fg = colors.magenta })
hi('@keyword.ruby', { fg = colors.blue })
hi('@keyword.function.ruby', { fg = colors.blue })
hi('@keyword.operator.ruby', { fg = colors.blue })
hi('@method.ruby', { fg = colors.magenta })
hi('@method.call.ruby', { fg = colors.magenta })
hi('@module.ruby', { fg = colors.yellow })
hi('@namespace.ruby', { fg = colors.yellow })
hi('@number.ruby', { fg = colors.orange })
hi('@operator.ruby', { fg = colors.orange })
hi('@parameter.ruby', { fg = colors.white })
hi('@property.ruby', { fg = colors.white })
hi('@string.ruby', { fg = colors.green })
hi('@string.special.ruby', { fg = colors.orange })
hi('@symbol.ruby', { fg = colors.cyan })
hi('@type.ruby', { fg = colors.yellow })
hi('@variable.ruby', { fg = colors.white })
hi('@variable.builtin.ruby', { fg = colors.red })
hi('@comment.ruby', { fg = colors.gray7, italic = true })
hi('@punctuation.delimiter.ruby', { fg = colors.gray9 })
hi('@punctuation.bracket.ruby', { fg = colors.gray9 })

-- Rust
hi('@type.rust', { fg = colors.yellow })
hi('@attribute.rust', { fg = colors.cyan })
hi('@variable.rust', { fg = colors.white })

-- Go
hi('@type.go', { fg = colors.yellow })
hi('@variable.go', { fg = colors.white })

-- C/C++
hi('@type.c', { fg = colors.yellow })
hi('@type.cpp', { fg = colors.yellow })
hi('@variable.c', { fg = colors.white })
hi('@variable.cpp', { fg = colors.white })

-- C#
hi('@type.c_sharp', { fg = colors.yellow })
hi('@type.cs', { fg = colors.yellow })
hi('@variable.c_sharp', { fg = colors.white })
hi('@variable.cs', { fg = colors.white })
hi('@property.c_sharp', { fg = colors.white })
hi('@property.cs', { fg = colors.white })
hi('@field.c_sharp', { fg = colors.white })
hi('@field.cs', { fg = colors.white })
hi('@method.c_sharp', { fg = colors.magenta })
hi('@method.cs', { fg = colors.magenta })
hi('@namespace.c_sharp', { fg = colors.yellow })
hi('@namespace.cs', { fg = colors.yellow })
hi('@attribute.c_sharp', { fg = colors.cyan })
hi('@attribute.cs', { fg = colors.cyan })
hi('@keyword.c_sharp', { fg = colors.blue })
hi('@keyword.cs', { fg = colors.blue })
hi('@keyword.modifier.c_sharp', { fg = colors.blue })
hi('@keyword.modifier.cs', { fg = colors.blue })
hi('@keyword.type.c_sharp', { fg = colors.blue })
hi('@keyword.type.cs', { fg = colors.blue })
hi('@keyword.operator.c_sharp', { fg = colors.blue })
hi('@keyword.operator.cs', { fg = colors.blue })
hi('@string.c_sharp', { fg = colors.green })
hi('@string.cs', { fg = colors.green })
hi('@string.interpolated.c_sharp', { fg = colors.green })
hi('@string.interpolated.cs', { fg = colors.green })
hi('@string.verbatim.c_sharp', { fg = colors.green })
hi('@string.verbatim.cs', { fg = colors.green })
hi('@number.c_sharp', { fg = colors.orange })
hi('@number.cs', { fg = colors.orange })
hi('@boolean.c_sharp', { fg = colors.red })
hi('@boolean.cs', { fg = colors.red })
hi('@constant.c_sharp', { fg = colors.cyan })
hi('@constant.cs', { fg = colors.cyan })
hi('@constant.builtin.c_sharp', { fg = colors.cyan, bold = true })
hi('@constant.builtin.cs', { fg = colors.cyan, bold = true })
hi('@operator.c_sharp', { fg = colors.orange })
hi('@operator.cs', { fg = colors.orange })
hi('@punctuation.bracket.c_sharp', { fg = colors.gray9 })
hi('@punctuation.bracket.cs', { fg = colors.gray9 })
hi('@punctuation.delimiter.c_sharp', { fg = colors.gray9 })
hi('@punctuation.delimiter.cs', { fg = colors.gray9 })
hi('@comment.c_sharp', { fg = colors.gray7, italic = true })
hi('@comment.cs', { fg = colors.gray7, italic = true })
hi('@comment.documentation.c_sharp', { fg = colors.gray8, italic = true })
hi('@comment.documentation.cs', { fg = colors.gray8, italic = true })

-- C# specific language constructs
hi('@conditional.c_sharp', { fg = colors.blue })
hi('@conditional.cs', { fg = colors.blue })
hi('@constructor.c_sharp', { fg = colors.yellow })
hi('@constructor.cs', { fg = colors.yellow })
hi('@exception.c_sharp', { fg = colors.red })
hi('@exception.cs', { fg = colors.red })
hi('@function.builtin.c_sharp', { fg = colors.magenta, bold = true })
hi('@function.builtin.cs', { fg = colors.magenta, bold = true })
hi('@function.c_sharp', { fg = colors.magenta })
hi('@function.cs', { fg = colors.magenta })
hi('@include.c_sharp', { fg = colors.cyan })
hi('@include.cs', { fg = colors.cyan })
hi('@label.c_sharp', { fg = colors.blue })
hi('@label.cs', { fg = colors.blue })
hi('@parameter.c_sharp', { fg = colors.white })
hi('@parameter.cs', { fg = colors.white })
hi('@repeat.c_sharp', { fg = colors.blue })
hi('@repeat.cs', { fg = colors.blue })
hi('@storageclass.c_sharp', { fg = colors.blue })
hi('@storageclass.cs', { fg = colors.blue })
hi('@variable.member.cs', { fg = colors.white })

-- Add CodeCompanion highlight groups
hi('CodeCompanionChatInfo', { fg = colors.info })
hi('CodeCompanionChatError', { fg = colors.error })
hi('CodeCompanionChatWarn', { fg = colors.warning })
hi('CodeCompanionChatSubtext', { fg = colors.gray7 })
hi('CodeCompanionChatHeader', { fg = colors.white, bold = true })
hi('CodeCompanionChatSeparator', { fg = colors.gray5 })
hi('CodeCompanionChatTokens', { fg = colors.cyan, italic = true })
hi('CodeCompanionChatTool', { fg = colors.magenta })
hi('CodeCompanionChatToolGroups', { fg = colors.yellow })
hi('CodeCompanionChatVariable', { fg = colors.white })
hi('CodeCompanionVirtualText', { fg = colors.gray8 })

-- Markview highlight groups
hi('MarkviewPalette0', { fg = colors.white, bg = colors.gray2 })
hi('MarkviewPalette0Fg', { fg = colors.white })
hi('MarkviewPalette0Bg', { bg = colors.gray2 })
hi('MarkviewPalette0Sign', { fg = colors.white, bg = colors.gray2 })

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

hi('MarkviewCode', { fg = colors.white, bg = colors.black })
hi('MarkviewCodeInfo', { fg = colors.gray7, bg = colors.black })
hi('MarkviewCodeFg', { fg = colors.white })
hi('MarkviewInlineCode', { fg = colors.green, bg = colors.black })

-- Git signs
hi('GitSignsAdd', { fg = colors.green })
hi('GitSignsChange', { fg = colors.yellow })
hi('GitSignsDelete', { fg = colors.red })

-- Telescope (if installed)
hi('TelescopeNormal', { fg = colors.white, bg = colors.black })
hi('TelescopeBorder', { fg = colors.gray4, bg = colors.black })
hi('TelescopePromptBorder', { fg = colors.gray4, bg = colors.black })
hi('TelescopeResultsBorder', { fg = colors.gray4, bg = colors.black })
hi('TelescopePreviewBorder', { fg = colors.gray4, bg = colors.black })
hi('TelescopeSelection', { fg = colors.white, bg = colors.gray2 })
hi('TelescopeSelectionCaret', { fg = colors.orange, bg = colors.gray2 })

-- NvimTree (if installed)
hi('NvimTreeNormal', { fg = colors.white, bg = colors.black })
hi('NvimTreeFolderName', { fg = colors.blue })
hi('NvimTreeFolderIcon', { fg = colors.blue })
hi('NvimTreeOpenedFolderName', { fg = colors.blue, bold = true })
hi('NvimTreeEmptyFolderName', { fg = colors.gray7 })
hi('NvimTreeIndentMarker', { fg = colors.gray4 })
hi('NvimTreeSpecialFile', { fg = colors.yellow })
hi('NvimTreeExecFile', { fg = colors.green })

-- Which-key (if installed)
hi('WhichKey', { fg = colors.cyan })
hi('WhichKeyGroup', { fg = colors.blue })
hi('WhichKeyDesc', { fg = colors.white })
hi('WhichKeySeperator', { fg = colors.gray6 })
hi('WhichKeyFloat', { bg = colors.gray1 })
hi('WhichKeyBorder', { fg = colors.gray4 })

return M
