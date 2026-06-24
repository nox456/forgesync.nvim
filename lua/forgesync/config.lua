local M = {}

M.defaults = {
	auto_sync = true,
}

M.merges = function(opts)
	return vim.tbl_deep_extend("force", {}, M.defaults, opts)
end

return M
