
command! -range=% -nargs=* -complete=custom,manga_osort#compl OSort call manga_osort#chunked_sort(<line1>, <line2>, <f-args>)
