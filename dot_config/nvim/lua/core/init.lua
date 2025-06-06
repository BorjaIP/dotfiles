--                _________  ___      ___ ___  _____ _______
--               |\   ___  \|\  \    /  /|\  \|\   _ \  _   \
--               \ \  \\ \  \ \  \  /  / | \  \ \  \\\__\ \  \
--                \ \  \\ \  \ \  \/  / / \ \  \ \  \\|__| \  \
--                 \ \  \\ \  \ \    / /   \ \  \ \  \    \ \  \
--                  \ \__\\ \__\ \__/ /     \ \__\ \__\    \ \__\
--                   \|__| \|__|\|__|/       \|__|\|__|     \|__|

-- -----------------------------------------------------------------------------
--                    	        Lazy.nvim
-- -----------------------------------------------------------------------------
-- Plugin manager
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

require("core.options")
require("core.keymaps")

require("lazy").setup({
	spec = "plugins",
	change_detection = { notify = false },
})
