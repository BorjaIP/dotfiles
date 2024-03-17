return {
	-- Statusline
	-- https://github.com/nvim-lualine/lualine.nvim
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "base16",
				-- Disable sections and component separators
				component_separators = "",
				section_separators = "",
			},
		})
	end,
}
