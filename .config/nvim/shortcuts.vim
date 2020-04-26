"                 ________  ___  ___  ________  ________  _________  ________  ___  ___  _________  ________
"                |\   ____\|\  \|\  \|\   __  \|\   __  \|\___   ___\\   ____\|\  \|\  \|\___   ___\\   ____\
"                \ \  \___|\ \  \\\  \ \  \|\  \ \  \|\  \|___ \  \_\ \  \___|\ \  \\\  \|___ \  \_\ \  \___|_
"                 \ \_____  \ \   __  \ \  \\\  \ \   _  _\   \ \  \ \ \  \    \ \  \\\  \   \ \  \ \ \_____  \
"                  \|____|\  \ \  \ \  \ \  \\\  \ \  \\  \|   \ \  \ \ \  \____\ \  \\\  \   \ \  \ \|____|\  \
"                    ____\_\  \ \__\ \__\ \_______\ \__\\ _\    \ \__\ \ \_______\ \_______\   \ \__\  ____\_\  \
"                   |\_________\|__|\|__|\|_______|\|__|\|__|    \|__|  \|_______|\|_______|    \|__| |\_________\
"                   \|_________|                                                                      \|_________|


" ------------------------------------------------------------------------------

" ESC to jk in 'insert mode'
imap jk <Esc>

" Map leader
let mapleader = "\<Space>"

" Map move cursor
noremap H 0
noremap L $
noremap J 5j
noremap K 5k

" Remap splits
noremap <leader>w <C-w>

" Adjusing split sizes
noremap <silent> <C-Left> :vertical resize +3<CR>
noremap <silent> <C-Right> :vertical resize -3<CR>
noremap <silent> <C-Up> :resize +3<CR>
noremap <silent> <C-Down> :resize -3<CR>

" Split windows from vert to horiz or horiz to vert
map <leader>th <C-w>t<C-w>H
map <leader>tk <C-w>t<C-w>K

" Change to previous buffer
noremap <leader><TAB> :b# <CR>

" Reload nvim config file
nnoremap <leader>re :source $MYVIMRC<CR>

" Run Startify
nnoremap <leader>y :Startify <CR>

" Edit gitconfig
nnoremap <leader>eg :e! ~/.gitconfig <CR>

" Clear highlighted search
nnoremap <leader>t :set hlsearch! hlsearch? <CR>

" Select all in normal mode
nnoremap <leader>% <esc>ggVG <CR>

" Insert new line
nnoremap <C-o> o<Esc>

" Indent all the code
nnoremap <C-b> gg=G

" Alias replace all to S
nnoremap S :%s//gI<Left><Left><Left>

" Spellchecking
nnoremap <leader>es :setlocal spell! spelllang=es_es <CR>
nnoremap <leader>en :setlocal spell! spelllang=en_en <CR>

nnoremap <leader>u :UndotreeShow<CR>


" Exit the terminal
tnoremap jk <C-\><C-n>

" Save file as sudo when no sudo permissions
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

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
" nnoremap <silent> <leader>s :GFiles? <CR>

" Show all file buffers
" nnoremap <silent> <leader>b :Buffers <CR>

