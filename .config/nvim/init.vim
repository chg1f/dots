" encoding=utf-8

set nocompatible

set encoding=utf-8
set t_Co=256

" control
set mouse=
let g:mapleader=" "
let g:maplocalleader="\\"
" set clipboard=unnamedplus

" template files
if exists("*stdpath")
  let statedir=stdpath('state')
else
  let statedir=expand("$HOME/.local/state/vim")
  if !isdirectory(statedir)
    if exists("*mkdir")
      call mkdir(statedir, 'p')
    endif
  endif
endif
" BUG: save failure
" set backup
" exec 'set backupdir=' . statedir . '/backup'
exec 'set viewdir=' . statedir . '/views'
" BUG: read failure
" exec 'set directory=' . statedir . '/swap'
exec 'set undodir=' . statedir . '/undo'
set undofile
exec 'set viminfo+=n' . statedir . '/viminfo'
let g:netrw_home=statedir . '/netrw'

colorscheme desert
syntax on

set expandtab
set shiftwidth=2
set tabstop=4

" control characters
set list
set listchars=tab:»\ ,multispace:·\ ,trail:·,eol:¬,extends:>,precedes:<

" cursor
set cursorcolumn " always show vertical cursor
set cursorline " always show horizontal cursor
set cursorlineopt=both " highlight text line of the cursor and the line number

" tabline
set showtabline=2 " always show tabline

" statusline
set laststatus=2 " always show statusline

" ruler
set ruler

" sign
set number " show line number
set signcolumn=yes " always show sign column

" folder
set foldmethod=indent " fold by indent
set nofoldenable " disable fold by default

" indent
set autoindent " auto indent

" window
set splitbelow " default split below
set splitright " default split right

" search
set ignorecase " ignore case
set smartcase " don't ignore case with capitals
set grepformat='%f:%l:%c:%m'
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case\ --ignore-case
endif

"autocmd BufWritePre * if !isdirectory(expand('%:p:h')) call mkdir(expand('%:p:h'), 'p') endif

" Lazy load Neovim configurations
if has('nvim') && filereadable(stdpath("config") .. "/lua/lazyinit.lua")
  lua require("lazyinit")
endif
