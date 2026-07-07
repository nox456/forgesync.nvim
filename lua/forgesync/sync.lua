local M = {}

local cli = require("forgesync.cli")
local is_syncing = false

M.run = function(repo_filter)
	if is_syncing then
		vim.notify("Already syncing...", vim.log.levels.WARN, { title = "ForgeSync" })
		return
	end
	is_syncing = true
	vim.notify("Syncing...", vim.log.levels.INFO, { title = "ForgeSync" })

	local on_done = function(err, report)
		is_syncing = false
		if err then
			vim.notify("Sync failed: " .. err, vim.log.levels.ERROR, { title = "ForgeSync" })
			return
		end
		vim.notify("Synced!", vim.log.levels.INFO, { title = "ForgeSync" })
		local created = report.created
		local updated = report.updated
		local unchanged = report.unchanged

		vim.notify(
			created .. " created, " .. updated .. " updated, " .. unchanged .. " unchanged",
			vim.log.levels.INFO,
			{ title = "ForgeSync" }
		)
	end

	cli.sync(on_done, repo_filter)
end

return M
