let s:save_cpo = &cpo
set cpo&vim

function! unite#filters#matcher_haskellimport#define()
  return s:matcher
endfunction

let s:matcher = {
      \ 'name' : 'matcher_haskellimport',
      \ 'description' : 'matcher for unite-haskellimport',
      \}

" This matcher filters out no candidates because `hoogle` command already does.
function! s:matcher.filter(candidates, context)
  return a:candidates
endfunction

" Any special symbols for regex are excaped in this matcher. Note that the
" asterisk (*) is escaped for matching the (**) operator in the untie interface.
function! s:matcher.pattern(input)
  return escape(a:input, '*~\.^$[]')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
