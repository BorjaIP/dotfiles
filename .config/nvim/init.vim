"                _________  ___      ___ ___  _____ _______
"               |\   ___  \|\  \    /  /|\  \|\   _ \  _   \
"               \ \  \\ \  \ \  \  /  / | \  \ \  \\\__\ \  \
"                \ \  \\ \  \ \  \/  / / \ \  \ \  \\|__| \  \
"                 \ \  \\ \  \ \    / /   \ \  \ \  \    \ \  \
"                  \ \__\\ \__\ \__/ /     \ \__\ \__\    \ \__\
"                   \|__| \|__|\|__|/       \|__|\|__|     \|__|


" -----------------------------------------------------------------------------
"                    	        Vim Plug
" -----------------------------------------------------------------------------

if ! filereadable(expand('~/.local/share/nvim/site/autoload/plug.vim'))
    echo "Downloading vim-plug to manage plugins..."
    silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall
endif

" -----------------------------------------------------------------------------
"                             System settings
" -----------------------------------------------------------------------------

source ~/.config/nvim/plugins.vim
source ~/.config/nvim/shortcuts.vim

set mouse=a                     " Add mouse in all modes
set clipboard+=unnamedplus      " Copy and paste for vim
set ignorecase                  " Case insensitive searching
set smartcase                   " Case-sensitive ignore capital letters
set incsearch                   " Set incremental search, like modern browsers
set nolazyredraw                " Don't redraw while executing macros
set cursorline                  " Show cursorline
set splitbelow splitright       " Fix splitting
set autoread                    " Autoread files if it changed
set noswapfile                  " Disable swap files
set nobackup                    " Disable backup
set nowritebackup               " Resolve issies with backup files
set undodir                     " Directory for undo ('$XDG_DATA_HOME/nvim/undo')
set undofile                    " Saves undo history
set updatetime=300              " Change time to reload file
set hidden                      " Put buffer to the background
set number relativenumber       " Show line numbers
set expandtab                   " Replace tabs with ${tabstop} spaces
set tabstop=4                   " Tabs are 4 spaces
set shiftwidth=4                " Default shift width for indents
set softtabstop=4               " Edit as if the tabs are 4 characters wide
set shiftround                  " Round indent to a multiple of 'shiftwidth'
set cmdheight=2                 " Give more space for displaying messages
set shortmess+=c                " Don't pass messages to 'ins-completion-menu'
set signcolumn=yes              " Always show the signcolumn
" set colorcolumn=80              " Show column

" Filetypes
filetype on                     " File type detection
filetype plugin indent on       " Add plugin indent changes
" filetype plugin on              " Ignore plugin indent changes

" This will start Startify
autocmd VimEnter * if !argc() | Startify | wincmd w | endif

" Remove trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

" Remember cursor position between vim sessions
autocmd BufReadPost *
            \ if line("'\"") > 0 && line ("'\"") <= line("$") |
            \   exe "normal! g'\"" |
            \ endif
" Center buffer around cursor when opening files
autocmd BufRead * normal zz

" Configure Startify
autocmd User Startified setlocal cursorline

" Make sure all types of requirements.txt files get syntax highlighting.
autocmd BufNewFile,BufRead requirements*.txt set syntax=python

" -----------------------------------------------------------------------------
"                               NERDCommenter
" -----------------------------------------------------------------------------

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" -----------------------------------------------------------------------------
"                                   FZF
" -----------------------------------------------------------------------------

let g:fzf_layout = { 'down': '~25%' }

" -----------------------------------------------------------------------------
"                                Hexokinase
" -----------------------------------------------------------------------------
let g:Hexokinase_refreshEvents = ['TextChanged', 'InsertLeave']

let g:Hexokinase_optInPatterns = [
            \     'full_hex',
            \     'triple_hex',
            \     'rgb',
            \     'rgba',
            \     'hsl',
            \     'hsla',
            \     'colour_names'
            \ ]

let g:Hexokinase_highlighters = ['backgroundfull']

