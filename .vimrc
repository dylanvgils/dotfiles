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
"----------- vim-go ----------- 
"
let g:go_fmt_command = "goimports"
let g:go_autodetect_gopath = 1
let g:go_list_type = "quickfix"
let g:go_def_mapping_enabled = 0

let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_generate_tags = 1

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
      \   'gitbranch': 'fugitive#head'
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
