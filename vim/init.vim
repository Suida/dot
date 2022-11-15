" Plug Settings -- {{{

" Install vim-plug if not found
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
  \| call plug#helptags()
\| endif

function! LoadLuaConf(name)
    exe 'luafile ' . stdpath('config') . '/' . a:name . '.lua'
endfunction

call plug#begin(stdpath('data') . '/plugged')
Plug 'junegunn/vim-plug'
Plug 'neoclide/coc.nvim', {
            \ 'branck': 'master',
            \ 'do': ':call CocHook()',
            \ }

" Navigation & developing support
" File, sign navigator & float terminal
Plug 'majutsushi/tagbar'
Plug 'voldikss/vim-floaterm'
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
" Marker
Plug 'kshenoy/vim-signature'

" Fuzzy finder
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
Plug 'joshdick/onedark.vim'
" Status / tabline
Plug 'itchyny/lightline.vim'
" Indentation line
Plug 'Yggdroot/indentLine'
Plug 'tpope/vim-sleuth'

" Language supports
" Plug 'sheerun/vim-polyglot'
Plug 'octol/vim-cpp-enhanced-highlight', { 'for': ['cpp', 'c'] }
" Font-end tool chain
Plug 'ap/vim-css-color', { 'for': [ 'css', 'less', 'scss', 'tsx', 'ts', 'vim', 'tmux', ] }
Plug 'HerringtonDarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty', { 'for': [ 'tsx', 'jsx', ] }
Plug 'posva/vim-vue'
" Html preview
Plug 'turbio/bracey.vim', { 'for': [ 'html', ] }
" Markdown syntax and preview
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': [ 'markdown', 'vim-plug', ] }
" Python utils // The indent really saved my life
Plug 'Vimjas/vim-python-pep8-indent', { 'for': [ 'python', ] }
Plug 'jmcantrell/vim-virtualenv', { 'for': [ 'python', ] }
" Plug 'vim-python/python-syntax', { 'for': [ 'python', ] }
" Asm
Plug 'Shirk/vim-gas', { 'for': 'asm' }
Plug 'cespare/vim-toml', { 'for': [ 'toml', ] }
" Latex
Plug 'lervag/vimtex'

" Other utilities
Plug 'mhinz/vim-rfc'
Plug 'editorconfig/editorconfig-vim'
Plug 'vim-scripts/Drawit'
Plug 'voldikss/vim-translator'
let g:vimspector_enable_mappings = 'HUMAN'
Plug 'puremourning/vimspector'

" Neovim only
if has('nvim')
    " Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python3 -m chadtree deps'}
    Plug 'kyazdani42/nvim-web-devicons' " optional, for file icons
    Plug 'kyazdani42/nvim-tree.lua'
else
    Plug 'preservim/nerdtree'
endif
" Plug 'suida/beacon.nvim'

call plug#end()
" }}}


" Origin init.vim -- {{{
" Terminal settings

" Exit tmode
tnoremap jk <C-\><C-n>
tnoremap Jk <C-\><C-n>
tnoremap JK <C-\><C-n>

" Ctrl+R
tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi'

" Provider
if has('unix') || has('macunix')
    let g:python3_host_prog="~/.pyenv/versions/nvim/bin/python"
    let g:coc_node_path = $FNM_MULTISHELL_PATH . '/bin/node'
    nnoremap <silent> <leader>tot :tabnew term://zsh<CR>
elseif has('win32')
    let g:python3_host_prog=expand('$PYENV_ROOT') . 'versions\nvim\Scripts\python.exe'
    if filereadable($NODE_PATH)
        let g:coc_node_path = $NODE_PATH
    else
        let g:coc_node_path = $FNM_MULTISHELL_PATH . '/node.exe'
    endif
    nnoremap <silent> <leader>tot :tabnew term://pwsh.exe<CR>
endif
" }}}


" Specify the default .vimrc file as the one under working directory -- {{{

set exrc
set secure
" }}}


" Basics -- {{{

syntax on
autocmd! bufreadpost *.svg set syntax=off
filetype plugin indent on
set wrap
set title 
set ruler
set hidden
set belloff=all
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
set concealcursor=
set clipboard+=unnamed
set noswapfile
set guicursor=n-v-c-sm:block-blinkwait300-blinkon500-blinkoff500-Cursor,i:hor20-blinkwait300-blinkon500-blinkoff500-Cursor
augroup guidetect
    autocmd VimEnter * call s:guisettings()
augroup END
function! s:guisettings()
    if has('nvim') && exists('g:GuiLoaded')
        GuiFont! CaskaydiaCove\ NF:h10
        GuiTabline 0
        GuiPopupmenu 0
    endif
endfunction
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
set expandtab
set foldmethod=marker
set nofoldenable
set autoindent
set backspace=indent,eol,start
set autoread
set formatoptions+=jn
augroup basic_prelaunch_settings
    " Jump to the line viewed at last time
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    " Reload file every time the cursor get into a buffer
    autocmd FocusGained,BufLeave * if bufname()!='[Command Line]' | checktime | endif
    " Disable line breaking in markdown file
    autocmd BufNewFile,BufRead,BufEnter *.md set textwidth=0
    autocmd GUIEnter * simalt ~x