" Reenable hexokinase on enter
autocmd VimEnter * HexokinaseTurnOn

" -----------------------------------------------------------------------------
"                                  Markdown
" -----------------------------------------------------------------------------
let g:mkdp_auto_close = 0

" -----------------------------------------------------------------------------
"                                  Gutter
" -----------------------------------------------------------------------------

let g:gitgutter_enabled = 1
let g:gitgutter_map_keys = 0

" -----------------------------------------------------------------------------
"                                   Goyo
" -----------------------------------------------------------------------------

" Function for entered and leave in Goyo
let g:goyo_entered = 0
function! s:goyo_enter()
    silent !tmux set status off
    let g:goyo_entered = 1
    set noshowmode
    set noshowcmd
    set scrolloff=999
endfunction

function! s:goyo_leave()
    silent !tmux set status on
    let g:goyo_entered = 0
    set showmode
    set showcmd
    set scrolloff=5
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" -----------------------------------------------------------------------------
"                                   ALE
" -----------------------------------------------------------------------------

" Keep the sign gutter open at all times
" let g:ale_change_sign_column_color = 0
" let g:ale_sign_column_always = 1
" Change signs for warning and error
" let g:ale_sign_error = '✖'
" let g:ale_sign_warning = '⚠'
" Fixers
" let g:ale_fix_on_save = 1
" let g:ale_fixers = {
            " \   'python': ['yapf', 'isort' ],
            " \   'json': ['prettier']
            " \}

" -----------------------------------------------------------------------------
"                                    CoC
" -----------------------------------------------------------------------------

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" -----------------------------------------------------------------------------
"                                 Startify
" -----------------------------------------------------------------------------

" Don't change to directory when selecting a file
let g:startify_files_number = 5
let g:startify_change_to_dir = 0
let g:startify_custom_header = [ ]
let g:startify_relative_path = 1
let g:startify_use_env = 1

function! s:list_commits()
    let git = 'git -C ' . getcwd()
    let commits = systemlist(git . ' log --oneline | head -n5')
    let git = 'G' . git[1:]
    return map(commits, '{
                \ "line": matchstr(v:val, "\\s\\zs.*"),
                \ "cmd": "'. git .' show ". matchstr(v:val, "^\\x\\+")
                \ }')
endfunction

" Custom startup list, only show MRU from current directory/project
let g:startify_lists = [
            \  { 'type': 'dir',		  'header': [ 'Files '. getcwd() ] },
            \  { 'type': function('s:list_commits'), 'header': [ 'Recent Commits' ] },
            \  { 'type': 'sessions',  'header': [ 'Sessions' ]		 },
            \  { 'type': 'bookmarks', 'header': [ 'Bookmarks' ]		 },
            \  { 'type': 'commands',  'header': [ 'Commands' ]		 },
            \ ]

let g:startify_commands = [
            \	{ 'ui': [ 'Install Plugins', ':PlugInstall' ] },
            \	{ 'up': [ 'Update Plugins', ':PlugUpdate' ] },
            \	{ 'ug': [ 'Upgrade Plugin', ':PlugUpgrade' ] },
            \ ]

let g:startify_bookmarks = [
            \ { 'c': '~/.config/nvim/init.vim' },
            \ { 'p': '~/.config/nvim/plugins.vim' },
            \ { 's': '~/.config/nvim/shortcuts.vim' },
            \ ]

" -----------------------------------------------------------------------------
"                                   NERDTree
" -----------------------------------------------------------------------------
" Enables folder icon highlighting using exact match
let g:NERDTreeHighlightFolders = 1
let g:WebDevIconsUnicodeDecorateFolderNodes = 1

" Highlights the folder name
let g:NERDTreeHighlightFoldersFullName = 1

" Disable uncommon file extensions highlighting
" let g:NERDTreeLimitedSyntax = 1

" Custom NERDTree Git
" let g:NERDTreeGitStatusWithFlags = 1
"
" Close vim if the only window left open is a NERDTree
autocmd bufenter *
            \ if (winnr("$") == 1 && exists("b:NERDTree")
            \ && b:NERDTree.isTabTree()) | q |
            \ endif

