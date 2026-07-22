local notify = require("utils.notify")

local M = {}

local cli = require("forgesync.cli")
local is_syncing = false

M.run = function(repo_filter)
	if is_syncing then
		notify.warn("Already syncing...")
		return
	end
	is_syncing = true
	notify.info("Syncing...")

	local on_done = function(err, report)
		is_syncing = false
		if err then
			notify.error("Sync failed: " .. err)
			return
		end
		notify.info("Synced!")
		local created = report.created
		local updated = report.updated
		local unchanged = report.unchanged

		notify.info(created .. " created, " .. updated .. " updated, " .. unchanged .. " unchanged")
	end

	cli.sync(on_done, repo_filter)
end

return M
