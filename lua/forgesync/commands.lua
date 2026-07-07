local sync = require("forgesync.sync")

vim.api.nvim_create_user_command("ForgeSync", function()
	sync.run()
end, {
	desc = "Perform a ForgeSync sync process",
})