augroup END

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
let maplocalleader = "  "
" Compatibility config for alacritty which dose not support control-space by
" default, where control-space is mapped to "\xb" (<ESC>) by myself, and here,
" <ESC> is remapped back to control-space to fit previous settings
imap <ESC> <C-space>

" Vimrc
nnoremap <leader>vs :vsplit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" Editting
inoremap jk <ESC>
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
noremap <expr>0 col('.') == 1 ? '^': '0'
noremap <expr>g0 col('.') == 1 ? '^': 'g0'
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
" Adaption for easymotion
nmap <silent> <leader>S <Plug>(easymotion-s)
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
" GUI Operations
noremap <M-Space>n :simalt ~n<CR>
noremap <M-Space>r :simalt ~r<CR>
noremap <M-Space>x :simalt ~x<CR>
inoremap <C-V> <C-R>+
cnoremap <C-V> <C-R>+
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
colorscheme onehalflight
" Hide (~) at the end of buffer
highlight NonText guifg=bg
highlight EndOfBuffer ctermbg=bg ctermfg=bg guibg=bg guifg=bg
function! CheckColorGroup()
    return map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction
" Fix coc popup menu color
highlight default link CocMenuSel PmenuSel
" Beacon
let g:beacon_size = 40
highlight Beacon guibg=#a0a1a7 ctermbg=15

" Lightline
set noshowmode
let g:lightline = {
      \ 'colorscheme': 'solarized',
      \ 'background': 'light',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'EmojiedFugitiveHead'
      \ },
      \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
      \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" },
      \ 'tabline_separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
      \ 'tabline_subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" },
      \ }

function! EmojiedFugitiveHead()
    return ' ' . FugitiveHead()
endfunction

" indentLine
set list listchars=tab:¦\ 
let g:indentLine_setColors = 1
let g:indentLine_defaultGroup = "LineNr"
let g:indentLine_char_list = ['¦']
let g:indentLine_concealcursor = 'c'
" Latex conceal compatibility
let g:indentLine_fileTypeExclude = ['tex']
" }}}


" Coc.nvim -- {{{

" Disable under diff mode
" autocmd VimEnter * CocDisable
" autocmd VimEnter * echom 0

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
" set cmdheight=2

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
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gT <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
xmap <leader>gf  <Plug>(coc-format-selected)
nmap <leader>gf  <Plug>(coc-format-selected)
nnoremap <silent> K :call <SID>show_documentation()<CR>
" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>aa  <Plug>(coc-codeaction-selected)
nmap <leader>aa  <Plug>(coc-codeaction-selected)
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

" Remap <C-d> and <C-u> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
    nnoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"
    nnoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"
    inoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<C-d>"
    inoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<C-u>"
    vnoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"
    vnoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"
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
nnoremap <silent><nowait> <leader>cs  :<C-u>CocList -I symbols<cr>
" Resume latest coc list.
nnoremap <silent><nowait> <leader>cp  :<C-u>CocListResume<CR>
" Restart coc service
nnoremap <silent><nowait> <leader>cr  :<C-u>CocRestart<CR>

" Confirm selection by <C-f>
inoremap <silent><nowait><expr> <C-f> coc#pum#visible() ? coc#pum#confirm() : "\<Right>"
inoremap <silent><nowait><expr> <C-b> "\<Left>"

augroup CocGroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    autocmd FileType css let b:coc_additional_keywords = ["-"]
    autocmd BufAdd * if getfsize(expand('<afile>')) > 1024*1024 |
                            \ let b:coc_enabled=0 |
                            \ endif
    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')
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
" Disable in vue project for the poor performance
autocmd BufAdd *.vue let b:coc_enabled=0
" }}}


" Plugin Settings -- {{{

" Floaterm
if has('unix') || has('macunix')
  let g:floaterm_shell='/usr/bin/zsh'
elseif has('win32')
  let g:floaterm_shell='"C:\Program Files\PowerShell\7\pwsh.exe"'