" Ignore files in NERDTree
let NERDTreeIgnore = ['\.pyc$', '^node_modules$', '\~$']

" -----------------------------------------------------------------------------
"                                   Lightline
" -----------------------------------------------------------------------------

let g:lightline = {
            \	'colorscheme': 'base16',
            \	'active': {
            \		'left': [ [ 'mode', 'paste' ],
            \				[ 'gitbranch' ],
            \				[ 'readonly', 'filetype', 'filename' ]],
            \		'right': [ [ 'percent' ], [ 'lineinfo' ],
            \				[ 'fileformat', 'fileencoding' ],
            \				[ 'linter_errors', 'linter_warnings' ]]
            \	},
            \	'component_expand': {
            \		'linter': 'LightlineLinter',
            \		'linter_warnings': 'LightlineLinterWarnings',
            \		'linter_errors': 'LightlineLinterErrors',
            \		'linter_ok': 'LightlineLinterOk'
            \	},
            \	'component_type': {
            \		'readonly': 'error',
            \		'linter_warnings': 'warning',
            \		'linter_errors': 'error'
            \	},
            \	'component_function': {
            \		'fileencoding': 'LightlineFileEncoding',
            \		'filename': 'LightlineFileName',
            \		'fileformat': 'LightlineFileFormat',
            \		'filetype': 'LightlineFileType',
            \		'gitbranch': 'LightlineGitBranch'
            \	},
            \	'tabline': {
            \		'left': [ [ 'tabs' ] ],
            \		'right': [ [ 'close' ] ]
            \	},
            \	'tab': {
            \		'active': [ 'filename', 'modified' ],
            \		'inactive': [ 'filename', 'modified' ],
            \	},
            \	'separator': { 'left': '', 'right': '' },
            \	'subseparator': { 'left': '', 'right': '' }
            \ }

let g:lightline_buffer_enable_devicons = 1

function! LightlineFileName() abort
    let filename = winwidth(0) > 70 ? expand('%') : expand('%:t')
    if filename =~ 'NERD_tree'
        return ''
    endif
    let modified = &modified ? ' +' : ''
    return fnamemodify(filename, ":~:.") . modified
endfunction

function! LightlineFileEncoding()
    " only show the file encoding if it's not 'utf-8'
    return &fileencoding == 'utf-8' ? '' : &fileencoding
endfunction

function! LightlineFileFormat()
    " only show the file format if it's not 'unix'
    let format = &fileformat == 'unix' ? '' : &fileformat
    return winwidth(0) > 70 ? format . ' ' . WebDevIconsGetFileFormatSymbol() : ''
endfunction

function! LightlineFileType()
    return WebDevIconsGetFileTypeSymbol()
    return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! LightlineLinter() abort
    let l:counts = ale#statusline#Count(bufnr(''))
    return l:counts.total == 0 ? '' : printf('×%d', l:counts.total)
endfunction

function! LightlineLinterWarnings() abort
    let l:counts = ale#statusline#Count(bufnr(''))
    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors
    return l:counts.total == 0 ? '' : '⚠ ' . printf('%d', all_non_errors)
endfunction

function! LightlineLinterErrors() abort
    let l:counts = ale#statusline#Count(bufnr(''))
    let l:all_errors = l:counts.error + l:counts.style_error
    return l:counts.total == 0 ? '' : '✖ ' . printf('%d', all_errors)
endfunction

function! LightlineLinterOk() abort
    let l:counts = ale#statusline#Count(bufnr(''))
    return l:counts.total == 0 ? 'OK' : ''
endfunction

function! LightlineGitBranch()
    return "\uE725 " . (exists('*fugitive#head') ? fugitive#head() : '')
endfunction

function! LightlineUpdate()
    if g:goyo_entered == 0
        " do not update lightline if in Goyo mode
        call lightline#update()
    endif
endfunction

augroup alestatus
    autocmd User ALELint call LightlineUpdate()
augroup end
