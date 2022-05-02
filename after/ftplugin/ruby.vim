setlocal foldexpr=getline(v:lnum)=~'^\\s*#'
setlocal foldlevel=100 " Open all folds by default
setlocal foldmethod=expr
setlocal shiftwidth=2
setlocal spelllang=en_ca
setlocal tabstop=2
setlocal textwidth=80
setlocal colorcolumn=+1
setlocal formatoptions-=t formatoptions+=croql

" colourize the operators and space errors
let ruby_operators = 1
let ruby_space_errors = 1

" Spell check strings. :)
let ruby_spellcheck_strings = 1

" Use the "do" block style when indenting
let g:ruby_indent_block_style = 'do'

inoreabbr <buffer> fsl: frozen_string_literal: true<cr><esc>D
inoreabbr <buffer> cls class
inoreabbr <buffer> stp $stderr.puts

" Drop a mark and then jump to the end of the "require" block
nnoremap <buffer> <silent> <localleader>u mugg/^require<cr>)Orequire<space>

" Resort the "require" block
nnoremap <buffer> <silent> <localleader>s V(:'<,'>!sort<cr>

" Visually select a block
nmap <buffer> <silent> <localleader>a var
nmap <buffer> <silent> <localleader>i vir

function! FormatRubyWithRubocop(buffer) abort
    let l:executable = ale#Var(a:buffer, 'ruby_rubocop_executable')

    let command = ale#ruby#EscapeExecutable(l:executable, 'rubocop')
                \ . ' --fix-layout --stderr '
                \ . ale#Var(a:buffer, 'ruby_rubocop_options')
                \ . ' --stdin %s'
    return { 'command': command, }
endfunction

execute ale#fix#registry#Add('rubocop-format', 'FormatRubyWithRubocop', ['ruby'], 'rubocop layout fixes')
