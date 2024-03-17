return {
	-- Lightweight yet powerful formatter
	-- https://github.com/stevearc/conform.nvim
	"stevearc/conform.nvim",
	opts = {
		notify_on_error = false,
		format_on_save = {
			-- These options will be passed to conform.format()
			timeout_ms = 500,
			lsp_fallback = true,
		},
		formatters_by_ft = {
			lua = { "stylua" },
		},
	},
}
