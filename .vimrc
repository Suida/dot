" Compatibility

if has('win32') || has('win64')
    set runtimepath-=~/vimfiles
    set runtimepath^=~/.vim
    set runtimepath-=~/vimfiles/after
    set runtimepath+=~/.vim/after
endif

" Specify the default .vimrc file as the one under working directory

set exrc
set secure

" Pathogen settings

execute pathogen#infect()

" Basics
if (has("termguicolors"))
    set termguicolors
endif
syntax on
filetype plugin indent on
set shell=/bin/zsh
set ruler
set hlsearch
set incsearch
set showmatch
set encoding=utf-8
set clipboard=unnamedplus
set nowrap
set spelllang=en_us,cjk
set conceallevel=2
let mapleader = " "

inoremap <C-e> <C-o>A

" Syntastic settings

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1
function! FindConfig(prefix, what, where)
    let cfg = findfile(a:what, fnameescape(a:where) . ';')
    return cfg !=# '' ? ' ' . a:prefix . ' ' . shellescape(cfg) : ''
endfunction

" Indentation rules

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" Highlight the column number 80

set colorcolumn=80
set cursorline

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
    syn match ShortWord /\<\w\{1,4}\>/ contains=@NoSpell transparent
    syn cluster Spell add=CamelCase0
    syn cluster Spell add=CamelCase1
    syn cluster Spell add=SnakeCase0
    syn cluster Spell add=ShortWord
    "" syn cluster Spell add=UpperCase
endfun
autocmd BufRead,BufNewFile * :call IgnoreCustomItems()
set number
nnoremap <leader>f 1z=
nnoremap <leader>s :set spell!<CR>
inoremap jk <ESC>
noremap <leader>y "*y
noremap <leader>p "*p
nnoremap / /\v
vnoremap / /\v
nnoremap <C-j> 10j
nnoremap <C-k> 10k

" Arrows are not suggested

nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" NERDTree

nnoremap <leader>e :NERDTreeToggle<CR>
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

" Clang complete

let g:clang_library_path='/usr/lib/llvm-6.0/lib'
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_concepts_highlight = 1

" Markdown

let g:vim_markdown_folding_level = 3
let g:vim_markdown_autowrite = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_no_extensions_in_markdown = 1

" Color scheme

set t_Co=256
set background=dark
set laststatus=2
colorscheme tender
let g:PaperColor_Theme_Options = {
  \   'theme': {
  \     'default.dark': {
  \       'transparent_background': 1
  \     }
  \   }
  \ }
let g:airline_theme='molokai'
hi Normal guibg=NONE ctermbg=NONE
hi LineNr guifg=DeepPink2 guibg=NONE ctermfg=yellow ctermbg=NONE
hi TabLineFill guibg=NONE ctermfg=NONE ctermbg=NONE
hi ColorColumn guibg=Grey63

" Python
" Highlight and checker of syntastic, all other stuffs are originated from jedi

let g:python_highlight_all = 1
let syntastic_python_checkers = ["pylint","flake8"]
let g:jedi#auto_initialization = 1
let g:jedi#use_tabs_not_buffers = 1
let g:jedi#completions_enabled = 1
let g:jedi#auto_vim_configuration = 1
let g:jedi#smart_auto_mappings = 1
let g:jedi#show_call_signatures = "1"
let g:jedi#completions_command = "<C-N>"
let g:jedi#usages= "<leader>n"
let g:jedi#rename_command = "<leader>m"

autocmd FileType python let b:syntastic_python_flake8_args =
    \ get(g:, 'syntastic_python_flake8_args', '') .
    \ FindConfig('-c', '.flake8', expand('%:p:h'))
    "" \ FindConfig('-c', 'tox.ini', expand('%:p:h'))
    "" \ FindConfig('-c', 'setup.cfg', expand('%:p:h'))

" Git

set updatetime=100
let g:gitgutter_highlight_linenrs = 1

" Rust

let g:rust_conceal = 1
let g:rust_conceal_mod_path = 1
let g:rust_conceal_pub = 1
let g:rustfmt_command = 'rustfmt'
let g:rustfmt_autosave = 1
let g:rustfmt_autosave_if_config_present = 1
