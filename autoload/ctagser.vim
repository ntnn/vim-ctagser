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

function ctagser#job_stdout_handler(channel, msg)
    echom "tagscreate:" a:msg
endfunction

function ctagser#job_stderr_handler(channel, msg)
    echohl Error | echom "tagscreate:" a:msg | echohl None
endfunction

function ctagser#job_exit_handler(channel, status)
    echom "tagscreate finished with status" a:status
endfunction

function ctagser#index_system()
    let exe = s:bindir . 'tagscreate'

    for params in g:ctagser_params
        echom "Creating tags for" split(params)[0]

        if exists('*job_start')
            let job = job_start([exe] + split(params),
                        \   {
                        \     "out_cb": "ctagser#job_stdout_handler",
                        \     "err_cb": "ctagser#job_stderr_handler",
                        \     "exit_cb": "ctagser#job_exit_handler",
                        \   }
                        \ )
        else
            call system(exe . params)
        endif

    endfor
endfunction

" Returns the filename with a prefix '+ ' or '- ', depending on if the
" file is readable.
function s:test_tags_file(file)
    return (filereadable(a:file) ? '+' : '-')
                \ . ' '
                \ . a:file
endfunction

" Lists contents of &tags with information about globs and availability.
"
" Example:
"   set tags=~/project/dir/**/tags,./tags,~/tags,/usr/example/*/tags
"
" results in this output:
"
"   + /home/user/project/dir/**/tags:
"     + /home/user/project/dir/src/tags
"     + /home/user/project/dir/tests/tags
"   - ./tags
"   + /home/user/tags
"   - /usr/example/*/tags
"
" If `./tags` does not exist and `/usr/example/*/tags` globs to an empty
" list.
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
