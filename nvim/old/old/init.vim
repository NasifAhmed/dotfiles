syntax on
filetype plugin indent on

set hidden
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set textwidth=120
set smartindent
set number relativenumber
set nu rnu
set nowrap
set smartcase
set noswapfile
set nobackup
set undofile
set incsearch
set hlsearch
set laststatus=2  
set noshowmode  " this is to remove the default INSERT prompt
set ruler
set wildmenu
set lazyredraw
set showmatch
"  set spell   " this will turn spell-checking dictionary
nnoremap // :noh<return>

filetype plugin on
set omnifunc=syntaxcomplete#Complete


let g:rainbow_active = 1
call plug#begin('~/.vim/plugged') 
Plug 'ap/vim-css-color'
Plug 'itchyny/lightline.vim'
Plug 'NasifAhmed/lightline-gruvbox.vim'
Plug 'morhetz/gruvbox'
Plug 'preservim/nerdtree'
Plug 'leafgarland/typescript-vim'  
Plug 'scrooloose/syntastic'
Plug 'junegunn/goyo.vim'
Plug 'psliwka/vim-smoothie'

call plug#end()



set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0 

let g:lightline = {}
let g:lightline.colorscheme = 'deus'
let g:lightline#extensions#tabline#enabled = 1
let g:lightline#extensions#tabline#fnamemod = ':t'

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif 


let mapleader=" "
nnoremap <leader>t :enew<CR><C-n>
nnoremap <leader>l :bnext<CR>
nnoremap <leader>h :bprevious<CR>
map <C-n> :NERDTreeToggle<CR>
map <C-s> :FZF<CR>
noremap <Down> :resize +1 <CR>
noremap <Up> :resize -1 <CR>
noremap <Right> :vertical resize +1 <CR>
noremap <Left> :vertical resize -1 <CR>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
nnoremap <leader>v <C-W><C-V>
nnoremap <leader>s <C-W><C-S>
nnoremap <leader>q <C-W><C-Q>
nnoremap <leader>p "*p
nnoremap <leader>o o<Esc>o
nnoremap <leader>O O<Esc>o
nnoremap <leader>j o<Esc> 
nnoremap <leader>k O<Esc> 
