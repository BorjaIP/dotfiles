local set = vim.opt

set.mouse = "a" -- Add mouse in all modes
--set.clipboard += unnamedplus -- Copy and paste for vim
set.ignorecase = true -- Case insensitive searching
set.smartcase = true -- Case-sensitive ignore capital letters
set.incsearch = true -- Set incremental search, like modern browsers
-- set.nolazyredraw = true -- Don't redraw while executing macros
set.cursorline = true -- Show cursorline
-- set.splitbelow = splitright -- Fix splitting
set.autoread = true -- Autoread files if it changed
set.swapfile = false -- Disable swap files
--set.nobackup = true -- Disable backup
--set.nowritebackup = true -- Resolve issies with backup files
--set.undodir = true -- Directory for undo ('$XDG_DATA_HOME/nvim/undo')
--set.undofile = true -- Saves undo history
set.updatetime = 300 -- Change time to reload file
set.hidden = true -- Put buffer to the background
set.number = true -- Show line numbers
set.relativenumber = true -- Show the line number relative to the line with the cursor in front of each line.
set.expandtab = true -- Replace tabs with ${tabstop} spaces
set.smartindent = true
set.autoindent = true
set.termguicolors = true
set.tabstop = 4 -- Tabs are 4 spaces
set.shiftwidth = 4 -- Default shift width for indents
set.softtabstop = 4 -- Edit as if the tabs are 4 characters wide
set.shiftround = true -- Round indent to a multiple of 'shiftwidth'
set.cmdheight = 2 -- Give more space for displaying messages
--set.shortmess += c -- Don't pass messages to 'ins-completion-menu'
--set.signcolumn = true -- Always show the signcolumn
-- set colorcolumn=80              " Show column