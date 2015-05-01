let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
      \ 'name': 'haskellimport',
      \ 'max_candidates': 30,
      \ 'is_volatile': 1,
      \ 'required_pattern_length': 1,
      \ }

function! s:hoogle(input)
  return s:remove_verbose(unite#util#system('hoogle --verbose "' . escape(a:input, '\"') . '" | head -n 31'))
endfunction

function! s:unite_source.gather_candidates(args, context)
  let result = s:hoogle(a:context.input)
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

function! s:remove_verbose(output)
  let l:output = substitute(a:output, '^.*= ANSWERS =\n', '', '')
  let l:output = substitute(l:output, '^No results found\n', '', '')
  let l:output = substitute(l:output, '\%(package\|keyword\).\{-}\n', '', 'g')
  let l:output = substitute(l:output, '  -- \(\a\+\(+\a\+\)*\)*', '', 'g')
  return l:output
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
