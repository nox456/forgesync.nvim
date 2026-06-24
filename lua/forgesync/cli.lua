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

return M
