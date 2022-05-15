"
"----------- Vim options ----------- 
"
set hidden
set laststatus=2
set number
set relativenumber
set cursorline
set nobackup
set nowritebackup

" Show indent guides
set list
set listchars=tab:\|\ ,nbsp:·,trail:·

" Indent settings
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

"
"----------- Packages ----------- 
"
packadd! onedark.vim

"
"----------- Auto CMD -----------
"
if has("autocmd")
    " File type detection. Indent based on filetype. Recommended.
    filetype plugin indent on
endif

"
"----------- Lightline ----------- 
"
let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }

"
"----------- Color theme and syntax ----------- 
"
let g:onedark_termcolors=256

if (has("termguicolors"))
  set termguicolors
endif

colorscheme onedark
set background=dark
syntax on
