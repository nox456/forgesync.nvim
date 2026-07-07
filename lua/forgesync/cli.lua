local M = {}

M.cache = {}

M.get_projects = function(on_done)
	if M.cache.projects then
		on_done(nil, M.cache.projects)
		return
	end
	local on_exit = function(result)
		local ok, decoded
		vim.schedule(function()
			if result.code == 0 then
				ok, decoded = pcall(vim.json.decode, result.stdout)
			else
				on_done(result.stderr, nil)
				return
			end

			if not ok then
				on_done("Failed to decode JSON", nil)
				return
			end

			M.cache.projects = decoded.projects
			on_done(nil, decoded.projects)
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
				on_done(result.stderr, nil)
				return
			end

			if not ok then
				on_done("Failed to decode JSON", nil)
				return
			end
			on_done(nil, decoded.report)
		end)
	end

	vim.system({ "forgesync", "sync", "--repo", repo_filter or "", "--json" }, { text = true }, on_exit)
end

M.status = function(on_done, repo_filter)
	local on_exit = function(result)
		local ok, decoded
		vim.schedule(function()
			if result.code == 0 then
				ok, decoded = pcall(vim.json.decode, result.stdout)
			else
				on_done(result.stderr, nil)
				return
			end

			if not ok then
				on_done("Failed to decode JSON", nil)
				return
			end
			on_done(nil, decoded.rows)
		end)
	end

	vim.system({ "forgesync", "status", "--repo", repo_filter or "", "--json" }, { text = true }, on_exit)
end

return M
