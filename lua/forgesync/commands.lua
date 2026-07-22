local sync = require("forgesync.sync")
local dashboard = require("forgesync.dashboard")
local cli = require("forgesync.cli")

vim.api.nvim_create_user_command("ForgeSync", function(opts)
	sync.run(opts.fargs[1])
end, {
	desc = "Perform a ForgeSync sync process",
	nargs = 1,
})

vim.api.nvim_create_user_command("ForgeSyncDashboard", function()
	dashboard.open()
end, {
	desc = "Open the ForgeSync dashboard",
})

vim.api.nvim_create_user_command("ForgeSyncRepository", function(opts)
	local path = opts.fargs[1]

	cli.resolve_repo(path, function(err_resolve, repo)
		if err_resolve then
			vim.notify(err_resolve, vim.log.levels.ERROR)
			return
		end

		local on_projects_done = function(err_projects, projects)
			if err_projects or not projects then
				vim.notify(err_projects, vim.log.levels.ERROR)
				return
			end

			if #projects == 0 then
				vim.notify("No projects found", vim.log.levels.WARN)
				return
			end

			local project = nil

			for _, p in ipairs(projects) do
				if p.repo == repo then
					project = p
					break
				end
			end

			if not project then
				vim.notify("No project found for repo " .. repo, vim.log.levels.WARN)
				return
			end

			sync.run(project.repo)
		end

		cli.get_projects(on_projects_done)
	end)
end, {
	desc = "Perform a ForgeSync sync process for the given repository",
	nargs = 1,
})
