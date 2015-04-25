let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
      \ 'name': 'haskellimport',
      \ 'max_candidates': 30,
      \ 'is_volatile': 1,
      \ 'required_pattern_length': 2,
      \ }

function! s:unite_source.gather_candidates(args, context)
  return map(
        \ split(s:remove_verbose(unite#util#system('hoogle --verbose "' . a:context.input . '"')), "\n"),
        \ '{
        \ "word": v:val,
        \ "source": "haskellimport",
        \ "kind": "command",
        \ "action__command": printf("silent Haskellimport \"%s\"", v:val),
        \ }')
endfunction

function! unite#sources#haskellimport#define()
  return executable('hoogle') ? s:unite_source : []
endfunction

function! s:remove_verbose(output)
  let l:output = substitute(a:output, '^.*= ANSWERS =\n', '', '')
  let l:output = substitute(l:output, '^No results found\n', '', '')
  let l:output = substitute(l:output, 'package.\{-}\n', '', 'g')
  let l:output = substitute(l:output, '  -- \(\a\+\(+\a\+\)*\)*', '', 'g')
  return l:output
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
