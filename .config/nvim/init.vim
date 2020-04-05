
"             ███╗   ██╗██╗   ██╗██╗███╗   ███╗
"             ████╗  ██║██║   ██║██║████╗ ████║
"             ██╔██╗ ██║██║   ██║██║██╔████╔██║
"             ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
"             ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
"             ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝

" ################################################################
" #                                                              #
" #                          VIM-PLUG 	                         #
" #                                                              #
" ################################################################

if ! filereadable(expand('~/.local/share/nvim/site/autoload/plug.vim'))
	echo "Downloading vim-plug to manage plugins..."
	silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall
endif

source ~/.config/nvim/plugins.vim
source ~/.config/nvim/shortcuts.vim

" ################################################################
" #                                                              #
" #                       SYSTEM SETTINGS                        #
" #                                                              #
" ################################################################

" Use Vim defaults
set nocompatible

" Encoding displayed and written to file in utf-8
scriptencoding utf-8
set encoding=utf-8
set fileencoding=utf-8

" Explicitly tell vim that the terminal supports 256 colors
set t_Co=256

" Enable 24 bit color support if supported
if (has('mac') && empty($TMUX) && has('termguicolors'))
  set termguicolors
endif

" Copy and paste for vim
set clipboard=unnamed
" Case insensitive searching
set ignorecase
" Case-sensitive if expresson contains a capital letter
set smartcase
" Highlight search results
set hlsearch
" Set incremental search, like modern browsers
set incsearch
" Don't redraw while executing macros
set nolazyredraw
" Disable swap files
set noswapfile
" Show cursorline
set cursorline

" ################################################################
" #                                                              #
" #                       CODE FORMATTING                        #
" #                                                              #
" ################################################################

" The current buffer can be put to the background without writing to disk
set hidden

" Enable syntax highlighting
syntax on

" Make the highlighting of tabs and other non-text less annoying
highlight SpecialKey ctermfg=236
highlight NonText ctermfg=236

" Make comments and HTML attributes italic
highlight Comment cterm=italic
highlight htmlArg cterm=italic
highlight xmlAttrib cterm=italic
highlight Type cterm=italic
highlight Normal ctermbg=none

" Show line numbers
set number relativenumber
" Show matching brackets.
set showmatch
" Bracket blinking.
set matchtime=2
" Set terminal title
set title
" Show incomplete commands
set showcmd

" Remember indentation of previous line
set autoindent
" A tab as the first character on a line is shiftwidth
set smarttab
" Replace tabs with ${tabstop} spaces
set expandtab
" Tabs are 4 spaces
set tabstop=4
" Default shift width for indents
set shiftwidth=4
" Edit as if the tabs are 4 characters wide
set softtabstop=6 
" Round indent to a multiple of 'shiftwidth'
set shiftround

" Toggle invisible characters (tabs)
set list listchars=tab:\|\ 
set list

" ################################################################
" #                                                              #
" #                  AUTOCOMMANDS & FYLETYPES                    #
" #                                                              #
" ################################################################

" Filetypes
filetype on
filetype plugin on
filetype indent on

" This will start Startify
autocmd VimEnter * if !argc() | Startify | wincmd w | endif

" Remember cursor position between vim sessions
autocmd BufReadPost *
      \ if line("'\"") > 0 && line ("'\"") <= line("$") |
      \   exe "normal! g'\"" |
      \ endif
" Center buffer around cursor when opening files
autocmd BufRead * normal zz

" BASH / ZSH support
autocmd FileType sh setlocal shiftwidth=4 tabstop=4 softtabstop=4
autocmd FileType sh set keywordprg=man

" JSON support
au! BufRead,BufNewFile *.json set filetype=json

" Java/HTML/JS support
autocmd FileType java,html,javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2

" Configure Startify
autocmd User Startified setlocal cursorline

" ################################################################
" #                                                              #
" #                           PLUGINS                            #
" #                                                              #
" ################################################################

" ---------------------------------------------------
"                    NERDCommenter
" ---------------------------------------------------

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" ---------------------------------------------------
"                      FZF
" ---------------------------------------------------

let g:fzf_layout = { 'down': '~25%' }

" ---------------------------------------------------
"                     UltiSnips
" ---------------------------------------------------

" Complete with TAB
let g:UltiSnipsExpandTrigger="<tab>"

" ---------------------------------------------------
"                     JS Libraries
" ---------------------------------------------------

" Syntax file for JavaScript libraries
let g:used_javascript_libs = 'angularui, angularuirouter, react, vue'

" ---------------------------------------------------
"                     Deoplete
" ---------------------------------------------------

" Enable autocomplete
let g:deoplete#enable_at_startup = 1

" ---------------------------------------------------
"                       JSON
" ---------------------------------------------------

