" Plug Settings -- {{{
"call plug#begin(stdpath('data').'/plugged')
call plug#begin('~/.local/share/nvim/data/plugged')

Plug 'neoclide/coc.nvim', {'branck': 'master', 'do': 'yarn install --frozen-lockfile'}

Plug 'vim-syntastic/syntastic'

" Navigation & developing support
" File & sign navigator
Plug 'majutsushi/tagbar'
Plug 'preservim/nerdtree'
" Commenter & git utils
Plug 'tomtom/tcomment_vim'
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
" Session manager
Plug 'mhinz/vim-startify'

" View
" Color schemes
Plug 'arcticicestudio/nord-vim'
Plug 'sonph/onehalf', {'rtp': 'vim'}
Plug 'morhetz/gruvbox'
Plug 'mhinz/vim-janah'
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
Plug 'leafOfTree/vim-vue-plugin'
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
set runtimepath+=~/.local/share/nvim
set runtimepath+=~/.local/share/nvim
let &packpath = &runtimepath

" Terminal settings

" Exit tmode
tnoremap <Esc> <C-\><C-n>
tnoremap jk <C-\><C-n>
tnoremap Jk <C-\><C-n>
tnoremap JK <C-\><C-n>

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
set hidden
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
set autoread
set guicursor+=n:blinkon300-nCursor,i:hor50-blinkon300
if has("autocmd")
    " Jump to the line viewed at last time
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    " Reload file every time the cursor get into a buffer
    autocmd FocusGained,BufEnter * :silent! !
    " Disable line breaking in markdown file
    autocmd BufNewFile,BufRead,BufEnter *.md set textwidth=0
endif

" Persistent undo
let g:undo_path = fnamemodify(expand($MYVIMRC), ':h') . '/undo'
if !isdirectory(g:undo_path)
    call system('mkdir -p ' . g:undo_path)
endif
set undofile
execute 'set undodir=' . g:undo_path

set undolevels=1000
set undoreload=10000
" }}}


" Global key mappings -- {{{

let mapleader = " "
" Vimrc
nnoremap <leader>vs :vsplit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>
" Editting
inoremap jk <ESC>
inoremap Jk <C-\><C-n>
inoremap JK <C-\><C-n>
inoremap jjk jk

inoremap <C-e> <Esc>A
inoremap <C-j> <Esc>o
inoremap <C-k> <Esc>O
nnoremap <leader>] <C-w><C-]><C-w>T
nnoremap <leader>WW :w<CR>
nnoremap <leader>WQ :wq<CR>
nnoremap <leader>QQ :q<CR>
nnoremap QQ :q<CR>
nnoremap <silent> <leader>pp :set paste!<CR>
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
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

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
nnoremap <leader>sw 1z=
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
" Edit current tag
nnoremap <leader>i vit<Esc>i
" Abbreviations
iabbrev @@ suidar@foxmail.com
iabbrev ccp Copyright 2020 Hugh Young, all rights reserved.
" }}}


" View and Airline/ indentLine plugin settings -- {{{

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
highlight Identifier guifg=#8FBCBB
highlight Constant guifg=#8FBCBB
" Set signs column's color the same as bg
execute 'hi GitGutterAdd    guifg=' . g:terminal_color_10 . ' ctermfg=2'
execute 'hi GitGutterChange guifg=' . g:terminal_color_14 . ' ctermfg=3'
execute 'hi GitGutterDelete guifg=' . g:terminal_color_9  . ' ctermfg=1'
execute 'hi SignColumn guibg=' . g:terminal_color_0
" Hide (~) at the end of buffer
highlight NonText guifg=bg
" Cursor stuff
highlight CursorLineNr guifg=white
highlight nCursor guifg=white guibg=black gui=reverse

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
" This command will enforce the background to be dark not matter what color
" scheme is set
"hi Normal guibg=NONE ctermbg=NONE
"hi TabLineFill guibg=NONE ctermfg=NONE ctermbg=NONE
" Airline
let g:airline_theme='gruvbox'
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#tab_nr_type = 1 " # of splits (default)
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_tab_count = 0
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#virtualenv#enabled = 1
let g:airline#extensions#ycm#enabled = 1

" indentLine
let g:indentLine_enabled = 0
augroup indent_launch
    autocmd!
    autocmd FileType * IndentLinesEnable
