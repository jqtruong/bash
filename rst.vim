function! s:GotoLink()
  " yank inside backticks (rst refs) and mark position
  normal! yi`m'
  " @" contains the reference to search for, fixed with rst link formatting
  let regex = '.. _' . @" . ': *.'
  " search for link label from beginning of buffer
  normal! gg
  call search(regex, 'e')
  " cursor should be on the first character of the file::method string, so
  " yank until end of line
  exec "normal y$\<C-O>"
  " split the file::method string (TODO: use tags and pymove, or split more
  " for class name, and search for each split)
  let file_method = split(@", '::')
  let file = file_method[0]
  let method = file_method[1]
  " edit file
  exec 'e ' . file
  " search for method definition (TODO: constants don't start with `def')
  call search('def ' . method)
  " next word to be on the method name, then scroll down a bit
  normal! wzt
endfunction

function! s:NextThing(forward=1)
  " for rst, thing is a ref
  let regex = '`\{1}[^`]\+`_'
  if a:forward
    call search(regex, 'zs')
  else
    call search(regex, 'zbs')
  endif
  normal l
endfunction

function! s:NextBigThing(forward=1)
  " for rst, big thing is a heading
  let regex = '^.\+\n[=\-\.`~]\+\n'
  if a:forward
    call search(regex, 's')
  else
    call search(regex, 'bs')
  endif
endfunction

noremap <script> <buffer> <silent> <leader>o
        \ :call <SID>GotoLink()<cr>

noremap <script> <buffer> <silent> ]]
        \ :call <SID>NextBigThing(1)<cr>

noremap <script> <buffer> <silent> [[
        \ :call <SID>NextBigThing(0)<cr>

noremap <script> <buffer> <silent> ]l
        \ :call <SID>NextThing(1)<cr>

noremap <script> <buffer> <silent> [l
        \ :call <SID>NextThing(0)<cr>
