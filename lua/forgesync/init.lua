local config = require("forgesync.config")

local M = {}

function M.setup(opts)
	M.options = config.merge(opts or {})
	require("forgesync.commands")
end

return M