" Show correct syntax on JSON
let g:vim_json_syntax_conceal = 0

" ---------------------------------------------------
"                       Emmet
" ---------------------------------------------------

let g:user_emmet_settings = {
      \   'javascript.jsx': {
      \   'extends': 'jsx',
      \  },
      \}

" ---------------------------------------------------
"                      Tsuquyomi
" ---------------------------------------------------

"  Method's signature in the popup menu
let g:tsuquyomi_disable_default_mappings = 1

" ---------------------------------------------------
"                     Signify
" ---------------------------------------------------

let g:signify_vcs_list = [ 'git' ]
let g:signify_sign_add = '+'
let g:signify_sign_delete = '_'
let g:signify_sign_delete_first_line = '‾'
let g:signify_sign_change = '!'

" ---------------------------------------------------
"                     Vimwiki
" ---------------------------------------------------

" Show path for VimWiki and use markdown for this
let g:vimwiki_list = [{'path': '~/Vimwiki/',
      \ 'syntax': 'markdown', 
      \ 'ext': '.md'}]

" Extensions and syntax
let g:vimwiki_ext2syntax = {'.md': 'markdown',
      \ '.mkd': 'markdown',
      \ '.mdown': 'markdown'}

" ---------------------------------------------------
"                     Markdown
" ---------------------------------------------------
 let g:mkdp_auto_close = 0

" ---------------------------------------------------
"                     Limelight
" ---------------------------------------------------

" Highlight in Goyo mode
let g:limelight_conceal_ctermfg = 240

" ---------------------------------------------------
"                       Goyo
" ---------------------------------------------------

" Function for entered and leave in Goyo
let g:goyo_entered = 0
function! s:goyo_enter()
  silent !tmux set status off
  let g:goyo_entered = 1
  set noshowmode
  set noshowcmd
  set scrolloff=999
  Limelight
endfunction

function! s:goyo_leave()
  silent !tmux set status on
  let g:goyo_entered = 0
  set showmode
  set showcmd
  set scrolloff=5
  Limelight!
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" ---------------------------------------------------
"                       ALE
" ---------------------------------------------------

let g:ale_change_sign_column_color = 0
" Keep the sign gutter open at all times
let g:ale_sign_column_always = 1
" Change signs for warning and error
let g:ale_sign_error = '✖'
let g:ale_sign_warning = '⚠'
" Enable completion where available (only for Typescript)
let g:ale_completion_enabled = 1
" Don't fix files when you save them
let g:ale_fix_on_save = 0

let g:ale_linters = {
      \	'javascript': ['prettier', 'eslint'],
      \	'typescript': ['tsserver', 'tslint'],
      \	'jsx': ['stylelint', 'eslint'],
      \	'python': ['flake8', 'pylint'],
      \	'html': []
      \}

let g:ale_fixers = {}
let g:ale_fixers['javascript'] = ['prettier', 'eslint']
let g:ale_fixers['typescript'] = ['prettier', 'tslint']
let g:ale_fixers['jsx'] = ['prettier', 'eslint']
let g:ale_fixers['vue'] = ['eslint-plugin-vue']
let g:ale_fixers['json'] = ['prettier']
let g:ale_fixers['python'] = ['autopep8', 'yapf']
" let g:ale_javascript_prettier_use_local_config = 1

" ---------------------------------------------------
"                  	 Startify
" ---------------------------------------------------

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
  return map(commits, '{"line": matchstr(v:val, "\\s\\zs.*"), "cmd": "'. git .' show ". matchstr(v:val, "^\\x\\+") }')
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
      \ { 'z': '~/.config/zsh' }
      \ ]

" ---------------------------------------------------
"                     NERDTree
" ---------------------------------------------------

let g:WebDevIconsOS = 'Darwin'

" Enables folder icon highlighting using exact match
let g:NERDTreeHighlightFolders = 1
let g:WebDevIconsUnicodeDecorateFolderNodes = 1

" Highlights the folder name
let g:NERDTreeHighlightFoldersFullName = 1

" Disable uncommon file extensions highlighting
let g:NERDTreeLimitedSyntax = 1

" Close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Custom NERDTree Git
let g:NERDTreeIndicatorMapCustom = {
      \ "Modified"  : "✹",
      \ "Staged"	  : "✚",
      \ "Untracked" : "✭",
      \ "Renamed"   : "➜",
      \ "Unmerged"  : "═",
      \ "Deleted"   : "✖",
      \ "Dirty"	  : "✗",
      \ "Clean"	  : "✔︎",
      \ 'Ignored'   : '☒',
      \ "Unknown"   : "?"
      \ }

" ---------------------------------------------------
"                     Lightline
" ---------------------------------------------------

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
  " return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
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
