local M = {}

M.info = function(msg)
	vim.notify(msg, vim.log.levels.INFO, {
		title = "ForgeSync",
	})
end

M.warn = function(msg)
	vim.notify(msg, vim.log.levels.WARN, {
		title = "ForgeSync",
	})
end

M.error = function(msg)
	vim.notify(msg, vim.log.levels.ERROR, {
		title = "ForgeSync",
	})
end

return M
