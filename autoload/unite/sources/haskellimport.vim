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
        \ split(unite#util#system('hoogle "' . a:context.input . '"'), "\n"),
        \ '{
        \ "word": v:val,
        \ "source": "haskellimport",
        \ "kind": "command",
        \ "action__command": printf("silent Haskellimport \"%s\"", v:val),
        \ }')
endfunction

function! unite#sources#haskellimport#define()
  return executable('ghc-mod') ? s:unite_source : []
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
