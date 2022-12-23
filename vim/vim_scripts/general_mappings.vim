" Global key mappings -- {{{

" Compatibility config for alacritty which dose not support control-space by
" default, where control-space is mapped to "\xb" (<ESC>) by myself, and here,
" <ESC> is remapped back to control-space to fit previous settings
imap <ESC> <C-space>

" Vimrc
nnoremap <leader>vs :vsplit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" Editting
inoremap jk <C-\><C-n>
inoremap Jk <C-\><C-n>
inoremap JK <C-\><C-n>
inoremap jjk jk
nnoremap <leader>i vit<Esc>i

inoremap <C-a> <Esc>I
inoremap <C-e> <Esc>A
inoremap <C-j> <Esc>A<Enter>
inoremap <C-k> <Esc>O
nnoremap <leader>] <C-w><C-]><C-w>T
nnoremap <silent> XC :w<CR>
nnoremap <silent> XX :w \| bd<CR>
nnoremap <silent> <leader>pp :set paste!<CR>
nmap <leader>gb ysiw}lysiw{
nmap <silent> <leader>ft :TableFormat<CR>
nnoremap <silent> - :m .+1<CR>
nnoremap <silent> _ :m .-2<CR>

" Navigation
inoremap <C-f> <Right>
inoremap <C-b> <Left>
noremap <expr>0 col('.') == 1 ? '^': '0'
noremap <expr>g0 col('.') == 1 ? '^': 'g0'
nmap h 0
nmap l $
nnoremap <C-j> 15j
nnoremap <C-k> 15k
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>
nnoremap <left> :tabp <CR>
nnoremap <right> :tabn <CR>
inoremap <left> <ESC> :tabp <CR>
inoremap <right> <ESC> :tabn <CR>
nnoremap <silent> <C-l> :tabn<CR>
nnoremap <silent> <C-h> :tabp<CR>
nnoremap <silent> <leader>tl :tabs<CR>
nnoremap <space>h <C-w>h
nnoremap <space>j <C-w>j
nnoremap <space>k <C-w>k
nnoremap <space>l <C-w>l
tnoremap <silent> <C-w> <C-\><C-n><C-w>

nnoremap <leader>bt :b 
nnoremap <leader>bs :vert sb 
nnoremap <silent> <leader>bb :<C-u>execute 'buffer ' . v:count<CR>
nnoremap <silent> <leader>bl :buffers<CR>
nnoremap <silent> <leader>ba :buffer #<CR>
nnoremap <silent> <leader>1 :normal 1gt<CR>
nnoremap <silent> <leader>2 :normal 2gt<CR>
nnoremap <silent> <leader>3 :normal 3gt<CR>
nnoremap <silent> <leader>4 :normal 4gt<CR>
nnoremap <silent> <leader>5 :normal 5gt<CR>
nnoremap <silent> <leader>6 :normal 6gt<CR>
nnoremap <silent> <leader>7 :normal 7gt<CR>
nnoremap <silent> <leader>8 :normal 8gt<CR>
nnoremap <silent> <leader>9 :normal 9gt<CR>
" Use <space>sl to clear the highlighting of :set hlsearch.
nnoremap <silent> <leader>sl :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>

" Command
nnoremap ! :!
" Spell check
nnoremap <leader>sw 1z=
nnoremap <leader>ss :set spell!<CR>
" Copy & paste
noremap <leader>y "*y
noremap <leader>p "*p
" Search
nnoremap / /\v
vnoremap / /\v
" Abbreviations
iabbrev @@ suidar@foxmail.com
iabbrev ccp Copyright 2020 Hugh Young, all rights reserved.
" Check color group under cursor
nnoremap <silent> <leader>cg :echom string(CheckColorGroup())<CR>
function! CheckColorGroup()
    return map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction
" Highlight test
nnoremap <silent> <leader>ch :so $VIMRUNTIME/syntax/hitest.vim<CR>
" Translate
nnoremap <silent> <leader>tr :Translate<CR>
" GUI Operations
noremap <M-Space>n :simalt ~n<CR>
noremap <M-Space>r :simalt ~r<CR>
noremap <M-Space>x :simalt ~x<CR>
inoremap <C-V> <C-R>+
cnoremap <C-V> <C-R>+

" Emacs-style keybindings in command mode
" change command-line window openning key map
set cedit=\<C-t>
" start of line
cnoremap <C-A>  <Home>
" back one character
cnoremap <C-B>  <Left>
" delete character under cursor
cnoremap <C-D>  <Del>
" end of line
cnoremap <C-E>  <End>
" forward one character
cnoremap <C-F>  <Right>
" recall newer command-line
" cnoremap <C-N>  <Down>
" recall previous (older) command-line
" cnoremap <C-P>  <Up>
" back one word
cnoremap <Esc><C-B> <S-Left>
" forward one word
cnoremap <Esc><C-F> <S-Right>
" }}}
