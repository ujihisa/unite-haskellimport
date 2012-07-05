command! Haskellimport call s:haskellimport(<q-args>)

" Supported patterns
"
" import Root.A
" import Root.B (a, b, c)
" import Root.C (a, b, c
"               , d )
" import Root.D ((<$>), a, b)
" import Root.E ( a, b, (<$>)
"               , c)
" import Root.F (a, b, c) -- bar
" import Root.J ( a, b, (<$>) -- cat
"               , c)
" import Root.K ( a, b, (<$>))
" import Root.L ( a, b, (<$>)) -- cat
" import Root.M ( a, b, c,
"                 d, e )

function! s:haskellimport(x)
  let y = split(eval(a:x), ' ')
  let pos = getpos('.')
  let added = s:add_name(y[0], y[1])
  if !added
    call s:add_import(y[0], y[1])
  endif
  call setpos('.', pos)
endfunction


function! s:add_name(module, name)
  let module_re = escape(a:module, '.\')
  let import_re = '^import \+' . module_re
  call cursor(1, 1)

  let newpos = search(import_re)
  if !newpos
    return 0
  endif

  let line = getline(newpos)
  let tail = matchstr(line, '\s*\(--.*$\|$\)')
  let line = line[0:-len(tail)-1]

  " 'import Foo.Bar' . <SPACES> . '( foldl, transpose, concat )' . ' -- comment'
  let m = matchlist(line, import_re . '\(\s\+\)' . '(\(\s*\)' . '\(.*\)')
  if len(m) < 1
    return 1
  endif

  let [head, ihead, names] = m[1:3]
  let end = ''
  let name_list = split(names, '\s*,\s*')
  let last_name = name_list[-1]

  " if last_name is '(<$>)' or 'foo)'
  if match(last_name, '^\((.*))\|[^(]\+)\)$') > -1
    let name_list[-1] = substitute(last_name, '\s*)', '', '')
    let end = ')'
  endif

  " if 'import Foo.Bar (a, b, c<,>'
  if match(names, ',\s*$') > -1
    let end = ',' . l:end
  endif

  " Add if <name> have not been imported.
  if index(name_list, a:name) < 0
    let name_list = add(name_list, a:name)
    call setline(newpos, 'import ' . a:module . head . '(' . ihead . join(sort(name_list), ', ') . end . tail)
  endif

  return 1
endfunction


function! s:add_import(module, name)
  let line = printf("import %s (%s)", a:module, a:name)
  let newpos = search('^import', 'b')
  if newpos == 0
    call cursor(1, 1)
  else
    call cursor(newpos)
    call cursor(search('^[^ ]\|^$'))
  endif
  call append(getpos('.')[1] - 1, line)
endfunction
