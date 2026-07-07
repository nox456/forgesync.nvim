local config = require("forgesync.config")

local M = {}

function M.setup(opts)
	require("forgesync.commands")
	M.config = config.merge(opts or {})
end

return M
