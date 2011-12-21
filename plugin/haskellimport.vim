command! Haskellimport call s:haskellimport(<q-args>)

function! s:haskellimport(x)
  let y = split(eval(a:x), ' ')
  let line = printf("import %s (%s)", y[0], y[1])
  let pos = getpos('.')
  let newpos = search('^import', 'b')
  if newpos == 0
    call cursor(1, 1)
  else
    call cursor(newpos)
    call cursor(search('^[^ ]\|^$'))
  endif
  call append(getpos('.')[1] - 1, line)
  call setpos('.', pos)
endfunction
