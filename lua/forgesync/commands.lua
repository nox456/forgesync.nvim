local sync = require("forgesync.sync")
local dashboard = require("forgesync.dashboard")
local cli = require("forgesync.cli")
local notify = require("utils.notify")

vim.api.nvim_create_user_command("ForgeSync", function(opts)
	sync.run(opts.fargs[1])
end, {
	desc = "Perform a ForgeSync sync process",
	nargs = 1,
})

vim.api.nvim_create_user_command("ForgeSyncDashboard", function(opts)
	dashboard.open(opts.fargs[1])
end, {
	desc = "Open the ForgeSync dashboard",
	nargs = 1,
})

vim.api.nvim_create_user_command("ForgeSyncRepository", function(opts)
	local path = opts.fargs[1]

	notify.info("Trying to sync repository...")
	cli.resolve_repo(path, function(err_resolve, repo)
		if err_resolve then
			notify.error(err_resolve)
			return
		end

		local on_projects_done = function(err_projects, projects)
			if err_projects or not projects then
				notify.error(err_projects)
				return
			end

			if #projects == 0 then
				notify.warn("No projects found")
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
				notify.warn("No project found for repo " .. repo)
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
