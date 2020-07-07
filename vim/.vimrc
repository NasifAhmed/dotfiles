syntax on
filetype plugin indent on

set hidden
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
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
set noshowmode

let g:rainbow_active = 1

call plug#begin('~/.vim/plugged')

Plug 'ap/vim-css-color'
Plug 'itchyny/lightline.vim'
Plug 'NasifAhmed/lightline-gruvbox.vim'
Plug 'morhetz/gruvbox'
Plug 'preservim/nerdtree'
Plug 'leafgarland/typescript-vim'  
Plug 'scrooloose/syntastic'

call plug#end()



set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0 

let g:lightline = {}
let g:lightline.colorscheme = 'gruvbox'

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif 


let mapleader=" "

nnoremap <leader>t :tabnew<CR>
nnoremap <leader>l :tabnext<CR>
nnoremap <leader>h :tabprevious<CR>
map <C-n> :NERDTreeToggle<CR>
map <C-s> :FZF<CR>
noremap <Up> :resize +1 <CR>
noremap <Down> :resize -1 <CR>
noremap <Left> :vertical resize +1 <CR>
noremap <Right> :vertical resize -1 <CR>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
