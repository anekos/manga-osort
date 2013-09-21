
" Mojo {{{

if exists('g:anekos_manga_osort_loaded')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

" }}}

let s:default_options = {'pre' : 0, 'key' : 0, 'ignorecase' : 0, 'pattern' : ''}
let s:option_names = ['pre', 'key', 'ignorecase']
let s:key_prefix = 'a'
let s:empty_key = 'z'

function! s:MakeDefaultOption() " {{{
  let l:result = copy(s:default_options)
  if exists('g:manga_osort_default_options')
    for [l:key, l:value] in items(g:manga_osort_default_options)
      let l:result[l:key] = l:value
    endfor
  endif
  return l:result
endfunction " }}}

function! s:FParseArgs(args) " {{{
  let l:result = s:MakeDefaultOption()

  let l:patterns = []
  for l:arg in a:args
    if match(l:arg, '^/') == 0
      let l:patterns = l:patterns + [l:arg]
    else
      let l:kv = match(l:arg, '=')
      if l:kv < 0
        let l:patterns = l:patterns + [l:arg]
      else
        let l:key = l:arg[: l:kv - 1]
        if index(s:option_names, l:key) >= 0
          let l:value = l:arg[l:kv + 1 :]
          let l:result[l:key] = l:value
        else
          echoerr 'Unknow option: ' . l:arg
        endif
      endif
    endif
  endfor

  " テケトー
  if len(l:patterns)
    let l:result.pattern = join(l:patterns, ' \+')
  endif
  return l:result
endfunction " }}}

function! s:QParseArgs(args) " {{{
  let l:slash = match(a:args, '/')
  let l:result = s:MakeDefaultOption()

  if l:slash >= 0
    let l:rest = ''

    for l:arg in split(a:args[: l:slash - 1], '\s\+')
      let l:kv = match(l:arg, '=')
      if l:kv < 0
        echoerr 'Unknow option: ' . l:arg
      else
        let l:key = l:arg[: l:kv - 1]
        if index(s:option_names, l:key) >= 0
          let l:value = l:arg[l:kv + 1 :]
          let l:result[l:key] = l:value
        else
          echoerr 'Unknow option: ' . l:arg
        endif
      endif
    endfor

    let l:result.pattern = l:rest . a:args[l:slash + 1 :]
  endif

  return l:result
endfunction " }}}

function! s:Push(chunks, chunk, key_index) " {{{
  if (a:key_index < len(a:chunk)) && (a:chunk[a:key_index] != '')
    let l:key = s:key_prefix . a:chunk[a:key_index]
  else
    " 空の場合は、後ろにとりあえずもってく
    let l:key = s:empty_key

    " とりあえずエラーはやめる
    " echoerr 'Empty key line. Check the value of "key" option = ' . a:key_index . '.'
    " return 0
  endif

  if has_key(a:chunks, l:key)
    let a:chunks[l:key] = a:chunks[l:key] + a:chunk
  else
    let a:chunks[l:key] = a:chunk
  end

  return 1
endfunction " }}}

function! s:ChunkedSort(first, last, ...) " {{{
  let l:opt = s:FParseArgs(a:000)

  let l:first = 1
  let l:cur_chunk = []

  let l:prefix = 0
  let l:chunks = {}

  for l:i in range(a:first, a:last)
    let l:line = getline(l:i)

    if match(l:line, l:opt.pattern) >= 0
      if l:first == 1
        let l:first = 0
      else
        if ! s:Push(l:chunks, l:cur_chunk, l:opt.key)
          return 0
        endif
      endif

      let l:cur_chunk = [l:line]

    else
      if l:first == 1
        let l:prefix = l:prefix + 1
      else
        let l:cur_chunk = l:cur_chunk + [l:line]
      endif
    endif
  endfor

  if l:first == 1
    echoerr "Not found key: " . l:opt.pattern
    return
  endif

  if ! s:Push(l:chunks, l:cur_chunk, l:opt.key)
    return 0
  endif

  let l:pos = getpos('.')
  execute (a:first + l:prefix) . ',' . a:last . 'delete'

  let l:last = a:first - 1 + l:prefix

  if l:opt.ignorecase
    let l:sorted_keys = sort(keys(l:chunks), 1)
  else
    let l:sorted_keys = sort(keys(l:chunks))
  endif

  for l:key in l:sorted_keys
    call append(l:last, l:chunks[l:key])
    let l:last += len(l:chunks[l:key])
  endfor

  call cursor(l:pos[1:])
endfunction " }}}

function! s:Compl(lead, cmdline, cursorpos) " {{{
  return map(copy(s:option_names), 'v:val . "="')
endfunction " }}}

command! -range=% -nargs=* -complete=customlist,s:Compl OSort call s:ChunkedSort(<line1>, <line2>, <f-args>)

" Mojo {{{

let &cpo = s:save_cpo
unlet s:save_cpo

let g:anekos_manga_osort_loaded = 1

" }}}
