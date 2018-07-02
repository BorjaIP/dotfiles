"
"       ██████╗ ██╗     ██╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗
"       ██╔══██╗██║     ██║   ██║██╔════╝ ██║████╗  ██║██╔════╝
"       ██████╔╝██║     ██║   ██║██║  ███╗██║██╔██╗ ██║███████╗
"       ██╔═══╝ ██║     ██║   ██║██║   ██║██║██║╚██╗██║╚════██║
"       ██║     ███████╗╚██████╔╝╚██████╔╝██║██║ ╚████║███████║
"       ╚═╝     ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝


call plug#begin('~/.config/nvim/plugged')

" ################################################################
" #                                                              #
" #                            SYSTEM                            #
" #                                                              #
" ################################################################

" Base16 themes
Plug 'chriskempson/base16-vim'

" NerdTree
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" Lightline (Bottom line)
Plug 'itchyny/lightline.vim'
Plug 'BorjaIP/vim-base16-lightline'

" Awesome icons
Plug 'ryanoasis/vim-devicons'

" Awesome start display
Plug 'mhinz/vim-startify'

" Fuzzy finder files in vim (add path from brew)
Plug 'junegunn/fzf.vim'
Plug '/usr/local/opt/fzf'

" Show indent line with a marker
" Plug 'yggdroot/indentline'

" Window max on '<leader>-w-o'
Plug 'vim-scripts/ZoomWin'

" Tmux integration for vim
Plug 'benmills/vimux'

" Indicate added, modified and removed lines
Plug 'mhinz/vim-signify'

" Personal wiki
Plug 'vimwiki/vimwiki'

" Shows git diff in the numbers line
Plug 'airblade/vim-gitgutter'

" Best Git wrapper of all time
Plug 'tpope/vim-fugitive'

" Resolving git merge and rebase conflicts
Plug 'christoomey/vim-conflicted'

" ################################################################
" #                                                              #
" #                          CODING                              #
" #                                                              #
" ################################################################

" Delete, change and add such surroundings in pairs
Plug 'tpope/vim-surround'

" Autocomplete code for web
Plug 'mattn/emmet-vim', { 'for': ['html', 'javascript.jsx']}

" Match tags in html, similar to paren support
Plug 'gregsexton/MatchTag', { 'for': 'html' }

" Endings for html, xml, etc.
Plug 'tpope/vim-ragtag'

" Commenting pluggin
Plug 'scrooloose/nerdcommenter'

" Auto pairs completion in brackets
Plug 'jiangmiao/auto-pairs'

" ALE (Asynchronous Lint Engine)
Plug 'w0rp/ale'

" Goyo
Plug 'junegunn/goyo.vim'

" Hyperfocus-writing
Plug 'junegunn/limelight.vim'

" Solution for snippets (generate code)
Plug 'SirVer/ultisnips'

" Snippets for all
Plug 'honza/vim-snippets'

" Asynchronous completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }

" ################################################################
" #                                                              #
" #                          LENGUAGES                           #
" #                                                              #
" ################################################################

" ---------------------------------------------------
"                 HTML/CSS/TEMPLATES
" ---------------------------------------------------

" HTML5 support
Plug 'othree/html5.vim', { 'for': 'html' }

" Add syntax highlighting, indenting and autocompletion for Less
Plug 'groenewege/vim-less', { 'for': 'less' }

" Better syntax CSS
Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }

" For highlighting SCSS elements
Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }

" CSS show colors
Plug 'gko/vim-coloresque'

" Pug / Jade support
Plug 'digitaltoad/vim-pug', { 'for': ['jade', 'pug'] }

" ---------------------------------------------------
"                      JavaScript
" ---------------------------------------------------

" JS syntax highlighting and improved indentation
Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx', 'html'] }

" Syntax file for JavaScript libraries
Plug 'othree/javascript-libraries-syntax.vim'

" Complete for JS
Plug 'ternjs/tern_for_vim', { 'for': ['javascript', 'javascript.jsx'], 'do': 'npm install' }

" Syntax highlighting and indenting for JSX (React)
Plug 'mxw/vim-jsx', { 'for': ['javascript.jsx', 'javascript'] }

" Tools for developing with Node.js
Plug 'moll/vim-node', { 'for': 'javascript' }

" Syntax for vue
Plug 'posva/vim-vue'

" ---------------------------------------------------
"                      TypeScript
" ---------------------------------------------------

" Syntax file and other settings for TypeScript
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }

" Completion typescrpit
Plug 'Quramy/tsuquyomi', { 'for': 'typescript', 'do': 'npm install' }

" Great asynchronous execution library for Vim (needed by tsuquyomi)
Plug 'Shougo/vimproc.vim', { 'do': 'make' }

" ---------------------------------------------------
"                       JSON
" ---------------------------------------------------

" Friendly and syntax JSON
Plug 'elzr/vim-json', { 'for': 'json' }

" ---------------------------------------------------
"                        GO
" ---------------------------------------------------

" Go language support for Vim
Plug 'fatih/vim-go', { 'for': 'go' }

" ---------------------------------------------------
"                     MARKDOWN
" ---------------------------------------------------

" Syntax support for md
Plug 'tpope/vim-markdown', { 'for': 'markdown' }

" Python style guide
" Plug 'cburroughs/pep8.py'

call plug#end()
