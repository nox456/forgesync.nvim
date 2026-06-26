require("forgesync.commands")

local config = require("forgesync.config")
vim.notify = require("notify")

local M = {}

function M.setup(opts)
	M.config = config.merges(opts or {})
end

return M
