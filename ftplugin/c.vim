" ctagser.vim - add header files
" Maintainer:	Nelo-T. Wallus <nelo@wallus.de>
" License:	MIT

function! s:tags()
    setl tags<

    for header in ctagser#list_headers(expand('%:p'))
        exec 'setl tags+='
                    \ . join([$TAGSDIR, 'c', header], '/')
                    \ . '.ctags'
    endfor
endfunction

call s:tags()
command! -buffer CtagsDetectHeaders call s:tags()
com! -buffer CtagsShowHeaders call ctagser#print_headers(expand('%'))
