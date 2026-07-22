local sync = require("forgesync.sync")
local dashboard = require("forgesync.dashboard")

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
