let s:save_cpo = &cpo
set cpo&vim

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

function! haskellimport#import(x) abort
  let y = split(eval(a:x), ' ')
  let pos = getpos('.')
  let name = y[1]
  if name ==# 'class' && len(y) > 2
    let name = y[2]
    let idx = index(y, '=>')
    if idx >= 0 && len(y) > idx + 1
      let name = y[idx + 1]
    endif
  elseif (name ==# 'data' || name ==# 'type') && len(y) > 2
    let name = y[2]
  endif
  let added = s:add_name(y[0], name)
  if !added
    let pos[1] += s:add_import(y[0], name)
  endif
  call setpos('.', pos)
endfunction


function! s:add_name(module, name) abort
  let module_re = escape(a:module, '.\')
  let import_re = '^import \+' . module_re
  call cursor(1, 1)

  let newpos = search(import_re . '\([A-Za-z0-9_.]\)\@!')
  if !newpos
    return 0
  endif

  let line = getline(newpos)
  let tail = matchstr(line, '\s*\(--.*$\|$\)')
  let line = line[0:-len(tail)-1]

  " 'import Foo.Bar' . '\s+' . '(\s*' . 'foldl, transpose, concat' . '\s*)'
  let m = matchlist(line, import_re . '\(\s\+\)' . '\((\s*\)' . '\(\%(\%(,\s*\)\?[^(), ]\+\|([^() ]*)\)*\)' . '\(.*\)')
  if len(m) < 1
    return 1
  endif

  let [leading, opening, names, rest] = m[1:4]
  let name_list = split(names, '\s*,\s*')

  " Import the module fully
  if a:name ==# ''
    call setline(newpos, 'import ' . a:module . tail)
  else
    " If <name> have not been imported.
    if index(name_list, a:name) < 0
      let name_list = add(name_list, a:name)
      call setline(newpos, 'import ' . a:module . leading . opening . join(sort(name_list), ', ') . rest . tail)
    endif
  endif

  return 1
endfunction


function! s:add_import(module, name) abort
  if a:name ==# ''
    let line = printf('import %s', a:module)
  else
    let line = printf('import %s (%s)', a:module, a:name)
  endif
  let newpos = search('^import', 'b')
  if newpos == 0
    call cursor(1, 1)
  else
    call search('^[^ ]\|^$')
  endif
  call append(getpos('.')[1] - 1, line)
  if getline('.') !~# '^import\|^\s*$'
    call append(getpos('.')[1] - 1, '')
    return 2
  endif
  return 1
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