augroup END
" }}}


" Coc.nvim -- {{{


" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" Code edit
nmap <silent> <leader>gd <Plug>(coc-definition)
nmap <silent> <leader>gt <Plug>(coc-type-definition)
nmap <silent> <leader>gi <Plug>(coc-implementation)
nmap <silent> <leader>gr <Plug>(coc-references)
xmap <leader>gf  <Plug>(coc-format-selected)
nmap <leader>gf  <Plug>(coc-format-selected)
nnoremap <silent> K :call <SID>show_documentation()<CR>
" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>ac  <Plug>(coc-codeaction)
" Quick fix
nmap <leader>qf  <Plug>(coc-fix-current)
" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <leader>cd  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <leader>cx  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <leader>cl  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <leader>co  :<C-u>CocList outline<cr>
" Search workspace symbols.
noremap <silent><nowait> <leader>cs  :<C-u>CocList -I symbols<cr>
" Resume latest coc list.
nnoremap <silent><nowait> <leader>cp  :<C-u>CocListResume<CR>

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

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


" NERDTree, Git, ctrlsf, startify & Tagbar
" NERDTree
let NERDTreeWinPos = 'right'
nnoremap <leader>e :NERDTreeToggle<CR>
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
" Git
set updatetime=100
let g:gitgutter_enabled = 0
" <leader>h is used to switch split, while <leader>h* is used in gitgutter,
" which leads to unacceptable delay when pressing <leader>h, thus gitggutter key
" mappings are disabled and re-mapped.
let g:gitgutter_map_keys = 0
nnoremap <silent> <leader>gg :GitGutterToggle<CR>
nnoremap <silent> ]c :GitGutterNextHunk<CR>
nnoremap <silent> [c :GitGutterPrevHunk<CR>
" CtrlSF
let g:ctrlsf_ignore_dir = [
            \ 'tags', 
            \ 'tags.d', 
            \ '*.log', 
            \ 'tsconfig.json',
            \ 'node_module', 
            \ 'static', 
            \ 'dist',
            \ '.vscode',
            \ '.ycm_extra_conf.py',
            \ ]
nnoremap <leader>sf :CtrlSF 
" Startify
let g:startify_session_before_save = [
            \ 'execute bufname() =~ "^NERD_tree_." ? ":NERDTreeClose" : ""',
            \ 'let g:startify_tmp_tabpagenr = tabpagenr()',
            \ 'let g:startify_tmp_winnr = winnr()',
            \ 'echo "Cleaning up before saving.."',
            \ 'silent! tabdo NERDTreeClose',
            \ 'execute "normal! " . g:startify_tmp_tabpagenr . "gt"',
            \ 'execute g:startify_tmp_winnr . "wincmd w"'
            \ ]
autocmd VimEnter *
            \   if !argc()
            \ |   Startify
            \ |   NERDTree
            \ |   wincmd w
            \ | endif
" Tagbar
let tagbar_left = 1
let tagbar_width = 32
let g:tagbar_compact=1
let g:tagbar_sort = 0
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
    autocmd BufRead,BufNewFile *.h,*.c,*.cpp set sw=2
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

" Recommanded by coc-css
autocmd FileType scss setl iskeyword+=@-@
" vim-vue-plugin
let g:vim_vue_plugin_use_less = 1
let g:vim_vue_plugin_use_sass = 1
let g:vim_vue_plugin_use_scss = 1
let g:vim_vue_plugin_use_stylus = 1
let g:vim_vue_plugin_highlight_vue_attr = 1
let g:vim_vue_plugin_highlight_vue_keyword = 1
"autocmd BufRead,BufNewFile *.js,*jsx set filetype=javascript
"autocmd BufRead,BufNewFile *.ts,*tsx set filetype=typescript

let g:user_emmet_leader_key = '<C-x>'
let g:bracey_server_port = 34911
let g:bracey_server_allow_remote_connections = 1
let g:bracey_refresh_on_save = 1
let g:bracey_eval_on_save = 1
let g:bracey_auto_start_server = 1
augroup html_indent
    autocmd!
    autocmd FileType javascript,css,vue,html,typescript,javascriptreact,typescriptreact set shiftwidth=2
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
