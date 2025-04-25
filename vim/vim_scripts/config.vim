" Basic Settings -- {{{

syntax on
autocmd! bufreadpost *.svg set syntax=off
filetype plugin indent on

set exrc
set secure

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
set textwidth=120
set encoding=utf-8
set spelllang=en_us,cjk
set conceallevel=2
set concealcursor=
set clipboard+=unnamedplus
set noswapfile
set noshowmode
set list listchars=tab:¦\ 
set nobackup
set nowritebackup
set shortmess+=c
set updatetime=100
set guicursor=n-v-c-sm:block-blinkwait300-blinkon500-blinkoff500-TermCursor,i:hor20-blinkwait300-blinkon500-blinkoff500-TermCursor
augroup guidetect
    autocmd VimEnter * call s:guisettings()
augroup END

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
    " autocmd BufNewFile,BufRead,BufEnter *.md,*.tex set textwidth=0
    autocmd GUIEnter * simalt ~x
augroup END

" Persistent undo
let g:undo_path = fnamemodify(expand($MYVIMRC), ':h') . '/undo'
if !isdirectory(g:undo_path)
    call system('mkdir -p ' . g:undo_path)
endif
set undofile
set undolevels=1000
set undoreload=10000

set ttimeout
set ttimeoutlen=100

" Color
set number
set relativenumber
set colorcolumn=120
set signcolumn=yes:1
set cursorline
set t_Co=256
set background=light
set laststatus=2

" Under Wsl environment
if has('win32') && has('unix')
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
" }}}


" Functions -- {{{
function! SetServerName()
    let nvim_server_file = has('win32')
                \ ? $TEMP . "/curnvimserver.txt"
                \ : $HOME . "/tmp/curnvimserver.txt"
    call system(printf("echo %s > %s", v:servername, nvim_server_file))
endfunction

function! s:guisettings()
    set guifont=CaskaydiaCove\ NFM\ SemiBold:h10.6
endfunction
" }}}
