" Plug Settings -- {{{
"call plug#begin(stdpath('data').'/plugged')
call plug#begin('~/.local/share/nvim/data/plugged')

Plug 'junegunn/vim-plug'
Plug 'neoclide/coc.nvim', {
            \ 'branck': 'master',
            \ 'do': ':call CocHook()',
            \ }

" Navigation & developing support
" File & sign navigator
Plug 'majutsushi/tagbar'
Plug 'preservim/nerdtree'
" Commenter & git utils
Plug 'tomtom/tcomment_vim'
Plug 'airblade/vim-gitgutter', { 'on': 'GitGutterToggle' }
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
Plug 'junegunn/fzf', { 'do': { -> fzf#install() }}
Plug 'junegunn/fzf.vim'
" Global finder
Plug 'brooth/far.vim'
Plug 'dyng/ctrlsf.vim'
" Session manager
Plug 'mhinz/vim-startify'

" View
" Color schemes
Plug 'arcticicestudio/nord-vim'
Plug 'sonph/onehalf', { 'rtp': 'vim/' }
Plug 'morhetz/gruvbox'
Plug 'mhinz/vim-janah'
Plug 'joshdick/onedark.vim'
" Status / tabline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Indentation line
Plug 'Yggdroot/indentLine'

" Language supports
Plug 'sheerun/vim-polyglot'
Plug 'octol/vim-cpp-enhanced-highlight', { 'for': ['cpp', 'c'] }
" Font-end tool chain
Plug 'ap/vim-css-color', { 'for': [ 'css', 'less', 'scss', 'tsx', 'ts', 'vim', 'tmux', ] }
" Plug 'posva/vim-vue', { 'for': 'vue' }
Plug 'HerringtonDarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty', { 'for': [ 'tsx', 'jsx', ] }
" Go commands
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" Html preview
Plug 'turbio/bracey.vim', { 'for': [ 'html', ] }
" Markdown syntax and preview
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown', { 'for': [ 'markdown', ] }
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': [ 'markdown', 'vim-plug', ] }
" Python utils // The indent really saved my life
" Plug 'Vimjas/vim-python-pep8-indent', { 'for': [ 'python', ] }
Plug 'jmcantrell/vim-virtualenv', { 'for': [ 'python', ] }
" Plug 'vim-python/python-syntax', { 'for': [ 'python', ] }
" Asm
Plug 'Shirk/vim-gas', { 'for': 'asm' }
Plug 'cespare/vim-toml', { 'for': [ 'toml', ] }

" Other utilities
Plug 'mhinz/vim-rfc'
Plug 'vim-scripts/Drawit'
Plug 'voldikss/vim-translator'

call plug#end()

autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif

" function! s:plug_gx()
"   let line = getline('.')
"   echo 'line: ' . line
"   let sha  = matchstr(line, '^  \X*\zs\x\{7,9}\ze ')
"   echo 'sha: ' . sha
"   let name = empty(sha) ? matchstr(line, '^[-x+] \zs[^:]\+\ze:')
"                       \ : getline(search('^- .*:$', 'bn'))[2:-2]
"   let uri  = get(get(g:plugs, name, {}), 'uri', '')
"   echo 'uri: ' . uri
"   if uri !~ 'github.com'
"     return
"   endif
"   let repo = matchstr(uri, '[^:/]*/'.name)
"   echo 'repo: ' . repo
"   let url  = empty(sha) ? 'https://github.com/'.repo
"                       \ : printf('https://github.com/%s/commit/%s', repo, sha)
"   echo 'url: ' . url
"   call netrw#BrowseX(url, 0)
" endfunction
let g:netrw_browsex_viewer = "cmd.exe /C start"
function! Lite_gx()
    let line = getline('.')
    let url = ''
    if stridx(line, 'Plug') != 0
        let url = matchstr(line, '\S*://\(\S\|\.\)*')
    else
        let url = 'https://github.com/' . matchlist(getline('.'), 'Plug\s\s*''\(.*\)''')[1]
    endif
    if strlen(url) != 0
        call netrw#BrowseX(url, 0)
    endif
endfunction

" augroup PlugGx
"   autocmd!
"   autocmd FileType vim-plug nnoremap <buffer> <silent> gx :call <sid>plug_gx()<cr>
" augroup END

" nnoremap <buffer> <silent> gx :call <sid>plug_gx()<cr>
nnoremap <silent> gx :call Lite_gx()<cr>

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

syntax on
filetype plugin indent on
set wrap
set ruler
set hidden
if (has('termguicolors'))
    set termguicolors
endif
if has('unix') || has('macunix')
    set shell=/bin/zsh
endif

set hlsearch
set incsearch

set showmatch
set textwidth=80
set encoding=utf-8
set spelllang=en_us,cjk
set conceallevel=2
set clipboard+=unnamed
set noswapfile
" Under Wsl environment
if has('windows') && has('unix')
    let g:clipboard = {
              \   'name': 'win32yank-wsl',
              \   'copy': {
              \      '+': 'win32yank.exe -i --crlf',
              \      '*': 'win32yank.exe -i --crlf',
              \    },
              \   'paste': {
              \      '+': 'win32yank.exe -o --lf',
              \      '*': 'win32yank.exe -o --lf',
              \   },
              \   'cache_enabled': 0,
              \ }
endif
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
set formatoptions+=jn
if has('autocmd')
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

set ttimeout
set ttimeoutlen=100
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
nnoremap <leader>i vit<Esc>i

inoremap <C-e> <Esc>A
inoremap <C-j> <Esc>o
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
noremap <expr>0 col('.') == 1 ? '^': '0'
nnoremap <C-j> 15j
nnoremap <C-k> 15k
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>
nnoremap <C-c>h :tabp <CR>
nnoremap <C-c>l :tabn <CR>
nnoremap <left> :tabp <CR>
nnoremap <right> :tabn <CR>
inoremap <left> <ESC> :tabp <CR>
inoremap <right> <ESC> :tabn <CR>
nnoremap <C-l> :tabn<CR>
nnoremap <C-h> :tabp<CR>
tnoremap <C-l> <C-\><C-n>:tabn<CR>
tnoremap <C-h> <C-\><C-n>:tabp<CR>
nnoremap <silent> <leader>tl :tabs<CR>
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l
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
" Adaption for easymotion
nmap <silent> F <Plug>(easymotion-f)
nmap <silent> T <Plug>(easymotion-t)
nmap <silent> <leader>W <Plug>(easymotion-w)
nmap <silent> <leader>B <Plug>(easymotion-b)
nmap <silent> <leader>J <Plug>(easymotion-j)
nmap <silent> <leader>K <Plug>(easymotion-k)

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
nnoremap <silent> <leader>ch :so $VIMRUNTIME/syntax/hitest.vim<CR>
" Translate
nnoremap <silent> <leader>tr :Translate<CR>
" }}}


" View and Airline / indentLine plugin settings -- {{{

" Color
set number
set relativenumber
set colorcolumn=80
set cursorline
set t_Co=256
set background=dark
set laststatus=2
" If it is gruvbox, set signs column's color the same as bg
let g:gruvbox_sign_column='bg0'
colorscheme gruvbox
let g:_color = get(g:, 'colors_name', 'default') 
if g:_color == 'janah'
    highlight LineNr guifg=#878787 ctermfg=102 guibg=#262626 ctermbg=237 gui=NONE cterm=NONE
    highlight CursorLineNr guifg=#878787 ctermfg=102 guibg=#303030 ctermbg=237 gui=NONE cterm=NONE
    highlight SignColumn ctermfg=NONE guibg=#262626 ctermbg=237 gui=NONE cterm=NONE
    highlight GitGutterAdd guifg=#87dfdf ctermfg=119 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
    highlight GitGutterDelete guifg=#df5f5f ctermfg=167 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
    highlight GitGutterChange guifg=#ffff5f ctermfg=227 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
    highlight GitGutterText guifg=#ff5f5f ctermfg=203 guibg=#5f0000 ctermbg=52 gui=bold cterm=bold
elseif g:_color == 'gruvbox'
    " These 2 colors of nord theme are quite suitable to gruvbox
    highlight Identifier guifg=#8FBCBB
    highlight Constant guifg=#8FBCBB
endif
if g:_color != 'janah'
    highlight EndOfBuffer ctermbg=bg ctermfg=bg guibg=bg guifg=bg
endif
" Hide (~) at the end of buffer
highlight NonText guifg=bg
function! CheckColorGroup()
    return map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction

" Airline
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
let g:indentLine_leadingSpaceChar = '·'
let g:indentLine_leadingSpaceEnabled = 1
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
if has('nvim-0.5.0') || has('patch-8.1.1564')
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
" Restart coc service
nnoremap <silent><nowait> <leader>sr  :<C-u>CocRestart<CR>

augroup CocGroup
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
" Cure linter madness caused by vim-easymotion
autocmd User EasyMotionPromptBegin silent! CocDisable
autocmd User EasyMotionPromptEnd silent! CocEnable
" }}}


" Plugin Settings -- {{{


" Snippet
let g:UltiSnipsExpandTrigger = '<C-l>'

" NERDTree, Git, ctrlsf, startify & Tagbar
" NERDTree
let NERDTreeWinPos = 'right'
let NERDTreeIgnore = ['.*\.swp']
let NERDTreeShowHidden = 1
nnoremap <silent> <leader>e :NERDTreeToggle<CR>
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
let g:startify_session_persistence = 1
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
let g:typescript_use_builtin_tagbar_defs = 0
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
au FileType python let b:coc_root_patterns = [
    \ '.git',
    \ '.env',
    \ 'venv',
    \ '.venv',
    \ 'setup.cfg',
    \ 'setup.py',
    \ 'pyrightconfig.json',
    \ '.python-version',
    \ ]
let g:python_highlight_all = 1

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
    autocmd FileType javascript,css,less,vue,html,typescript,javascriptreact,typescriptreact set shiftwidth=2
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

function! CocHook()
    !npm install --frozen-lockfile
    !npm run build
    :CocInstall coc-go coc-pyright coc-rls coc-json coc-vetur coc-html coc-tsserver coc-cmake coc-sh coc-css coc-cssmodules coc-clangd coc-rust-analyzer
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
