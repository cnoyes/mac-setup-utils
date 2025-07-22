" ====================
" General Settings
" ====================

syntax on                  " Enable syntax highlighting
filetype plugin indent on  " Enable filetype detection and indentation
set encoding=utf-8         " Set encoding
set number                 " Show line numbers
set ruler                  " Show the cursor position
set showcmd                " Show (partial) command in the status line
set wildmenu               " Enhanced command line completion
set showmatch              " Show matching brackets

" ====================
" Indentation
" ====================

set tabstop=4              " Number of spaces a tab displays
set shiftwidth=4           " Number of spaces used for each auto-indent
set softtabstop=4          " Number of spaces when you press tab
set expandtab              " Use spaces instead of tabs
set autoindent             " Copy indent from current line when starting a new one
set smartindent            " Smart autoindenting for programming

" ====================
" Search
" ====================

set hlsearch               " Highlight all search results
set incsearch              " Show match while typing
set ignorecase             " Case-insensitive search...
set smartcase              " ... unless uppercase is used

" ====================
" Appearance
" ====================

set background=dark        " Better for dark themes
colorscheme desert         " You can try: desert, elflord, murphy, torte, etc.
set cursorline             " Highlight current line
set scrolloff=8            " Keep 8 lines visible above/below cursor
set laststatus=2           " Always show the status line

" ====================
" Python-Specific Settings
" ====================

autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType python setlocal tabstop=4

" ====================
" R-Specific Settings
" ====================

autocmd FileType r setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=2

