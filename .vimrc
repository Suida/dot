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
set nowrap
set spelllang=en_us,cjk
set conceallevel=2
" Indentation rules and folding
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set foldmethod=syntax
set nofoldenable
set indentexpr=
set smartindent


" Global key mappings

let mapleader = " "
" Editting
inoremap jk <ESC>
inoremap <C-e> <C-o>A
inoremap <C-o> <C-o>A<CR>
nnoremap <leader>] <C-w><C-]><C-w>T
" Navigation
nnoremap <C-j> 10j
nnoremap <C-k> 10k
nmap <C-c>h :tabp <CR>
nmap <C-c>l :tabn <CR>
" Arrows are not suggested
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
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


" Color

set number
set colorcolumn=80
set cursorline
set t_Co=256
set background=dark
set laststatus=2
colorscheme gruvbox
hi Normal guibg=NONE ctermbg=NONE
hi LineNr guifg=DeepPink2 guibg=NONE ctermfg=yellow ctermbg=NONE
hi TabLineFill guibg=NONE ctermfg=NONE ctermbg=NONE


" Ycm & Syntastic settings

nnoremap <leader>gf :YcmCompleter Format<CR>
nnoremap <leader>gd :YcmCompleter GoToDefinition<CR>
nnoremap <leader>gt :YcmCompleter GetType<CR>
nnoremap <leader>gi :YcmCompleter GoToInclude<CR>
nnoremap <leader>gr :YcmCompleter GoToReferences<CR>
nnoremap <leader>gp :call TogglePreview()<CR>
nnoremap <leader>sr :YcmRestartServer<CR>
nnoremap <leader>sl :call ToggleErrors()<CR>
nnoremap <leader>sk :call DoSyntasticCheck()<CR>

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
    "" \ FindConfig('-c', 'tox.ini', expand('%:p:h'))
    "" \ FindConfig('-c', 'setup.cfg', expand('%:p:h'))


" Markdown

let g:vim_markdown_folding_level = 3
let g:vim_markdown_autowrite = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_no_extensions_in_markdown = 1
let g:mkdp_port = '34910'
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
