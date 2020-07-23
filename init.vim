call plug#begin(stdpath('data').'/plugged')

Plug 'ycm-core/YouCompleteMe', { 'do': './install.py' }
Plug 'vim-syntastic/syntastic'

" Navigation & developing support
" File & sign navigator
Plug 'majutsushi/tagbar'
Plug 'preservim/nerdtree'
" Commenter & git utils
Plug 'preservim/nerdcommenter'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
" Better move
Plug 'easymotion/vim-easymotion'
Plug 'andymass/vim-matchup'
Plug 'tpope/vim-surround'
" Brackets
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-unimpaired'
" Code template
Plug 'mattn/emmet-vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" Fuzzy finer
Plug 'junegunn/fzf', { 'do': 'yes \| ./install' }
" Global finder
Plug 'brooth/far.vim'
Plug 'dyng/ctrlsf.vim'

" View
" Color schemes
Plug 'arcticicestudio/nord-vim'
" Status / tabline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Language support
Plug 'Chiel92/vim-autoformat'
Plug 'octol/vim-cpp-enhanced-highlight'
" Font-end tool chain
Plug 'pangloss/vim-javascript'
Plug 'ap/vim-css-color'
Plug 'posva/vim-vue'
" Html preview
Plug 'turbio/bracey.vim'
" Markdown syntax and preview
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" Python utils // The indent really saved my life
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'jmcantrell/vim-virtualenv'

call plug#end()


" Origin init.vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" Terminal settings

" Exit tmode
tnoremap <Esc> <C-\><C-n>
tnoremap jk <C-\><C-n>

" Ctrl+R
tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi'

" Navigate
" On my 60% keyboard, I have mapped <A-hjkl> to left/down/up/right arrows.
" So the settings following are useful somewhere, but not on my PC.
"tnoremap <A-h> <C-\><C-N><C-w>h
"tnoremap <A-j> <C-\><C-N><C-w>j
"tnoremap <A-k> <C-\><C-N><C-w>k
"tnoremap <A-l> <C-\><C-N><C-w>l
"inoremap <A-h> <C-\><C-N><C-w>h
"inoremap <A-j> <C-\><C-N><C-w>j
"inoremap <A-k> <C-\><C-N><C-w>k
"inoremap <A-l> <C-\><C-N><C-w>l
"nnoremap <A-h> <C-w>h
"nnoremap <A-j> <C-w>j
"nnoremap <A-k> <C-w>k
"nnoremap <A-l> <C-w>l

" Provider
let g:python3_host_prog="/Users/hugh/.pyenv/versions/nvim/bin/python"


" Origin vimrc
" Compatibility

set nocp
if has('win32') || has('win64')
    set runtimepath-=~/vimfiles
    set runtimepath^=~/.vim
    set runtimepath-=~/vimfiles/after
    set runtimepath+=~/.vim/after
endif


" Specify the default .vimrc file as the one under working directory

set exrc
set secure


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
set wrap
set spelllang=en_us,cjk
set conceallevel=2
" Indentation rules and folding
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set foldmethod=syntax
set nofoldenable
set autoindent
set backspace=indent,eol,start


" Global key mappings

let mapleader = " "
" Editting
inoremap jk <ESC>
inoremap <C-e> <C-o>A
inoremap <C-o> <C-o>A<CR>
nnoremap <leader>] <C-w><C-]><C-w>T
noremap <leader>ff :Autoformat<CR>
" Navigation
nnoremap <C-j> 10j
nnoremap <C-k> 10k
noremap <expr>0 col('.') == 1 ? '^': '0'
nnoremap <C-c>h :tabp <CR>
nnoremap <C-c>l :tabn <CR>
nnoremap <left> :tabp <CR>
nnoremap <right> :tabn <CR>
inoremap <left> <ESC> :tabp <CR>
inoremap <right> <ESC> :tabn <CR>
nnoremap <silent> <leader>b :call GoToBufferN()<CR>
nnoremap <silent> <leader>t :call GoToTabN()<CR>
" Arrows are not suggested
nnoremap <up> <nop>
nnoremap <down> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
" Spell check
nnoremap <leader>sf 1z=
nnoremap <leader>ss :set spell!<CR>
autocmd BufRead,BufNewFile * :call IgnoreCustomItems()
" Copy & paste
noremap <leader>y "*y
noremap <leader>p "*p
" Search
nnoremap / /\v
vnoremap / /\v
" Jump to next tag
inoremap <C-f> <ESC>vit<ESC>i


