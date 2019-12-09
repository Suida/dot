" Compatibility

if has('win32') || has('win64')
    set runtimepath-=~/vimfiles
    set runtimepath^=~/.vim
    set runtimepath-=~/vimfiles/after
    set runtimepath+=~/.vim/after
endif

" Pathogen settings

execute pathogen#infect()

" Basics

syntax on
filetype plugin indent on
set shell=/bin/zsh
set ruler
set hlsearch
set incsearch
set showmatch
set encoding=utf-8
set clipboard=unnamedplus
set textwidth=80
set spell spelllang=en_us,cjk
set conceallevel=2
let mapleader = " "

" Syntastic settings

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Specify the default .vimrc file as the one under working directory

set exrc
set secure

" Indentation rules

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" Highlight the column number 80

set colorcolumn=80
highlight ColorColumn ctermbg=yellow

" Set files as C files

augroup project
    autocmd!
    autocmd BufRead,BufNewFile *.h,*.c set filetype=c.doxygen
augroup END

" Spell & Edit settings

fun! IgnoreCustomItems()
    syn match CamelCase0 /\<[A-Z][a-z]\+[A-Z].\{-}\>/ contains=@NoSpell transparent
    syn match CamelCase1 /\<[a-z]\+[A-Z].\{-}\>/ contains=@NoSpell transparent
    syn match SnakeCase0 /\<\w*_\+\w\+\>/ contains=@NoSpell transparent
    syn match UpperCase /\<[A-Z0-9]\+\>/ contains=@NoSpell transparent
    syn cluster Spell add=CamelCase0
    syn cluster Spell add=CamelCase1
    syn cluster Spell add=SnakeCase0
    "" syn cluster Spell add=UpperCase
endfun
autocmd BufRead,BufNewFile * :call IgnoreCustomItems()
set number
nnoremap <leader>f 1z=
nnoremap <leader>s :set spell!
inoremap jk <ESC>
noremap <leader>y "*y
noremap <leader>p "*p
nnoremap / /\v
vnoremap / /\v

" Arrows are not suggested

nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" Clang complete

let g:clang_library_path='/usr/lib/llvm-6.0/lib'

" Markdown

let g:vim_markdown_autowrite = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_no_extensions_in_markdown = 1

" Color scheme

set t_Co=256
set background=dark
set laststatus=2
colorscheme PaperColor
let g:PaperColor_Theme_Options = {
  \   'theme': {
  \     'default.dark': {
  \       'transparent_background': 1
  \     }
  \   }
  \ }
let g:airline_theme='papercolor'

" Python

let syntastic_python_checkers = ["flake8"]
let g:jedi#auto_initialization = 1
let g:jedi#use_tabs_not_buffers = 1
let g:jedi#use_splits_not_buffers = "left"
let g:jedi#completions_enabled = 1
let g:jedi#auto_vim_configuration = 1
let g:jedi#smart_auto_mappings = 1
let g:jedi#show_call_signatures = "1"
let g:jedi#completions_command = "<C-N>"

" Git

set updatetime=100
let g:gitgutter_highlight_linenrs = 1
