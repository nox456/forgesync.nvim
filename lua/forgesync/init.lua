local config = require("forgesync.config")

local M = {}

function M.setup(opts)
	require("forgesync.commands")
	M.config = config.merges(opts or {})
end

return M