" View

" Color
set number
set relativenumber
set colorcolumn=80
set cursorline
set t_Co=256
set background=dark
set laststatus=2
colorscheme nord
hi Normal guibg=NONE ctermbg=NONE
hi TabLineFill guibg=NONE ctermfg=NONE ctermbg=NONE
" Airline
let g:airline_theme='nord'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#virtualenv#enabled = 1
let g:airline#extensions#ycm#enabled = 1


" Ycm & Syntastic settings

nnoremap <silent> <leader>gf :YcmCompleter Format<CR>
nnoremap <silent> <leader>gd :YcmCompleter GoToDefinition<CR>
nnoremap <silent> <leader>gt :YcmCompleter GetType<CR>
nnoremap <silent> <leader>gi :YcmCompleter GoToInclude<CR>
nnoremap <silent> <leader>gr :YcmCompleter GoToReferences<CR>
nnoremap <silent> <leader>gp :call TogglePreview()<CR>
nnoremap <silent> <leader>sr :YcmRestartServer<CR>
nnoremap <silent> <leader>sd :YcmShowDetailedDiagnostic<CR>
nnoremap <silent> <leader>sl :call ToggleErrors()<CR>
nnoremap <silent> <leader>sk :call DoSyntasticCheck()<CR>
nnoremap <silent> <leader>sn :SyntasticReset<CR>

set completeopt=menuone,menu
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_semantic_triggers =  {
            \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
            \ 'rust': ['re!\w{2}'],
            \ }
let g:syntastic_mode_map = {
    \ "mode": "passive",
    \ "active_filetypes": [],
    \ "passive_filetypes": [] }


" Snippet
let g:UltiSnipsExpandTrigger = '<C-l>'


" Code format
"let g:formatterpath = [
    "\ '~/.pyenv/versions/nvim/bin/black',
    "\ ]
let g:autoformat_verbosemode=1
let g:formatdef_black = '"~/.pyenv/versions/nvim/bin/black -S -q ".(&textwidth ? "-l".&textwidth : "")." -"'
let g:formatters_python = ['black']


" NERDTree, Git, ctrlsf & Tagbar
" NERDTree
let NERDTreeWinPos = 'right'
nnoremap <leader>e :NERDTreeToggle<CR>
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
" Git
set updatetime=100
let g:gitgutter_highlight_linenrs = 1
" CtrlSF
let g:ctrlsf_ignore_dir = ['tags.d']
" Tagbar
let tagbar_left = 1
let tagbar_width = 32
let g:tagbar_compact=1
nmap <leader>w :TagbarToggle<CR>
let g:tagbar_type_cpp = {
    \ 'kinds' : [
         \ 'c:classes:0:1',
         \ 'd:macros:0:1',
         \ 'e:enumerators:0:0', 
         \ 'f:functions:0:1',
         \ 'g:enumeration:0:1',
         \ 'l:local:0:1',
         \ 'm:members:0:1',
         \ 'n:namespaces:0:1',
         \ 'p:functions_prototypes:0:1',
         \ 's:structs:0:1',
         \ 't:typedefs:0:1',
         \ 'u:unions:0:1',
         \ 'v:global:0:1',
         \ 'x:external:0:1'
     \ ],
     \ 'sro'        : '::',
     \ 'kind2scope' : {
         \ 'g' : 'enum',
         \ 'n' : 'namespace',
         \ 'c' : 'class',
         \ 's' : 'struct',
         \ 'u' : 'union'
     \ },
     \ 'scope2kind' : {
         \ 'enum'      : 'g',
         \ 'namespace' : 'n',
         \ 'class'     : 'c',
         \ 'struct'    : 's',
         \ 'union'     : 'u'
     \ }
 \ }



" C/C++

" Set files as C files
augroup project
    autocmd!
    autocmd BufRead,BufNewFile *.h,*.c set filetype=c.doxygen
