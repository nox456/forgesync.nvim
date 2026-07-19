local M = {}

local BUF = nil
local WIN = nil
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
	if not row.project_name then
		issue_number = row.issue_number .. " (" .. row.issue_repo .. ")"
	end
	return {
		row.project_name or "[NO PROJECT]",
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

M.open = function() end

return M
