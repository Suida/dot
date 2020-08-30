" Plug Settings -- {{{
call plug#begin(stdpath('data').'/plugged')

Plug 'ycm-core/YouCompleteMe', { 'do': './install.py --ts-completer --clang-completer' }
Plug 'ycm-core/lsp-examples', { 'do': './vue/install.py' }
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
" Better Performance
Plug 'Konfekt/FastFold'

" Fuzzy finer
Plug 'junegunn/fzf', { 'do': 'yes \| ./install' }
" Global finder
Plug 'brooth/far.vim'
Plug 'dyng/ctrlsf.vim'

" View
" Color schemes
Plug 'arcticicestudio/nord-vim'
Plug 'sonph/onehalf', {'rtp': 'vim'}
Plug 'morhetz/gruvbox'
" Status / tabline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Indentation line
Plug 'Yggdroot/indentLine'

" Language support
Plug 'Chiel92/vim-autoformat'
Plug 'octol/vim-cpp-enhanced-highlight'
" Font-end tool chain
Plug 'ap/vim-css-color'
Plug 'posva/vim-vue'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty'
" Go commands
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" Html preview
Plug 'turbio/bracey.vim'
" Markdown syntax and preview
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" Python utils // The indent really saved my life
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'jmcantrell/vim-virtualenv'
Plug 'vim-python/python-syntax'

call plug#end()
" }}}


" Origin init.vim -- {{{
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
if has('unix') || has('macunix')
    let g:python3_host_prog="~/.pyenv/versions/nvim/bin/python"
endif
" }}}


" Specify the default .vimrc file as the one under working directory -- {{{

set exrc
set secure
" }}}


" Basics -- {{{

if (has("termguicolors"))
    set termguicolors
endif
syntax on
filetype plugin indent on
if has('unix') || has('macunix')
    set shell=/bin/zsh
endif
set wrap
set ruler
set hlsearch
set incsearch
set showmatch
set shiftround
set textwidth=80
set encoding=utf-8
set clipboard=unnamedplus
set spelllang=en_us,cjk
set conceallevel=2
" Indentation rules and folding
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set foldmethod=marker
set nofoldenable
set autoindent
set backspace=indent,eol,start
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
" }}}


" Global key mappings -- {{{

