" Load plugins first
call plug#begin()

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'christoomey/vim-tmux-navigator'
Plug 'fholgado/minibufexpl.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'majutsushi/tagbar'
Plug 'ntpeters/vim-better-whitespace'
Plug 'mhinz/vim-signify'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'jiangmiao/auto-pairs'
Plug '907th/vim-auto-save'
Plug 'junegunn/vim-slash'
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/fzf'
Plug 'junegunn/vim-peekaboo'
Plug 'easymotion/vim-easymotion'

if has('nvim') || (v:version >= 800)
    Plug 'w0rp/ale'
endif

" Colorschemes
"Plug 'twerth/ir_black'
"Plug 'NLKNguyen/papercolor-theme'
"Plug 'alem0lars/vim-colorscheme-darcula'
Plug 'jnurmine/Zenburn'

call plug#end()

" Indent settings
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=0 " Same as tabstop
set shiftround
set autoindent
set smartindent

" Search settings
set ignorecase
set smartcase
set incsearch
" turn off search highlight
noremap <leader><space> :nohlsearch<CR>

" Other settings
set ruler
set number
set nowrap
set showcmd
set cursorline
set wildmenu
set wildmode=longest:full,full " Stop on ambiguity, then go through possibilities
set modeline
set backspace=indent,eol,start
set pastetoggle=<F2>
set scrolloff=3
set colorcolumn=120
set shortmess+=I " Remove intro text
set completeopt=menuone,longest " Show menu even if one possibility and stop on ambiguity
set mouse=a

" Set to auto read when a file is changed from the outside
set autoread

" Whitespaces
set listchars=tab:→\ ,trail:~
set list

" Use persistent undo
set undodir=~/.vim/undo
set undofile
set undolevels=1000 " maximum number of changes that can be undone
set undoreload=10000 " maximum number lines to save for undo on a buffer reload

" Key remaps
nnoremap <tab> %
vnoremap <tab> %

" Disable arrow keys
noremap <up>     <nop>
noremap <down>   <nop>
noremap <left>   <nop>
noremap <right>  <nop>
inoremap <up>    <nop>
inoremap <down>  <nop>
inoremap <left>  <nop>
inoremap <right> <nop>

" Start/End of line
nnoremap H ^
nnoremap L $

" Disable macro recording or whatever
noremap q <nop>
" Disable going in ex mode
noremap Q <nop>

" Insert at beginning / end of selected lines
vnoremap i <C-V>^I
vnoremap a <C-V>$A

" Cause we all do these mistakes
command! W w
command! Wq wq
command! WQ wq
command! Q q
command! Qa qa
command! QA qa

" Close current buffer but keep window
nmap <leader>d :bp<bar>sp<bar>bn<bar>bd<CR>

" JSON Tidy: Reformat JSON file
nmap <leader>jt :%!python -m json.tool<CR>
" XML Tidy: Reformat XML file
nmap <leader>xt :%!tidy -xml -i -w 2048 2>/dev/null<CR>

if has('nvim')
    " Send all/line to terminal
    nnoremap <leader>sa ggyG<C-w>wpi<CR><C-\><C-n><C-w>p``
    nnoremap <leader>sl yy<C-w>wpi<CR><C-\><C-n><C-w>p
    inoremap <leader>sa <ESC>ggyG<C-w>wpi<CR><C-\><C-n><C-w>p``a
    inoremap <leader>sl <ESC>yy<C-w>wpi<CR><C-\><C-n><C-w>pa

    " Send current selection to terminal
    vnoremap <leader>ss y<C-w>wpi<CR><C-\><C-n><C-w>p

    tnoremap <ESC><ESC> <C-\><C-n>
endif

" Syntaxes
syntax enable
au BufNewFile,BufRead *.bf set filetype=brainfuck
au BufNewFile,BufRead *.asm set filetype=nasm

" Disable stuff that slow down vim when working with big files
function! DisableStuffForBigFiles()
    syntax off
    set nocursorline
endfunction

" Manually set file encodings
function! SetFileEncodings(encodings)
    let b:fileencodingsbak=&fileencodings
    let &fileencodings=a:encodings
endfunction

" Restore previous file encodings
function! RestoreFileEncodings()
    let &fileencodings=b:fileencodingsbak
    unlet b:fileencodingsbak
endfunction

" Prevent slow downs when opening files bigger than 1MiB
au BufReadPre * if getfsize(expand("%")) > 1048576 | :call DisableStuffForBigFiles() | endif

" Make NFOs nice!
au BufReadPre *.nfo call SetFileEncodings('cp437')|set ambiwidth=single
au BufReadPost *.nfo call RestoreFileEncodings()

" Colors
if exists('$TMUX')
    " Colors in tmux
    let &t_8f = "<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "<Esc>[48;2;%lu;%lu;%lum"
endif

if substitute(system('tput colors'), '\n', '', '') == "256"
    if has('nvim')
        set termguicolors
        set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
    endif

    set bg=dark
    colorscheme zenburn
else
    colorscheme desert
endif

" vimdiff
if &diff
    set diffopt+=iwhite " Ignore changes in amount of white space.
endif

" --- PLUGINS ---
" Tagbar
nmap <leader>l :TagbarToggle<CR>
imap <leader>l <ESC>:TagbarToggle<CR>a

" MiniBufExpl
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1
let g:miniBufExplForceSyntaxEnable = 1

" NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <leader>nn :NERDTreeToggle<CR>
nnoremap <leader>nc :NERDTreeCWD<CR>
nnoremap <leader>nf :NERDTreeFind<CR>

" vim-better-whitespace
nnoremap <leader>ws :StripWhitespace<CR>

" Indent Guide
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2
let g:indent_guides_enable_on_vim_startup = 1

" vim-easytag
let g:easytags_async = 1
let g:easytags_file = '~/.vim/gtags'
let g:easytags_by_filetype = '~/.vim/tags/'

" vim-auto-save
let g:auto_save = 1  " enable AutoSave on Vim startup
let g:auto_save_in_insert_mode = 0  " do not save while in insert mode
let g:auto_save_silent = 1  " do not display the auto-save notification

" GitGutter
nnoremap <leader>gp :GitGutterPrevHunk<CR>
nnoremap <leader>gn :GitGutterNextHunk<CR>
nnoremap <leader>gr :GitGutterUndoHunk<CR>

" Ale
nnoremap <leader>ad :ALEDisable<CR>
nnoremap <leader>ae :ALEEnable<CR>
nnoremap <leader>at :ALEToggle<CR>
nmap <silent> <C-Up> <Plug>(ale_previous_wrap)
nmap <silent> <C-Down> <Plug>(ale_next_wrap)
let g:ale_sh_shellcheck_options = '-x'  " Allow source outside of FILES
let g:ale_python_flake8_options = '--max-line-length 120'

" EasyAlign
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
xmap gs :EasyAlign *\ <CR>

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" FZF
nnoremap <leader>fh :FZF ~<CR>
nnoremap <leader>f. :FZF <CR>

" Match vim colorscheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" Airline
set noshowmode
set laststatus=2
let g:airline_theme='zenburn'

let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_left_alt_sep= '>'
let g:airline_right_alt_sep = '<'

let g:airline_section_z="%#__accent_bold#%4l/%L%#__restore__# :%3v"

let g:airline#extensions#branch#enabled = 1
