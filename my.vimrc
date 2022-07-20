syntax on
packloadall

" default settings
filetype indent on
set autoindent
set cursorline
set expandtab
set hidden
set hlsearch
set ignorecase
set number
set shiftwidth=2
set smartcase
set smartindent
set showtabline=2
set so=5
set softtabstop=2
set t_Co=256
set tabstop=2
" termguicolors does not work on Terminal
" set termguicolors
set updatetime=100
set wildchar=<Tab> wildmenu wildmode=full

" custom functions
function! Input()
	call inputsave()
	let what = input('what? ')
	call inputrestore()
	echo "\n"
	return what
endfunction

" arglist : [ cwd ]
" change window local working directory
function! Tapi_lcd(bufnum, arglist)
  let winid = bufwinid(a:bufnum)
  let cwd = get(a:arglist, 0, '')
  if winid == -1 || empty(cwd)
    return
  endif
  call win_execute(winid, 'lcd ' . cwd)
endfunction

function CompareBufNrsByMru(nr1, nr2, dir=1)
  " dir: default ascending order, else use -1
  let buf1 = getbufinfo(nr1)
  let buf2 = getbufinfo(nr2)
  return (buf1['lastused'] - buf2['lastused']) * dir
endfunction

" leader + mappings
" default mapleader is \
" movement with f F t T
map <Space> <Leader>
inoremap <C-Space> <Esc>

" normal mappings
nnoremap <silent> gj :bn<CR>
nnoremap <silent> gk :bp<CR>
nnoremap <silent> gl :b #<CR>
" nnoremap <silent> <leader><Tab><Tab> :call SwitchToTaggedBuffer()<CR>
" nnoremap <silent> <leader><Tab>e :echo 'Tagged Buffer NRs: ' . tagged_buffers->join(', ')<CR>
" nnoremap <silent> <leader><Tab>f :call FixTaggedBuffers()<CR>
" nnoremap <silent> <leader><Tab>r :call ResetTaggedBuffers()<CR>
" nnoremap <silent> <leader><Tab>t :call TagBuffer()<CR>
nnoremap <silent> <Leader>/ :noh<CR>
"
" BFFs - to change to a method as it's too long to type...
" - C: clears the buffers list
nnoremap <silent> <Leader>bffC :unlet bff_buffers <BAR> unlet bff_idx <BAR> echo 'BFF buffers cleared' <CR>
" - e: "echo" the list of BFF buffers
function BffEcho()
  echom 'BFF buffers: [' . g:bff_buffers->join(', ') . '] at position ' . g:bff_idx
endfunction
nnoremap <silent> <leader>bffe :call BffEcho()<CR>
" - s: sorts the list by MRU
function BffSort()
  let g:bff_buffers = get(g:, 'bff_buffers', [])
  call sort(g:bff_buffers, CompareBufNrsByMru)
