let s:bindir = expand('<sfile>:p:h:h') . '/bin/'

" Returns a list with the output of list-system-headers, which takes one
" argument and searches all local included headers ("*.h") for more
" locally included headers and included system headers
function ctagser#list_headers(file)
    return systemlist(
                \ join([
                \       s:bindir . '/list-system-headers',
                \       a:file,
                \       '2>/dev/null'
                \      ])
                \ )
endfunction

function ctagser#index_system()
    let exe = s:bindir . '/tagscreate'

    if exists('*job_start')
        call job_start(exe)
    elseif exists(':Make')
        " check for dispatch's :Make
        let makeprg_save = &l:makeprg
        let &l:makeprg = exe
        Make
        let &l:makeprg = makeprg_save
    else
        call system(exe)
    endif
endfunction

function s:test_tags_file(file)
    let output_entry = ''

    if filereadable(a:file)
        let output_entry .= '+ '
    else
        let output_entry .= '- '
    endif

    let output_entry .= a:file

    return output_entry
endfunction

function ctagser#list_tags()
    let tags = split(&tags, ',')
    let output = []

    " take entry in &tags
    for entry in l:tags
        if filereadable(entry)
            call add(output, s:test_tags_file(entry))
        else
            " file is not readable, maybe it is a pattern
            let entrylist = glob(entry, 1, 1)

            " the list is empty - either the pattern globbed empty or the
            " file does not exist
            if empty(entrylist)
                call add(output, '- ' . entry)
                continue
            endif

            call add(output, '+ ' . entry . ':')

            " work through the globbed list and check if the files are
            " readable
            for tag in entrylist
                call add(output, '  ' . s:test_tags_file(tag))
            endfor
        endif
    endfor

    for out in output
        echo out
    endfor
endfunction
