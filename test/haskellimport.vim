scriptencoding utf-8

let s:suite = themis#suite('haskellimport')
let s:assert = themis#helper('assert')

function! s:suite.import()
  call haskellimport#import(string("A f"))
  call s:assert.equals(getline(1, '$'), ['import A (f)', ''])
endfunction