endfunction
nnoremap <silent> <Leader>bffs :call BffSort()<CR>
"
" copy the word
nnoremap <silent> <leader>c :let @*=expand('<cword>')<CR>
"
" directory commands
" - c: change directory
"   - c: invitae-crop
nnoremap <leader><C-d>cc :cd ~/Applications/invitae-crop<CR>
"   - v: invitae-vdb
nnoremap <leader><C-d>cv :cd ~/Applications/invitae-vdb<CR>
" - u: update to current file's repo dir by finding the config dir, upwards
"   with ';'
nnoremap <leader><C-d>u :exec 'cd ' . finddir('.git/..', expand('%:p:h').';')<CR>
nnoremap <silent> <Leader><C-s> :execute 'Ack! -p ~/mystuff/crop/.ag-ignore-tests -w ' . expand('<cword>')<CR>
"
nnoremap <leader>e :e %:h/
nnoremap <silent> <Leader>f :FZF<CR>
"
" format file and go back to last location
nnoremap <silent> <leader>F :g/./ normal gqq<CR>:noh<CR>``
nnoremap <silent> <leader>gb :Git blame<CR>
"
" h is for gitgutter too
nnoremap <silent> <leader>hh :let @/=expand('<cword>')<CR>
"
" Cycle between, and add new, BFF Buffers.
" BFF stands for Buffer For Fun... or something like that.
" It's really just to keep a list of most used buffers.
" If not on a BFF, go back to the last visited one.
" It would be better if i could just cycle all the buffers by MRU but will
" need to update logic.
" (maybe record current buffer before switching so that gl goes back to it?)
function BffNext(direction=1, add=0)
  " get BFF Idx pointing to the current buffer in the list...
  let g:bff_idx = get(g:, 'bff_idx', 0)
  " ...of BFF Buffers.
  let g:bff_buffers = get(g:, 'bff_buffers', [bufnr('%')])
  let nr = bufnr('%')
  let bufpos = g:bff_buffers->index(nr)
  "
  " is buffer not yet in the list?...
  if bufpos == -1
    if a:add
      "...insert new buffer at current position...
      call insert(g:bff_buffers, nr, g:bff_idx)
      "...increment the id again to point the one after this newly added nr...
      let g:bff_idx += a:direction
    endif
  else
    " ...else current buffer is part of BFF, so move to the next one...
    let g:bff_idx = bufpos + a:direction
    " ...using bufpos because if the current buffer is a BFF, reached by
    " non-BFF methods, then the next one is after this buffer, not technically
    " after the index which `bff_idx' is currently set to.
  endif
  "
  " reset to 0 if at the last position.
  if a:direction > 0 && g:bff_idx >= len(g:bff_buffers)
    let g:bff_idx = 0
  elseif a:direction < 0 && g:bff_idx < 0
    let g:bff_idx = len(g:bff_buffers) - 1
  endif
  "
  call BffEcho()
  " switch to buffer
  exec 'b ' . g:bff_buffers[g:bff_idx]
endfunction

nnoremap <silent> <leader>j :call BffNext(1, 0)<CR>
nnoremap <silent> <leader>J :call BffNext(1, 1)<CR>
nnoremap <silent> <leader>k :call BffNext(-1, 0)<CR>
nnoremap <silent> <leader>K :call BffNext(-1, 1)<CR>
"
" delete BFF buffer from list, but only if on one
function DelBff()
  let g:bff_idx = get(g:, 'bff_idx', 0)
  let g:bff_buffers = get(g:, 'bff_buffers', [bufnr('%')])
  if len(g:bff_buffers) && g:bff_idx >= 0 && g:bff_idx < len(g:bff_buffers)
    call remove(g:bff_buffers, g:bff_idx)
  endif
  if g:bff_idx >= len(g:bff_buffers)
    let g:bff_idx -= 1
  endif
  call BffEcho()
endfunction

nnoremap <silent> <leader>d :call DelBff()<CR>
"
" nnoremap <silent> <leader>K :call NextBigThing(0)<CR>
" copy file parent directory path
nnoremap <silent> <leader>ld :let @"=expand('%:h/')<CR>
nnoremap <silent> <leader>lD :let @*=expand('%:h/')<CR>
" copy file path
nnoremap <silent> <leader>lf :let @"=expand('%')<CR>
nnoremap <silent> <leader>lF :let @*=expand('%')<CR>
" copy path with line number for vim
nnoremap <silent> <leader>ll :let @"=expand('%') . ":" . line('.')<CR>
nnoremap <silent> <leader>lL :let @*=expand('%') . ":" . line('.')<CR>
" copy path for test
nnoremap <silent> <leader>lt :let @"=expand('%') . "::" . expand('<cword>')<CR>
nnoremap <silent> <leader>lT :let @*=expand('%') . "::" . expand('<cword>')<CR>
" copy path for import
nnoremap <silent> <leader>li :let @"='from ' . substitute(expand('%:r'), '/', '.', 'g') . ' import ' . expand('<cword>')<CR>
nnoremap <silent> <leader>lI :let @*='from ' . substitute(expand('%:r'), '/', '.', 'g') . ' import ' . expand('<cword>')<CR>
"
" move to left or right window, expanding the width as well
function NextWindow()
  normal! 
  exec 'vertical resize ' .  (&columns / 3 * 2)