let mapleader = " "
" Vimrc
nnoremap <leader>vs :vsplit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>
" Editting
inoremap jk <ESC>
inoremap <C-e> <Esc>A
inoremap <C-j> <Esc>o
inoremap <C-k> <Esc>O
nnoremap <leader>] <C-w><C-]><C-w>T
nnoremap <leader>WW :w<CR>
nnoremap <leader>WQ :wq<CR>
nnoremap <leader>QQ :q<CR>
nmap <leader>gb ysiw}lysiw{
nmap <silent> <leader>ft :TableFormat<CR>
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
nnoremap <silent> <leader>tl :tabs<CR>
nnoremap <silent> - :m .+1<CR>
nnoremap <silent> _ :m .-2<CR>
tnoremap <silent> <C-w> <C-\><C-n><C-w>
nnoremap <C-l> :tabn<CR>
nnoremap <C-h> :tabp<CR>
tnoremap <C-l> <C-\><C-n>:tabn<CR>
tnoremap <C-h> <C-\><C-n>:tabp<CR>
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l
" Command
nnoremap ! :!
" Arrows are not suggested
nnoremap <up> <nop>
nnoremap <down> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
" Spell check
nnoremap <leader>sf 1z=
nnoremap <leader>ss :set spell!<CR>
" The reason why highlights disapeared is just this command
" This was introduced to fix unnecessary spell checking highlights, which is
" useless now, so it is commented out.
"autocmd BufRead,BufNewFile * :call IgnoreCustomItems()
" Copy & paste
noremap <leader>y "*y
noremap <leader>p "*p
" Search
nnoremap / /\v
vnoremap / /\v
" Jump to next tag
inoremap <C-f> <ESC>vit<ESC>i
nnoremap <leader>i vit<Esc>i
" Abbreviations
iabbrev @@ suidar@foxmail.com
iabbrev ccp Copyright 2020 Hugh Young, all rights reserved.
" }}}


" View and Airline plugin settings -- {{{

" Color
set number
set relativenumber
set colorcolumn=80
set cursorline
set t_Co=256
set background=dark
set laststatus=2
colorscheme gruvbox
" These 2 colors of nord theme are quite suitable to gruvbox
hi Identifier guifg=#8FBCBB
hi Constant guifg=#8FBCBB
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
" This command will force the background to be dark not matter what color
" scheme is set
"hi Normal guibg=NONE ctermbg=NONE
"hi TabLineFill guibg=NONE ctermfg=NONE ctermbg=NONE
" Airline
let g:airline_theme='gruvbox'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#virtualenv#enabled = 1
let g:airline#extensions#ycm#enabled = 1
" }}}


" Ycm & Syntastic settings -- {{{

let s:lsp = '~/.local/share/nvim/plugged/lsp-examples'

nnoremap <silent> <leader>gf :call FormatCode()<CR>
nnoremap <silent> <leader>gd :YcmCompleter GoToDefinition<CR>
nnoremap <silent> <leader>gt :YcmCompleter GetType<CR>
nnoremap <silent> <leader>gi :YcmCompleter GoToInclude<CR>
nnoremap <silent> <leader>gr :YcmCompleter GoToReferences<CR>
nnoremap <silent> <leader>gx :YcmCompleter FixIt<CR>
nnoremap <silent> <leader>gp :call TogglePreview()<CR>
nnoremap <silent> <leader>sr :YcmRestartServer<CR>
nnoremap <silent> <leader>sd :YcmShowDetailedDiagnostic<CR>
nnoremap <silent> <leader>sl :call ToggleErrors()<CR>
nnoremap <silent> <leader>sk :call SyntaxCheck()<CR>
nnoremap <silent> <leader>sn :SyntasticReset<CR>

set completeopt=menuone,menu
let g:ycm_confirm_extra_conf = 0
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_always_populate_location_list = 1
"let g:ycm_key_invoke_completion = '<C-Space>'
"let g:ycm_log_level = 'debug'
let g:ycm_semantic_triggers =  {
            \ 'c,cpp,c.doxygen,python,java,go,erlang,perl': ['re!\w{2}'],
            \ 'rust': ['re!\w{2}'],
            \ 'javascript,typescript': ['re!\w{2}'],
            \ 'javascriptreact,typescriptreact': ['re!\w{2}'],
            \ }
let g:ycm_language_server = [
            \ {
            \   'name': 'vue',
            \   'filetypes': [ 'vue' ],
            \   'cmdline': [ expand( s:lsp . '/vue/node_modules/.bin/vls' ) ]
            \ },
            \ {
            \   'name': 'vim',
            \   'filetypes': [ 'vim' ],
            \   'cmdline': [ expand( s:lsp . '/viml/node_modules/.bin/vim-language-server' ), '--stdio' ]
            \ },
            \ ]
let g:syntastic_mode_map = {
    \ "mode": "passive",
    \ "active_filetypes": [],
    \ "passive_filetypes": [] }
" }}}


" Plugin Settings -- {{{


" Snippet
let g:UltiSnipsExpandTrigger = '<C-l>'


" Code format
let g:python_bin_dir = '/' . join(split(expand(g:python3_host_prog), '/')[0:-2], '/') . '/'
let g:autoformat_verbosemode=1
let g:formatdef_black =  '"' . g:python_bin_dir . 'black -S -q ".(&textwidth ? "-l".&textwidth : "")." -"'
"let g:formatdef_black = '"~/.pyenv/versions/nvim/bin/black -S -q ".(&textwidth ? "-l".&textwidth : "")." -"'
let g:formatters_python = ['black']
let g:formatdef_prettier = '"~/.nvm/versions/node/v12.18.2/bin/prettier --parser vue"'
let g:formatters_vue = ['prettier']


" NERDTree, Git, ctrlsf & Tagbar
" NERDTree
let NERDTreeWinPos = 'right'
nnoremap <leader>e :NERDTreeToggle<CR>
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
" Git
set updatetime=100
let g:gitgutter_highlight_linenrs = 1
let g:gitgutter_map_keys = 0
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
" }}}


" Language Settings -- {{{

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


" Go
let g:go_code_completion_enabled = 0
let g:go_test_show_name = 1


" Python
" Highlight and checker of syntastic, all other stuffs are originated from jedi
let g:python_highlight_all = 1
let syntastic_python_checkers = ['pylint']

augroup pythonAutocmd
    autocmd!
    autocmd FileType python let b:syntastic_python_flake8_args =
        \ get(g:, 'syntastic_python_flake8_args', '') .
        \ FindConfig('-c', '.flake8', expand('%:p:h'))
        "\ FindConfig('-c', 'tox.ini', expand('%:p:h'))
        "\ FindConfig('-c', 'setup.cfg', expand('%:p:h'))
    " Highlight python constant
    autocmd FileType python :call HighlightUpperCaseCamel()
augroup END


" Front Development

let g:front_end_filetypes = {
            \ "javascript": 1,
            \ "typescript": 1,
            \ "html": 1,
            \ "css": 1,
            \ "stylus": 1,
            \ "less": 1,
            \ "scss": 1,
            \ "vue": 1,
            \ "json": 1,
            \ }

"autocmd BufRead,BufNewFile *.js,*jsx set filetype=javascript
"autocmd BufRead,BufNewFile *.ts,*tsx set filetype=typescript
autocmd FileType javascript,css,vue,html,typescript,javascriptreact,typescriptreact set shiftwidth=2

let g:user_emmet_leader_key = '<C-x>'
let g:bracey_server_port = 34911
let g:bracey_server_allow_remote_connections = 1
let g:bracey_refresh_on_save = 1
let g:bracey_eval_on_save = 1
let g:bracey_auto_start_server = 1
augroup html_indent
    autocmd!
    autocmd FileType html,javascript,vue set shiftwidth=2
augroup END


" Markdown
let g:vim_markdown_folding_level = 1
let g:vim_markdown_folding_disabled = 1
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
" }}}


" Functions -- {{{

function! FormatCode()
    if &filetype == 'python'
        Autoformat
    elseif &filetype == 'vue'
        Autoformat
        "call FormatVue()
    else
        YcmCompleter Format
    endif
endfunction

function! FormatVue()
    let s:lines = nvim_buf_get_lines(buffer_number('%'), 0, -1, 1)
    let s:lines = split(system('prettier --parser vue', join(s:lines, "\n")), "\n")
    call nvim_buf_set_lines(buffer_number('%'), 0, -1, 0, s:lines)
    echo "Format succeed!"
endfunction

function! SyntaxCheck()
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

function! HighlightUpperCaseCamel()
    " Python constants are always written as identifiers only containing upper
    " case charactors, numbers and underscores.
    syn match pythonUpperCamel '\<[A-Z_]\+[A-Z0-9_]\+\>' display
    highlight def link pythonUpperCamel Constant
endfunction
" }}}


" Folding Setting ----------------------- {{{
augroup filtype_vim
    autocmd!
    autocmd FileType vim setlocal foldenable
    autocmd FileType vim setlocal foldlevel=0
    autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}
