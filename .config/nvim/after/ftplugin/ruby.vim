setlocal shiftwidth=2
setlocal spelllang=en_ca
setlocal tabstop=2
setlocal textwidth=80
setlocal formatoptions-=t formatoptions+=croql

" colourize the operators and space errors
let ruby_operators = 1
let ruby_space_errors = 1

" Spell check strings. :)
let ruby_spellcheck_strings = 1

" Use the "do" block style when indenting
let g:ruby_indent_block_style = 'do'

inoreabbr <buffer> agf aggregate_failures
inoreabbr <buffer> cls class
inoreabbr <buffer> fsl: frozen_string_literal: true<cr><esc>D
inoreabbr <buffer> rsd RSpec.describe
inoreabbr <buffer> stp $stderr.puts

inoreabbr <buffer> fba FactoryBot.attributes_for
inoreabbr <buffer> fbb FactoryBot.build
inoreabbr <buffer> fbc FactoryBot.create
inoreabbr <buffer> fbs FactoryBot.build_stubbed

" Drop a mark and then jump to the end of the "require" block
nnoremap <buffer> <silent> <localleader>u mugg/^require<cr>)Orequire<space>

" Resort the "require" block
nnoremap <buffer> <silent> <localleader>s V(:'<,'>!sort<cr>

" Visually select a block
nmap <buffer> <silent> <localleader>a var
nmap <buffer> <silent> <localleader>i vir
