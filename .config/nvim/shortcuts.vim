"
"       ███████╗██╗  ██╗ ██████╗ ██████╗ ████████╗ ██████╗██╗   ██╗████████╗███████╗
"       ██╔════╝██║  ██║██╔═══██╗██╔══██╗╚══██╔══╝██╔════╝██║   ██║╚══██╔══╝██╔════╝
"       ███████╗███████║██║   ██║██████╔╝   ██║   ██║     ██║   ██║   ██║   ███████╗
"       ╚════██║██╔══██║██║   ██║██╔══██╗   ██║   ██║     ██║   ██║   ██║   ╚════██║
"       ███████║██║  ██║╚██████╔╝██║  ██║   ██║   ╚██████╗╚██████╔╝   ██║   ███████║
"       ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═════╝    ╚═╝   ╚══════╝


" ################################################################
" #                                                              #
" #                      SYSTEM MAPPINGS                         #
" #                                                              #
" ################################################################

" ESC to jk in 'insert and visual mode'
imap jk <Esc>
vmap jk <Esc>

" Map leader
let mapleader = "\<Space>" 

" Map move cursor
noremap H 0
noremap L $
noremap J 5j
noremap K 5k

" Move between windows 
noremap <leader>w <C-w>

" Change to previous buffer
noremap <leader><TAB> :b# <CR>

" Run Startify
nnoremap <leader>y :Startify <CR>

" Edit gitconfig
nnoremap <leader>eg :e! ~/.gitconfig <CR>

" Clear highlighted search
nnoremap <leader>t :set hlsearch! hlsearch? <CR>

" Reload vim
nnoremap <leader>re :source $MYVIMRC <CR>

" Select all in normal mode
nnoremap <leader>% <esc>ggVG <CR>

" Paste toggle 
nnoremap <leader>v :set nopaste <CR>

" Insert new line
nnoremap <C-o> o<Esc>

" Indent all the code
nnoremap <C-b> gg=G

" Spellchecking
nnoremap <leader>sp :set nospell <CR>
nnoremap <C-g> :setlocal spell spelllang=en_en <CR>
nnoremap <C-s> :setlocal spell spelllang=es_es <CR>

" Exit the terminal
tnoremap jk <C-\><C-n>

" ---------------------------------------------------
"                        Goyo
" ---------------------------------------------------

" Show Goyo mode 
nnoremap <leader>g :Goyo <CR>

" ---------------------------------------------------
"                       NERDTree
" ---------------------------------------------------

" Show NERDTree
nnoremap <silent>XX :NERDTreeToggle <CR>

" ---------------------------------------------------
"                       Markdown
" ---------------------------------------------------

" Show markdown preview
nnoremap <leader>md :MarkdownPreview <CR>

" ---------------------------------------------------
"                        FZF
" ---------------------------------------------------

" Search files in the path (similar FZF)
nnoremap <leader>f :Files <CR>

" Search words in lines
nnoremap <leader>l :Lines <CR>

" Show git files (git status)
nnoremap <silent> <leader>s :GFiles? <CR>

" Show all file buffers
nnoremap <silent> <leader>b :Buffers <CR>
