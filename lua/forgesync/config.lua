local M = {}

M.defaults = {
	auto_sync = true,
}

M.merge = function(opts)
	return vim.tbl_deep_extend("force", {}, M.defaults, opts)
end

return M
