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

filetype plugin indent on
set shell=/bin/zsh
set ruler
set hlsearch
set incsearch
set showmatch
set encoding=utf-8
set clipboard=unnamedplus
set textwidth=80
set spell spelllang=en_us

" Syntastic settings

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_python_checkers = ['flake8']

" Specify the default .vimrc file as the one under working directory

set exrc
set secure

" Indentation rules

set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab

" Highlight the column number 80

set colorcolumn=80
highlight ColorColumn ctermbg=yellow

" Set files as C files

augroup project
    autocmd!
    autocmd BufRead,BufNewFile *.h,*.c set filetype=c.doxygen
augroup END

" Edit settings

set number
inoremap jk <ESC>

" Spell

nnoremap <leader>f 1z=
nnoremap <leader>s :set spell!
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

" Color scheme
set background=dark
colorscheme PaperColor

" Python
let g:jedi#goto_command = "<leader>d"
let g:jedi#goto_assignments_command = "<leader>g"
let g:jedi#goto_definitions_command = ""
let g:jedi#documentation_command = "K"
let g:jedi#usages_command = "<leader>n"
let g:jedi#completions_command = "<C-N>"
let g:jedi#rename_command = "<leader>r"