augroup END
" Highlight
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_concepts_highlight = 1


" Python
" Highlight and checker of syntastic, all other stuffs are originated from jedi

let g:python_highlight_all = 1
let syntastic_python_checkers = ['pylint']

autocmd FileType python let b:syntastic_python_flake8_args =
    \ get(g:, 'syntastic_python_flake8_args', '') .
    \ FindConfig('-c', '.flake8', expand('%:p:h'))
    "\ FindConfig('-c', 'tox.ini', expand('%:p:h'))
    "\ FindConfig('-c', 'setup.cfg', expand('%:p:h'))


" Front Development

let g:user_emmet_leader_key = '<C-x>'
let g:bracey_server_port = 34911
let g:bracey_server_allow_remote_connections = 1
let g:bracey_refresh_on_save = 1
let g:bracey_eval_on_save = 1
let g:bracey_auto_start_server = 1

" Markdown

let g:vim_markdown_folding_level = 3
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_autowrite = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_no_extensions_in_markdown = 1
let g:mkdp_port = '34910'
let g:mkdp_refresh_slow = 1
let g:mkdp_open_to_the_world = 1
let g:mkdp_echo_preview_url = 1
noremap <leader>mp :MarkdownPreview<CR>
noremap <leader>ms :MarkdownPreviewStop<CR>
"noremap <leader>mt :MarkdownPreviewToggle<CR> E492: Not an editor command


" Functions

function! DoSyntasticCheck()
    if &filetype == 'python'
        SyntasticCheck
    else
        YcmForceCompileAndDiagnostics
    endif
endfunction

function! ToggleErrors()
    if empty(filter(tabpagebuflist(), 'getbufvar(v:val, "&buftype") is# "quickfix"'))
        " No location/quickfix list shown, open syntastic error location panel
        " Nothing was closed, open syntastic error location panel
        Errors
    else
        lclose
    endif
endfunction

function! FindConfig(prefix, what, where)
    let cfg = findfile(a:what, fnameescape(a:where) . ';')
    return cfg !=# '' ? ' ' . a:prefix . ' ' . shellescape(cfg) : ''
endfunction

function! PreviewWindowOpened()
    for nr in range(1, winnr('$'))
        if getwinvar(nr, '&pvw') == 1
            return 1
        endif
    endfor
endfunction

function! TogglePreview()
    if PreviewWindowOpened()
        pclose
    else
        YcmCompleter GetDoc
    endif
endfunction

function! IgnoreCustomItems()
    syn match CamelCase0 /\<[A-Z][a-z]\+[A-Z].\{-}\>/ contains=@NoSpell transparent
    syn match CamelCase1 /\<[a-z]\+[A-Z].\{-}\>/ contains=@NoSpell transparent
    syn match SnakeCase0 /\<\w*_\+\w\+\>/ contains=@NoSpell transparent
    syn match UpperCase /\<[A-Z0-9]\+\>/ contains=@NoSpell transparent
    syn match ShortWord /\<\w\{1,4}\>/ contains=@NoSpell transparent
    syn cluster Spell add=CamelCase0
    syn cluster Spell add=CamelCase1
    syn cluster Spell add=SnakeCase0
    syn cluster Spell add=ShortWord
    syn cluster Spell add=UpperCase
endfunction

fun! GoToBufferN()
    " If typed char is 'l', list all buffers;
    " if is's a <number>, go to buffer <number>
    let l:chr = getchar()
    let l:n = l:chr - 48
    if l:chr == 108
        execute 'buffers'
    "elseif l:chr == 98
        "execute ''
    elseif 0 < l:n && l:n < 10
        execute 'buffer '.(l:n)
    else
        echo "Only support input [1-9] and char 'l'\n"
    endif
endfun

fun! GoToTabN()
    " If typed char is 'l', list all tabs;
    " if is's a <number>, go to tab <number>
    let l:chr = getchar()
    let l:n = l:chr - 48
    if l:chr == 108
        execute 'tabs'
    elseif 0 < l:n && l:n < 10
        execute 'normal! '.(l:n).'gt'
    else
        echo "Only support input [1-9] and char 'l'\n"
    endif
endfun

