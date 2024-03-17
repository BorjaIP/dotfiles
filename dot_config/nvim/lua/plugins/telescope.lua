return {
	-- Highly extendable fuzzy finder over lists
	-- https://github.com/nvim-telescope/telescope.nvim
	"nvim-telescope/telescope.nvim",
	tag = "0.1.5",

	dependencies = {
		-- lua functions that many plugins use
		"nvim-lua/plenary.nvim",
	},
	config = function()
		-- select colors
		local colors = require("base16-colorscheme").colors
		local TelescopeColor = {
			TelescopeMatching = { fg = colors.base0B },
			TelescopePromptBorder = { fg = colors.base0E },
			TelescopeResultsBorder = { fg = colors.base0E },
			TelescopePreviewBorder = { fg = colors.base0E },
			TelescopePromptTitle = { fg = colors.base0C },
			TelescopeResultsTitle = { fg = colors.base0C },
			TelescopePreviewTitle = { fg = colors.base0C },
		}

		for hl, col in pairs(TelescopeColor) do
			vim.api.nvim_set_hl(0, hl, col)
		end

		-- keymaps
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<C-p>", builtin.find_files, {})
		vim.keymap.set("n", "<leader>fg", builtin.git_files, {})
		vim.keymap.set("n", "<leader>pws", function()
			local word = vim.fn.expand("<cword>")
			builtin.grep_string({ search = word })
		end)
		vim.keymap.set("n", "<leader>pWs", function()
			local word = vim.fn.expand("<cWORD>")
			builtin.grep_string({ search = word })
		end)
		vim.keymap.set("n", "<leader>ps", function()
			builtin.grep_string({ search = vim.fn.input("Grep > ") })
		end)
		vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
	end,
}
