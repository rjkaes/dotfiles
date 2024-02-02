runtime! after/ftplugin/text.vim
setlocal textwidth=72

" Remove everything from the current line to just before the signature.
nmap <buffer> <silent> <leader>r :call <SID>RemoveReplyLines()<CR>

" Insert my signature
inoreabbr <buffer> rjk Thanks.<cr><space><space><space><space>--rjk<cr><esc>

function s:RemoveReplyLines()
    .,/^--/-2d
    noh
endfunction
