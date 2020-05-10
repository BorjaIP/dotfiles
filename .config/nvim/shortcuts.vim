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

" Show undo files
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

" ---------------------------------------------------
"                        CoC
" ---------------------------------------------------

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
" inoremap <silent><expr> <TAB>
      " \ pumvisible() ? "\<C-n>" :
      " \ <SID>check_back_space() ? "\<TAB>" :
      " \ coc#refresh()
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
" if exists('*complete_info')
  " inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
" else
  " inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> <leader>rr <Plug>(coc-rename)

" Use K to show documentation in preview window.
" nnoremap <silent> K :call <SID>show_documentation()<CR>


