local M = {}

M.defaults = {
	auto_sync = true,
	dashboard = {
		border = "rounded",
		max_width = 120,
		max_height = 30,
		keys = {
			close = "q",
			refresh = "r",
		},
		icons = {
			pr = "",
			synced = "",
		},
	},
}

M.merge = function(opts)
	return vim.tbl_deep_extend("force", {}, M.defaults, opts)
end

return M
