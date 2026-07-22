local M = {}

local BUF = 0
local WIN = 0
local IS_LOADING = false
local MIN_TITLE = 20
local HEADERS = {
	PROJECT = 1,
	TITLE = 2,
	PR = 3,
	SYNCED = 4,
	ISSUE = 5,
}

local function normalize(row, icons)
	local issue_number = row.issue_number
	local project_name = row.project_name
	if not row.project_name or row.project_name == vim.NIL then
		issue_number = row.issue_number .. " (" .. row.issue_repo .. ")"
		project_name = "[NO PROJECT]"
	end
	return {
		project_name,
		row.issue_title or "[NO TITLE]",
		row.has_pr and icons.pr or "-",
		row.is_synced and icons.synced or "-",
		tostring(issue_number),
	}
end

local function build_cells(rows, icons)
	local cells = {}

	table.insert(cells, {
		"Project",
		"Title",
		"PR",
		"Synced",
		"Issue",
	})

	for _, row in ipairs(rows) do
		local normalized = normalize(row, icons)
		table.insert(cells, normalized)
	end

	return cells
end

local function measure(cells)
	local widths = {}
	for _, row in ipairs(cells) do
		for i, cell in ipairs(row) do
			widths[i] = math.max(widths[i] or 0, vim.fn.strdisplaywidth(cell))
		end
	end

	return widths
end

local function layout(widths, available)
	local gutters = #widths - 1
	local title_id = HEADERS.TITLE

	local fixed_total = 0

	for i, width in ipairs(widths) do
		if i ~= title_id then
			fixed_total = fixed_total + width
		end
	end

	local slack = available - gutters - fixed_total

	local title_width = math.max(MIN_TITLE, slack)

	local final = vim.deepcopy(widths)

	final[title_id] = title_width

	return final
end

local function render_lines(cells, widths)
	local clamped_widths = {}
	for i, width in ipairs(widths) do
		clamped_widths[i] = math.max(0, width)
	end

	local lines = {}
	for i, row in ipairs(cells) do
		local cells_out = {}
		for j, cell in ipairs(row) do
			local w = vim.fn.strdisplaywidth(cell)
			local width = clamped_widths[j]

			if w > width then
				cells_out[j] = vim.fn.strcharpart(cell, 0, width - 1) .. "…"
			elseif w < width then
				cells_out[j] = cell .. string.rep(" ", math.max(0, width - w))
			else
				cells_out[j] = cell
			end
		end
		lines[i] = table.concat(cells_out, "|")
	end

	return lines
end

local function set_content(lines)
	if not vim.api.nvim_buf_is_valid(BUF) then
		return
	end

	vim.bo[BUF].modifiable = true

	vim.api.nvim_buf_set_lines(BUF, 0, -1, false, lines)

	vim.bo[BUF].modifiable = false
end

M.refresh = function(cfg, repo_filter)
	if IS_LOADING then
		return
	end

	IS_LOADING = true
	set_content({ "Loading…" })

	local cli = require("forgesync.cli")

	local on_done = function(err, rows)
		if err then
			set_content({ "Error loading forgesync" })
		elseif #rows == 0 then
			set_content({ "No issues found" })
		else
			local cells = build_cells(rows, cfg.icons)
			local widths = measure(cells)

			local available = vim.api.nvim_win_get_width(WIN)

			local layouted = layout(widths, available)

			local lines = render_lines(cells, layouted)

			set_content(lines)
		end
		IS_LOADING = false
	end

	cli.status(on_done, repo_filter)
end

M.close = function()
	if WIN ~= 0 and vim.api.nvim_win_is_valid(WIN) then
		vim.api.nvim_win_close(WIN, true)
	end
end

M.open = function(repo_filter)
	if WIN ~= 0 and vim.api.nvim_win_is_valid(WIN) then
		vim.api.nvim_set_current_win(WIN)
		return
	end

	local cfg = require("forgesync").options.dashboard

	local buf = vim.api.nvim_create_buf(false, true)
	assert(buf ~= 0, "forgesync.nvim: failed to create dashboard buffer")
	BUF = buf

	vim.bo[BUF].buftype = "nofile"
	vim.bo[BUF].bufhidden = "wipe"
	vim.bo[BUF].filetype = "forgesync-dashboard"

	local win_width = math.min(cfg.max_width, math.floor(vim.o.columns * 0.8))
	local win_height = math.min(cfg.max_height, math.floor(vim.o.lines * 0.8))

	WIN = vim.api.nvim_open_win(BUF, true, {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = math.floor((vim.o.lines - win_height) / 2),
		col = math.floor((vim.o.columns - win_width) / 2),
		style = "minimal",
		border = cfg.border,
		title = "ForgeSync",
	})

	vim.wo[WIN].wrap = false
	vim.wo[WIN].cursorline = true

	vim.keymap.set(
		"n",
		cfg.keys.close,
		M.close,
		{ buffer = BUF, nowait = true, silent = true, desc = "ForgeSync: close dashboard" }
	)

	vim.keymap.set("n", cfg.keys.refresh, function()
		M.refresh(cfg, repo_filter)
	end, { buffer = BUF, nowait = true, silent = true, desc = "ForgeSync: refresh dashboard" })

	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = BUF,
		callback = function()
			BUF = 0
			WIN = 0
		end,
	})

	M.refresh(cfg, repo_filter)
end

return M
