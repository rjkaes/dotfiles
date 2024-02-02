" set up tabs and line widths for perl programming
setlocal matchpairs+=<:>             " allow % to bounce bettern angles too

" load modules
setlocal isfname+=:

" check Perl code with :make
setlocal makeprg=perl\ -c\ %\ $*
setlocal errorformat=%f:%l:%m
setlocal equalprg=perltidy\ -q

" Insert the function header comment block
nnoremap <buffer> <silent> #f :r~/.code_templates/perl/sub_header.pl<CR>

" Lookup information under the cursor
nnoremap <buffer> <silent> K :!perldoc <cword> <bar><bar> perldoc -f <cword><cr>

" Perl tidy
nnoremap <buffer> <silent> _t :%!perltidy -q<CR>
vnoremap <buffer> <silent> _t :!perltidy -q<CR>
