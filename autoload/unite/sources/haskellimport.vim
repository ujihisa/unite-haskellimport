let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
      \ 'name': 'haskellimport',
      \ 'max_candidates': 30,
      \ 'is_volatile': 1,
      \ 'required_pattern_length': 1,
      \ }

if has('win16') || has('win32') || has('win64') || has('win95')
  function! s:system(cmd)
    return unite#util#system(a:cmd)
  endfunction
else
  function! s:system(cmd)
    return system(a:cmd)
  endfunction
endif

function! s:hoogle(input)
  return s:system(
        \ 'hoogle --verbose "' . escape(a:input, '\"') . '"'
        \.' | sed -e "/^= ANSWERS =/d" -e "/^No results found/d" -e "/^keyword/d" -e "/^package/d" -e "s/  -- [+a-zA-Z]*$//g"'
        \.' | head -n 31')
endfunction

function! s:unite_source.gather_candidates(args, context)
  if a:context.input =~# '^\s*(\s*$'
    let result = ''
  else
    let input = a:context.input =~# '^\*\+$' ? '(' . a:context.input . ')' : a:context.input
    let input = input =~# '^([-+*<>/$|@]\+$' ? input . ')' : input
    let result = s:hoogle(input)
    if result =~# '^Parse error.*Closing bracket expected'  
      let result = s:hoogle(substitute(a:context.input, '(', '', ''))
    endif
  endif
  return map(
        \ split(result, "\n"),
        \ '{
        \ "word": v:val,
        \ "source": "haskellimport",
        \ "kind": "command",
        \ "action__command": printf("silent Haskellimport \"%s\"", escape(v:val, "\\\"")),
        \ }')
endfunction

function! unite#sources#haskellimport#define()
  return executable('hoogle') ? s:unite_source : []
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
