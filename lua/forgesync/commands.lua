local sync = require("forgesync.sync")
local dashboard = require("forgesync.dashboard")

vim.api.nvim_create_user_command("ForgeSync", function()
	sync.run()
end, {
	desc = "Perform a ForgeSync sync process",
})

vim.api.nvim_create_user_command("ForgeSyncDashboard", function()
	dashboard.open()
end, {
	desc = "Open the ForgeSync dashboard",
})
