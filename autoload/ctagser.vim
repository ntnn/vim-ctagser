" ctagser.vim - add header files
" Maintainer:	Nelo-T. Wallus <nelo@wallus.de>
" License:	MIT

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

function ctagser#print_headers(file)
    echo "The following system headers have been detected by ctagser:"
    for line in ctagser#list_headers(a:file)
        echo "  " . line
    endfor
endfunction


function ctagser#job_start_stdout_handler(channel, msg)
    echom "tagscreate:" a:msg
endfunction

function ctagser#job_start_stderr_handler(channel, msg)
    echohl Error | echom "tagscreate:" a:msg | echohl None
endfunction

function ctagser#job_start_exit_handler(channel, status)
    if a:status == 0
        echom "tagscreate: success"
    else
        echom "tagscreate: failed with code" a:status
    endif
endfunction

function ctagser#jobstart_stdout_handler(channel, msg, stream)
    if len(a:msg) == 1 && a:msg[0] == ''
        return
    endif
    echom "tagscreate:" join(a:msg, " ")
endfunction

function ctagser#jobstart_stderr_handler(channel, msg, stream)
    if len(a:msg) == 1 && a:msg[0] == ''
        return
    endif
    echohl Error | echom "tagscreate:" join(a:msg, " ") | echohl None
endfunction

function ctagser#jobstart_exit_handler(channel, status, stream)
    if a:status == 0
        echom "tagscreate: success"
    else
        echom "tagscreate: failed with code" a:status
    endif
endfunction

function ctagser#index_system()
    let l:exe = s:bindir . 'tagscreate'

    for params in g:ctagser_params
        echom "Creating tags for" split(params)[0]

        if exists('*job_start')
            let job = job_start([l:exe] + split(params),
                        \   {
                        \     "out_cb": "ctagser#job_start_stdout_handler",
                        \     "err_cb": "ctagser#job_start_stderr_handler",
                        \     "exit_cb": "ctagser#job_start_exit_handler",
                        \   }
                        \ )
        elseif exists('*jobstart')
            let job = jobstart([l:exe] + split(params),
                        \   {
                        \     "on_stdout": "ctagser#jobstart_stdout_handler",
                        \     "on_stderr": "ctagser#jobstart_stderr_handler",
                        \     "on_exit": "ctagser#jobstart_exit_handler",
                        \   }
                        \ )
        else
            system(exe . " " . params)
            if v:shell_error == 0
              echom "tagscreate: success"
            else
              echom "tagscreate: failed with code" v:shell_error
            endif
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
