local M = {}

M.cache = {}

M.get_projects = function(on_done)
	if M.cache.projects then
		vim.schedule(function()
			on_done(nil, M.cache.projects)
		end)
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

			if not decoded.projects then
				on_done("Missing projects key", nil)
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

			if not decoded.report then
				on_done("Missing report key", nil)
				return
			end

			on_done(nil, decoded.report)
		end)
	end

	local cmd = { "forgesync", "sync", "--json" }

	if repo_filter then
		table.insert(cmd, "--repo")
		table.insert(cmd, repo_filter)
	end

	vim.system(cmd, { text = true }, on_exit)
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

			if not decoded.rows then
				on_done("Missing rows key", nil)
				return
			end

			on_done(nil, decoded.rows)
		end)
	end

	local cmd = { "forgesync", "status", "--json" }

	if repo_filter then
		table.insert(cmd, "--repo")
		table.insert(cmd, repo_filter)
	end

	vim.system(cmd, { text = true }, on_exit)
end

return M
