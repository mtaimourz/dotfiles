
" Basic Settings
set nocompatible
filetype plugin indent on
syntax on

let mapleader = " "
let maplocalleader = ","

set number
set relativenumber

set incsearch
set hlsearch
set ignorecase
set smartcase

set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set autoindent

set showcmd
set showmode
set wildmenu
set wildmode=longest:full,full
set scrolloff=8
set signcolumn=yes
" set colorcolumn=80

set lazyredraw
set ttyfast
set updatetime=50

set splitright
set splitbelow

set nobackup
set nowritebackup
set noswapfile
set undofile
set undodir=~/.vim/undodir

set clipboard=unnamed

set termguicolors
set background=dark

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'airblade/vim-gitgutter'

" Language support
Plug 'sheerun/vim-polyglot'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'christoomey/vim-tmux-navigator' " Tmux
Plug 'mhinz/vim-grepper'

Plug 'morhetz/gruvbox'              " Color scheme
Plug 'itchyny/lightline.vim'        " Minimal status line
Plug 'preservim/nerdtree'           " File tree (minimal use)
Plug 'mg979/vim-visual-multi'

call plug#end()

" Color
colorscheme gruvbox

" Escape insert mode quickly
inoremap jk <Esc>
inoremap kj <Esc>

nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>

" Navigation enhancements
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv

" Keep visual selection when indenting
vnoremap < <gv
vnoremap > >gv

" Move lines up/down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Clear search highlighting
nnoremap <leader>/ :nohlsearch<CR>

" Quick buffer navigation
nnoremap <leader>n :bnext<CR>
nnoremap <leader>p :bprevious<CR>
nnoremap <leader>d :bdelete<CR>

" Split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <leader>v :vsplit<CR>
nnoremap <leader>h :split<CR>

" File finder
nnoremap <leader>f :Files<CR>
nnoremap <leader>F :GFiles<CR>

" Buffer finder
nnoremap <leader>b :Buffers<CR>

" Content search (ripgrep)
nnoremap <leader>s :Rg<CR>
nnoremap <leader>S :RG<CR>

" Git commands
nnoremap <leader>gc :Commits<CR>
nnoremap <leader>gb :BCommits<CR>

" Command history
nnoremap <leader>: :History:<CR>

" Search history
nnoremap <leader>? :History/<CR>

" FZF customization
let g:fzf_layout = { 'down': '~40%' }
let g:fzf_preview_window = ['right:50%', 'ctrl-/']

" Advanced ripgrep command with preview
command! -bang -nargs=* RG
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)


" Quick compile/build
nnoremap <leader>m :make<CR>
nnoremap <leader>M :make!<CR>

" Execute current file based on filetype
autocmd FileType python nnoremap <buffer> <leader>r :!python3 %<CR>
autocmd FileType c nnoremap <buffer> <leader>r :!gcc % -o /tmp/a.out && /tmp/a.out<CR>
autocmd FileType cpp nnoremap <buffer> <leader>r :!g++ % -o /tmp/a.out && /tmp/a.out<CR>
autocmd FileType rust nnoremap <buffer> <leader>r :!cargo run<CR>
autocmd FileType javascript nnoremap <buffer> <leader>r :!node %<CR>
autocmd FileType sh nnoremap <buffer> <leader>r :!bash %<CR>


" debugger node
autocmd FileType python nnoremap <buffer> <leader>d :!python3 -m pdbpp %<CR>
autocmd FileType javascript nnoremap <buffer> <leader>d :!node inspect %<CR>


" Open quickfix/location list
nnoremap <leader>co :copen<CR>
nnoremap <leader>cc :cclose<CR>
nnoremap <leader>cn :cnext<CR>
nnoremap <leader>cp :cprevious<CR>


nnoremap <leader>gs :Git<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gl :Git log<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gP :Git pull<CR>

" File Explorer

nnoremap <leader>e :NERDTreeToggle<CR>
nnoremap <leader>E :NERDTreeFind<CR>

let NERDTreeShowHidden=1
let NERDTreeMinimalUI=1

let g:grepper = {
    \ 'tools': ['rg', 'git', 'grep'],
    \ 'open': 1,
    \ 'jump': 0,
    \ }

nnoremap <leader>* :Grepper -cword -noprompt<CR>
nnoremap <leader>g :Grepper<CR>

" CoC (Language Server Protocol)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Show documentation
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Rename symbol
nmap <leader>rn <Plug>(coc-rename)

" Formatting
xmap <leader>F  <Plug>(coc-format-selected)
nmap <leader>F  <Plug>(coc-format-selected)

" Apply AutoFix to problem on the current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Lightline Configuration

let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }

" Auto-remove trailing whitespace
autocmd BufWritePre * :%s/\s\+$//e

" Return to last edit position when opening files
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" C/C++ settings
autocmd FileType c,cpp setlocal tabstop=4 shiftwidth=4

" Web development
autocmd FileType html,css,javascript,typescript setlocal tabstop=2 shiftwidth=2

" Python
autocmd FileType python setlocal tabstop=4 shiftwidth=4

" Center cursor after searching
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz

" Better command-line editing
cnoremap <C-a> <Home>
cnoremap <C-e> <End>

" Quick macro playback
nnoremap Q @q

" Yank to end of line (consistent with D and C)
nnoremap Y y$

" Compile and run in split
command! CompileRun :w | vsplit | terminal gcc % -o /tmp/a.out && /tmp/a.out

" Open terminal in split
command! Term :vsplit | terminal
command! VTerm :vsplit | terminal
command! HTerm :split | terminal

" Quick edit vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" Don't redraw while executing macros
set lazyredraw

" Faster updatetime for better experience
set updatetime=50

" Reduce timeouts
set timeoutlen=500
set ttimeoutlen=10

" Enable per-project .vimrc
set exrc
set secure


" Terminal
nnoremap <leader>tt :terminal<CR>
tnoremap <Esc> <C-\><C-n>
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l
