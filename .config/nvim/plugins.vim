"                 ________  ___       ___  ___  ________  ___  ________   ________
"                |\   __  \|\  \     |\  \|\  \|\   ____\|\  \|\   ___  \|\   ____\
"                \ \  \|\  \ \  \    \ \  \\\  \ \  \___|\ \  \ \  \\ \  \ \  \___|_
"                 \ \   ____\ \  \    \ \  \\\  \ \  \  __\ \  \ \  \\ \  \ \_____  \
"                  \ \  \___|\ \  \____\ \  \\\  \ \  \|\  \ \  \ \  \\ \  \|____|\  \
"                   \ \__\    \ \_______\ \_______\ \_______\ \__\ \__\\ \__\____\_\  \
"                    \|__|     \|_______|\|_______|\|_______|\|__|\|__| \|__|\_________\
"                                                                           \|_________|

call plug#begin('~/.config/nvim/plugged')

" Base16 themes
Plug 'chriskempson/base16-vim'

" NerdTree
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
" Plug 'tsony-tsonev/nerdtree-git-plugin'

" Lightline (Bottom line)
Plug 'itchyny/lightline.vim'
Plug 'BorjaIP/vim-base16-lightline'

" Awesome icons
Plug 'ryanoasis/vim-devicons'

" Awesome start display
Plug 'mhinz/vim-startify'

" Fuzzy finder files in vim (add path from brew)
Plug 'junegunn/fzf.vim'

" Window max on '<leader>-w-o'
Plug 'vim-scripts/ZoomWin'

" Visualizes undo history
Plug 'mbbill/undotree'

" Shows git diff in the numbers line
Plug 'airblade/vim-gitgutter'

" Best Git wrapper of all time
" Plug 'tpope/vim-fugitive'

" Resolving git merge and rebase conflicts
" Plug 'christoomey/vim-conflicted'

" Delete, change and add such surroundings in pairs
Plug 'tpope/vim-surround'

" Commenting pluggin
Plug 'scrooloose/nerdcommenter'

" Highlight colors
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }

" Goyo
Plug 'junegunn/goyo.vim'

" ALE (Asynchronous Lint Engine)
Plug 'dense-analysis/ale'

" Auto pairs completion in brackets
Plug 'jiangmiao/auto-pairs'

" Syntax highlight and indentation suppor for multiple lenguages
Plug 'sheerun/vim-polyglot'

" Code completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Autocomplete code for web
" Plug 'mattn/emmet-vim', { 'for': ['html', 'javascript.jsx']}

" Match tags in html, similar to paren support
" Plug 'gregsexton/MatchTag', { 'for': 'html' }

" Endings for html, xml, etc.
" Plug 'tpope/vim-ragtag'

" Syntax support for md
" Plug 'tpope/vim-markdown', { 'for': 'markdown' }

" Markdown preview
" Plug 'iamcco/markdown-preview.vim'

call plug#end()
