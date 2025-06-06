return {
	{
		-- Base16 colorscheme
		-- https://github.com/RRethy/base16-nvim
		"RRethy/nvim-base16",
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			-- load the colorscheme here
			vim.cmd([[colorscheme base16-ocean]])
		end,
	},
}