endfunction
nnoremap <silent> <leader>n :call NextWindow()<CR>
" nnoremap <silent> <leader>o :call GotoLink()<cr>
nnoremap <silent> <leader>q :bp<bar>sp<bar>bn<bar>bd<CR>
"
" quicker save
nnoremap <leader>s :update<CR>
"
" helper to switch to and between terminal buffers
function SwitchToTerm()
  let term_bufs = getbufinfo({'buflisted':1})
  call filter(term_bufs, 'v:val.name =~ "^term"')
  call filter(term_bufs, 'v:val.bufnr != ' . bufnr('%'))
  call map(term_bufs, { _, e -> ({"nr": e.bufnr, "lu": e.lastused}) })
  if bufname('%') =~ "^term"
    call sort(term_bufs, { b1, b2 -> b1.lu - b2.lu })
  else
    call sort(term_bufs, { b1, b2 -> b2.lu - b1.lu })
  endif
  exec "b " . term_bufs[0].nr
endfunction

nnoremap <silent> <Leader>t :call SwitchToTerm()<cr>
"
nnoremap <silent> <leader>v :vsp<CR>
nnoremap <silent> <leader>V :Vigit<CR>
"
" window shortcuts
nnoremap <silent> <leader>w <C-w>
" visual mappings
vnoremap <silent> <leader>c "*y

" search oldfiles
command SearchOld execute ':browse filter /' . Input() . '/ oldfiles'

" open file at line in github
command Vigit execute '!open https://github.com/invitae-internal/$(basename $(git rev-parse --show-toplevel))/blob/$(git rev-parse --abbrev-ref HEAD)/' .  expand('%') . '\#L' . line('.')

" theme
autocmd vimenter * ++nested colorscheme gruvbox
set background=dark
let g:airline_theme = 'gruvbox'

" prettier
let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0

" ack
let g:ackprg = 'ag --vimgrep'

" set shell scripts' tab=4
autocmd FileType sh setlocal shiftwidth=4 softtabstop=4 expandtab

" python-mode
let g:pymode_python = 'python3'
let g:pymode_options_max_line_length = 120
let g:pymode_lint_options_pep8 = {'max_line_length': g:pymode_options_max_line_length}
let g:pymode_options_colorcolumn = 1
let g:pymode_breakpoint_bind = '<leader>B'
" override ;b from breakpoint to (; as leader) BufExplorer (does not work!)
" autocmd VimEnter * nnoremap <Leader>b :BufExplorer<CR>

" copy filename to clipboard
" :let @* = expand("%")

" gitgutter
let g:gitgutter_enabled = 1
let g:gitgutter_highlight_linenrs = 1
highlight GitGutterAdd guifg=#009900 ctermfg=Green
highlight GitGutterCahnge guifg=#bbbb00 ctermfg=Yellow
highlight GitGutterDelete guifg=#ff2222 ctermfg=Red

" groovy mode
autocmd FileType groovy setlocal shiftwidth=4 softtabstop=4 expandtab

" jenkinsfile
autocmd FileType Jenkinsfile setlocal shiftwidth=4 softtabstop=4 expandtab

" json
autocmd FileType json setlocal ts=2 sw=2 expandtab

" JSX, react, typescript
autocmd BufNewFile,BufRead *.ts*,*.js(x)? set filetype=typescriptreact

" dark red
hi tsxTagName guifg=#E06C75
hi tsxComponentName guifg=#E06C75
hi tsxCloseComponentName guifg=#E06C75

" orange
hi tsxCloseString guifg=#F99575
hi tsxCloseTag guifg=#F99575
hi tsxCloseTagName guifg=#F99575
hi tsxAttributeBraces guifg=#F99575
hi tsxEqual guifg=#F99575

" yellow
hi tsxAttrib guifg=#F8BD7F cterm=italic

" light-grey
hi tsxTypeBraces guifg=#999999
" dark-grey
hi tsxTypes guifg=#666666

hi ReactState guifg=#C176A7
hi ReactProps guifg=#D19A66
hi ApolloGraphQL guifg=#CB886B
hi Events ctermfg=204 guifg=#56B6C2
hi ReduxKeywords ctermfg=204 guifg=#C678DD
hi ReduxHooksKeywords ctermfg=204 guifg=#C176A7
hi WebBrowser ctermfg=204 guifg=#56B6C2
hi ReactLifeCycleMethods ctermfg=204 guifg=#D19A66

" nerdtree
" let g:NERDTreeWinPos = "right"

" remove trailing whitespaces
autocmd BufWritePre * :%s/\s\+$//e

" tags
set tags=tags;/
