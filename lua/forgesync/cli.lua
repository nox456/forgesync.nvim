local M = {}

M.get_projects = function(on_done)
	local on_exit = function(result)
		local ok, decoded
		vim.schedule(function()
			if result.code == 0 then
				ok, decoded = pcall(vim.json.decode, result.stdout)
			else
				vim.notify("Failed to get projects: " .. result.stderr, vim.log.levels.ERROR)
				return
			end

			if not ok then
				vim.notify("Failed to decode JSON", vim.log.levels.ERROR)
				return
			end
		end)

		vim.schedule(function()
			on_done(decoded.projects)
		end)
	end

	vim.system({ "forgesync", "projects", "--json" }, { text = true }, on_exit)
end

M.sync = function(on_done, repo_filter)
	local on_exit = function(result)
		local ok, decoded
		vim.schedule(function()
			if result.code == 0 then
				ok, decoded = pcall(vim.json.decode, result.stdout)
			else
				vim.notify("Failed to sync: " .. result.stderr, vim.log.levels.ERROR)
				return
			end

			if not ok then
				vim.notify("Failed to decode JSON", vim.log.levels.ERROR)
				return
			end
		end)

		vim.schedule(function()
			on_done(decoded.report)
		end)
	end

	vim.system({ "forgesync", "sync", "--repo", repo_filter, "--json" }, { text = true }, on_exit)
end

M.status = function(on_done, repo_filter)
	local on_exit = function(result)
		local ok, decoded
		vim.schedule(function()
			if result.code == 0 then
				ok, decoded = pcall(vim.json.decode, result.stdout)
			else
				vim.notify("Failed to get status: " .. result.stderr, vim.log.levels.ERROR)
				return
			end

			if not ok then
				vim.notify("Failed to decode JSON", vim.log.levels.ERROR)
				return
			end
		end)

		vim.schedule(function()
			on_done(decoded.rows)
		end)
	end

	vim.system({ "forgesync", "status", "--repo", repo_filter, "--json" }, { text = true }, on_exit)
end

return M