endif
let g:floaterm_width=0.8
let g:floaterm_height=0.8
nnoremap <silent> <C-t>t :FloatermToggle<CR>
nnoremap <silent> <C-t>n :FloatermNew<CR>
nnoremap <silent> <C-t>k :FloatermKill<CR>
nnoremap <silent> <C-t>] :FloatermNext<CR>
nnoremap <silent> <C-t>[ :FloatermPrev<CR>
tnoremap <silent> <C-t>t <C-\><C-n>:exe "sleep 100m \| FloatermToggle"<CR>
tnoremap <silent> <C-t>n <C-\><C-n>:exe "sleep 100m \| FloatermNew"<CR>
tnoremap <silent> <C-t>k <C-\><C-n>:exe "sleep 100m \| FloatermKill"<CR>
tnoremap <silent> <C-t>] <C-\><C-n>:exe "sleep 100m \| FloatermNext"<CR>
tnoremap <silent> <C-t>[ <C-\><C-n>:exe "sleep 100m \| FloatermPrev"<CR>

" Snippet
let g:UltiSnipsExpandTrigger = '<C-l>'

" NvimTree, Git, ctrlsf, startify & Tagbar
" NvimTree
call LoadLuaConf('nvim_tree_conf')
nnoremap <silent> <leader>e :NvimTreeToggle<CR>
augroup explorer
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * call s:handle_open_directory()
augroup END
function s:handle_open_directory()
    if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") 
        exe "cd" fnameescape(argv()[0])
        ene
        NvimTreeOpen
        sleep 100m
        wincmd w
    endif
endfunction

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
" Fzf
nnoremap <silent> F :FZF<CR>
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'Cursor', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'Cursor', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Cursor'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
" CtrlSF
let g:ctrlsf_backend = 'rg'
let g:ctrlsf_ignore_dir = [
            \ '*.log', 
            \ 'tsconfig.json',
            \ 'static', 
            \ 'dist',
            \ '.vscode',
            \ '.ycm_extra_conf.py',
            \ ]
nnoremap <leader>sf :CtrlSF 
" Startify
let g:startify_session_persistence = 1
let g:startify_session_delete_buffers = 1
let g:startify_session_before_save = [
            \ 'silent! NvimTreeClose',
            \ 'let g:startify_tmp_tabpagenr = tabpagenr()',
            \ 'let g:startify_tmp_winnr = winnr()',
            \ 'echo "Cleaning up before saving.."',
            \ 'silent! tabdo NvimTreeClose',
            \ 'execute "normal! " . g:startify_tmp_tabpagenr . "gt"',
            \ 'execute g:startify_tmp_winnr . "wincmd w"'
            \ ]
augroup startify_stuff
    autocmd VimEnter * call s:init_startify()
    autocmd BufEnter * let &titlestring=fnamemodify(v:this_session, ':t')
augroup END
function! s:init_startify()
    if !argc()
        Startify
        NvimTreeOpen
        sleep 100m
        wincmd w
    endif
endfunction
" Tagbar
let tagbar_left = 1
let tagbar_width = 32
let g:tagbar_compact=1
let g:tagbar_sort = 0
nmap <silent> <leader>w :TagbarToggle<CR>
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
" EditorConfig
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
au FileType gitcommit let b:EditorConfig_disable = 1
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
    autocmd FileType systemverilog,verilog set shiftwidth=4 tabstop=4
augroup END

" Markdown
let g:vim_markdown_folding_level = 6
let g:vim_markdown_conceal = 1
let g:vim_markdown_conceal_code_blocks = 1
let g:vim_markdown_autowrite = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_no_extensions_in_markdown = 1
augroup md_config
    autocmd!
    autocmd VimEnter * let g:vim_markdown_folding_disabled = &diff
augroup END

let g:mkdp_port = '34910'
let g:mkdp_refresh_slow = 1
let g:mkdp_open_to_the_world = 1
let g:mkdp_echo_preview_url = 1
noremap <leader>mp :MarkdownPreview<CR>
noremap <leader>ms :MarkdownPreviewStop<CR>

" LaTeX
let g:vimtex_complete_enabled = 0
let g:vimtex_syntax_conceal = {
            \ 'accents': 1,
            \ 'cites': 1,
            \ 'fancy': 1,
            \ 'greek': 1,
            \ 'math_bounds': 1,
            \ 'math_delimiters': 1,
            \ 'math_fracs': 0,
            \ 'math_super_sub': 0,
            \ 'math_symbols': 1,
            \ 'styles': 1,
            \ }
let g:vimtex_compiler_method = 'tectonic'
let g:vimtex_compiler_tectonic = {
            \ 'build_dir': 'dist',
            \ 'options': [
            \ '--keep-logs',
            \ '--synctex',
            \ ],
            \}
let g:vimtex_view_method = 'general'
let g:vimtex_view_general_viewer = 'SumatraPDF'
let g:vimtex_view_general_options
  \ = '-reuse-instance -forward-search @tex @line @pdf'
" Inhibit unnecessary font warnings
let g:vimtex_quickfix_ignore_filters = [
            \ ".*Script \"CJK\".*",
            \ ]
nnoremap <silent> <localleader>lb :VimtexCompile<CR>
augroup vimtex_common
    autocmd!
    autocmd FileType tex call SetServerName()
augroup END
" }}}


" Functions -- {{{

function! CocHook()
    !yarn
    !yarn build
    :CocInstall coc-pyright coc-json @yaegassy/coc-volar coc-html coc-tsserver coc-cmake coc-sh coc-css coc-cssmodules coc-clangd coc-rust-analyzer coc-texlab
endfunction

function! SetServerName()
    let nvim_server_file = has('win32')
                \ ? $TEMP . "/curnvimserver.txt"
                \ : $HOME . "/tmp/curnvimserver.txt"
    call system(printf("echo %s > %s", v:servername, nvim_server_file))
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
