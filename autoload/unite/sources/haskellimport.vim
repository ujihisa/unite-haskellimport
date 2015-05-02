let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
      \ 'name': 'haskellimport',
      \ 'max_candidates': 30,
      \ 'is_volatile': 1,
      \ 'required_pattern_length': 1,
      \ }

function! s:hoogle(input)
  return unite#util#system(
        \ 'hoogle --verbose "' . escape(a:input, '\"') . '"'
        \.' | sed -e "/^= ANSWERS =/d" -e "/^No results found/d" -e "/^keyword/d" -e "/^package/d" -e "s/  -- [+a-zA-Z]*$//g"'
        \.' | head -n 31')
endfunction

function! s:unite_source.gather_candidates(args, context)
  let input = a:context.input =~# '^\*\+$' ? '(' . a:context.input . ')' : a:context.input
  let input = input =~# '^([-+*<>/$|@]\+$' ? input . ')' : input
  let result = s:hoogle(input)
  if result =~# '^Parse error.*Closing bracket expected'
    let result = s:hoogle(substitute(a:context.input, '(', '', ''))
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
