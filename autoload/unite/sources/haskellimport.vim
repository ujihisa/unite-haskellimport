let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
      \ 'name': 'haskellimport',
      \ 'max_candidates': 30,
      \ 'is_volatile': 1,
      \ 'required_pattern_length': 1,
      \ }

if has('win16') || has('win32') || has('win64') || has('win95')
  " For Windows, we use the utility function of unite, which is actually the
  " function of vimproc, so that executing the external command does not show
  " the command prompt window.
  function! s:system(cmd)
    return unite#util#system(a:cmd)
  endfunction
else
  " For non-Windows, we use the system() function of Vim. Encoding conversion
  " is not required for the hoogle command and system() is actually faster
  " than the command of vimproc.
  function! s:system(cmd)
    return system(a:cmd)
  endfunction
endif

" This function executes hoogle with the input keyword. Also it removes the
" lines which the user does not intend to import to the source code. The
" command `head` is used to trim the candidates list because too many
" candidates causes the performance down.
function! s:hoogle(input)
  return s:system(
        \ 'hoogle --verbose "' . escape(a:input, '\"') . '"'
        \.' | sed -e "/^= ANSWERS =/d" -e "/^No results found/d" -e "/^keyword/d" -e "/^package/d" -e "s/  -- [+a-zA-Z]*$//g"'
        \.' | head -n 30')
endfunction

" This function gathers the candidates using the `hoogle` command. Firstly,
" when the input is `(`, there is no need to execute the external command.
" Then, it wraps the input with the parentheses when the input matches \*\+.
" This is because the `hoogle` command cannot suggest the (***) operator
" with `hoogle "***"`. This might be a bug of hoogle, but we can remedy
" beforehand. Then, a closing bracket is appended when it seems that the user
" will search for an operator. Nevertheless, when hoogle warns about the missing
" closing bracket, it appends a bracket and tries again.
function! s:unite_source.gather_candidates(args, context)
  if a:context.input =~# '^\s*(\s*$'
    let result = ''
  else
    let input = a:context.input =~# '^\*\+$' ? '(' . a:context.input . ')' : a:context.input
    let input = input =~# '^([-+*<>/$|@]\+$' ? input . ')' : input
    let result = s:hoogle(input)
    if result =~# '^Parse error.*Closing bracket expected'
      let result = s:hoogle(a:context.input . ')')
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
