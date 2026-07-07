require("forgesync.commands")

local config = require("forgesync.config")

local M = {}

function M.setup(opts)
	M.config = config.merges(opts or {})
end

return M
